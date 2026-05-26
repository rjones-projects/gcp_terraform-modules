#!/bin/bash -xe

# yum update -y
# yum install bind-utils -y

if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root" 1>&2
  exit 1
fi

restrict_su() {
  cat >/tmp/sudoers.sh <<"EOF"
#!/bin/bash
sudo chmod a+r /var/google-sudoers.d/*
sudo chmod a+r /etc/sudoers.d/google_sudoers
if grep -Fq "/bin/su" /etc/sudoers.d/google_sudoers
then
  :
else
  sudo awk 'FNR==1{print $0 ", !/bin/su";}' /etc/sudoers.d/google_sudoers > /tmp/google_sudoers
  sudo visudo -c -f /tmp/google_sudoers
  if [ "$?" -eq "0" ]; then
    sudo cp -f /tmp/google_sudoers /etc/sudoers.d/google_sudoers
  fi
fi
for file in /var/google-sudoers.d/*; do
  echo "Removing individual user access"
  echo "Removing individual user access for $file"
  filename=$(basename $file)
  if sudo grep -Fq "/bin/su" $file
  then
    echo "Su access already removed from $filename"
  else
    echo "Removing su access for $filename"
    sudo awk 'FNR==1{print $0 ", !/bin/su";}' $file > /tmp/$filename
    sudo visudo -c -f /tmp/$filename
    if [ "$?" -eq "0" ]; then
      sudo cp -f /tmp/$filename $file
    fi
  fi
done
/bin/bash
EOF

  chmod a+x /tmp/sudoers.sh
  chmod a+r /var/google-sudoers.d

  echo -e '\nForceCommand /tmp/sudoers.sh' >>/etc/ssh/sshd_config
  systemctl restart sshd
}

install_google_logging_monitoring(){
  yum clean all
  rm -f /etc/yum.repos.d/google-cloud-monitoring.repo
  rm -f /etc/yum.repos.d/google-cloud-logging.repo
  curl -sSO https://dl.google.com/cloudagents/add-monitoring-agent-repo.sh
  bash add-monitoring-agent-repo.sh --also-install

  curl -sSO https://dl.google.com/cloudagents/add-logging-agent-repo.sh
  bash add-logging-agent-repo.sh --also-install
}

enable_google_monitoring() {
  echo "[INFO] Installing Stackdriver Monitoring and logging agent"

  install_google_logging_monitoring


  systemctl restart stackdriver-agent
  systemctl enable stackdriver-agent

  mkdir -p /etc/google-fluentd/config.d/
  cat >/etc/google-fluentd/config.d/squid.conf <<"EOF"
<source>
  @type tail
  <parse>
    @type json
  </parse>  
  path /var/log/squid/*.log
  pos_file /var/lib/google-fluentd/pos/squid.pos
  read_from_head true
  tag squid
</source>
EOF

  systemctl restart google-fluentd
  systemctl enable google-fluentd
}

enable_squid() {
  # Install squid proxy
  #
  # Once squid is installed, linux system proxy can be set with the following environment variables:
  #   export https_proxy=http://127.0.0.1:3128/
  #   export https_proxy=http://127.0.0.1:3128/
  #   export no_proxy=169.254.169.254  # Skip proxy for the local Metadata Server.

  echo "[INFO] Installing Squid"

  yum install -y squid

  gsutil cp ${whitelist_gcs} /etc/squid/whitelist.txt
  gsutil cp ${squid_config_gcs} /etc/squid/squid.conf
  gsutil cp ${tls_inspection_bypass_gcs} /etc/squid/tls_inspection_bypass.txt

  if [ ! -d /etc/squid/ssl ]; then
    echo "[INFO] Generating SSL cert"
    mkdir -p /etc/squid/ssl
    cd /etc/squid/ssl
    openssl genrsa -out squid.key 4096
    openssl req -new -key squid.key -out squid.csr -subj "/C=XX/ST=XX/L=squid/O=squid/CN=squid"
    openssl x509 -req -days 3650 -in squid.csr -signkey squid.key -out squid.crt
    cat squid.key squid.crt >>squid.pem

    /usr/lib64/squid/security_file_certgen -c -s /var/spool/squid/ssl_db -M 4MB
  fi

  systemctl stop squid
  systemctl start squid
  systemctl enable squid

  sysctl -w net.ipv4.ip_forward=1
  echo "net.ipv4.ip_forward = 1" >>/etc/sysctl.d/ip_forward.conf

  my_ip=$(hostname -I | xargs)
  if [ ${allow_extra_connections} = true ]; then
    echo "start allowing extra connections"
    %{ for key, values in extra_connections_map }
      iptables -t nat -A PREROUTING -d ${values.ip} -i eth0 -p tcp -m tcp --dport ${values.port} -j RETURN
      iptables -t nat -A POSTROUTING -s ${extra_connections_source_range} -j MASQUERADE -d ${values.ip} -p tcp --dport ${values.port}
    %{ endfor ~}
  fi
  iptables -t nat -A PREROUTING -p tcp --dport 443 -j DNAT --to-destination $my_ip:443
  iptables -t nat -A PREROUTING -p tcp --dport 80 -j DNAT --to-destination $my_ip:80
  
  iptables-save >/etc/sysconfig/iptables
}

# infinite net cat process listening for health check
enable_health_check_port() {
  yum install -y nc
  nohup bash -c "while ! nc -z localhost 3128; do sleep 1; done" &
  nohup bash -c "while true; do nc -l -p 8080 -c 'echo -e \"HTTP/1.1 200 OK\n\n \$(date)\"'; done" &
}

watch_for_whitelist_changes() {
  cat >/etc/squid/reload_config.sh <<"EOF"
#!/bin/bash
while true; do
  sleep 10
  gsutil cp ${whitelist_gcs} /etc/squid/whitelist.txt
  gsutil cp ${squid_config_gcs} /etc/squid/squid.conf
  gsutil cp ${tls_inspection_bypass_gcs} /etc/squid/tls_inspection_bypass.txt
  squid -k parse && squid -k reconfigure
done
EOF
  chmod +x /etc/squid/reload_config.sh
  nohup bash -c "/etc/squid/reload_config.sh" &
}



watch_for_dns_dig_changes(){
  # 0. do it in loop
  # 1. understand if variable is IP
  # 2. dig for DNS 
  # 3. build a list of IPS 
  # 4. clear the IPTABLES rules 
  # 5. load new iptables rules
   yum install bind-utils -y

  cat >/etc/squid/dns_dig_config.sh <<"EOF"
  #!/bin/bash
  export allow_dns_targets="${allow_dns_targets}"
  while true; do
 IPS=$(
  for i in $(seq 60); do 
   for dns_name in $allow_dns_targets; do
    dig +short $dns_name A
  done
  done| sort|uniq
  )


  echo "Digged IPs:  $IPS " > /tmp/debug.log
  # clear existing IP TABLES prerouting/postrouting
  iptables -t nat -F POSTROUTING
  iptables -t nat -F PREROUTING
  
  # apply new rules
  if [ ${allow_extra_connections} = true ]; then
    echo "start allowing extra connections"
  %{ for key, values in extra_connections_map }
    iptables -t nat -A PREROUTING -d ${values.ip} -i eth0 -p tcp -m tcp --dport ${values.port} -j RETURN
    iptables -t nat -A POSTROUTING -s ${extra_connections_source_range} -j MASQUERADE -d ${values.ip} -p tcp --dport ${values.port}
  %{ endfor ~}
  fi
  
  for ip in $IPS; do 
    iptables -t nat -A PREROUTING -d $ip -i eth0 -p tcp -m tcp --dport 443 -j RETURN
    iptables -t nat -A POSTROUTING -s 0.0.0.0/0 -j MASQUERADE -d $ip -p tcp --dport 443
  done
  
  my_ip=$(hostname -I | xargs)
  iptables -t nat -A PREROUTING -p tcp --dport 443 -j DNAT --to-destination $my_ip:443
  iptables -t nat -A PREROUTING -p tcp --dport 80 -j DNAT --to-destination $my_ip:80
  iptables-save >/etc/sysconfig/iptables
  iptables -t nat -L -v -n --line-numbers > /tmp/iptables.state.txt
  sleep 3600 # slepp 1 hour
done  
EOF
  chmod +x /etc/squid/dns_dig_config.sh
  nohup bash -c "/etc/squid/dns_dig_config.sh" > /tmp/nohup_output.log 2>&1 &
  echo "nohup cmd :  $? " >> /tmp/debug.log
}
###################################
# Main body of script starts here #
###################################
echo "[INFO] Start of script"


echo "Enable google monitoring ?"${enable_google_monitoring}
if [ ${enable_google_monitoring} = true ]; then
  enable_google_monitoring
fi

echo "Enable squid ?"${enable_squid}
if [ ${enable_squid} = true ]; then
  enable_squid
fi

echo "Restrict su ?"${restrict_su}
if [ ${restrict_su} = true ]; then
  restrict_su
fi
cd /etc/pki/ca-trust/source/anchors/
printf "%s" "${cert}" > voda.pem
openssl x509 -in voda.pem -inform PEM -out voda.crt
update-ca-trust
systemctl restart squid

enable_health_check_port
watch_for_whitelist_changes
watch_for_dns_dig_changes

echo "[INFO] - Script completed"