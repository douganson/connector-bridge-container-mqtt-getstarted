#!/bin/sh

report_ip_address()
{
   IP_ADDRESS=`ifconfig | perl -nle'/dr:(\S+)/ && print $1' | tail -1`
   HOSTNAME=`hostname`
   echo "Container Hostname: " ${HOSTNAME} " IP: " ${IP_ADDRESS}
}

update_hosts()
{
    sudo /home/arm/update_hosts.sh
}

run_supervisord()
{
   /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf 2>&1 1>/tmp/supervisord.log
}

run_bridge()
{
   cd /home/arm
   su -l arm -s /bin/bash -c "/home/arm/restart.sh"
}

run_configurator()
{
  cd /home/arm/configurator
  su -l arm -s /bin/bash -c "/home/arm/configurator/runConfigurator.sh 2>&1 1> /tmp/configurator.log &"
}

run_mosquitto() {
  cd /home/arm
  mosquitto -d -c /etc/mosquitto/mosquitto.conf &
}

run_nodered() {
  cd /home/arm
  node-red 2>&1 1>/tmp/node-red.log &
}

main() 
{
   # report_ip_address
   update_hosts
   run_bridge
   run_configurator
   run_mosquitto
   run_nodered
   run_supervisord
}

main $*
