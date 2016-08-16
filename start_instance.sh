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

set_api_token() {
   API_TOKEN="$1"
   if [ "${API_TOKEN}X" != "X" ]; then
	sed -e s/"Your_Connector_API_Token_Goes_Here"/"${API_TOKEN}"/g < mds/connector-bridge/conf/gateway.properties > mds/connector-bridge/conf/gateway.properties.new
        mv mds/connector-bridge/conf/gateway.properties mds/connector-bridge/conf/gateway.properties-OLD
        mv mds/connector-bridge/conf/gateway.properties.new mds/connector-bridge/conf/gateway.properties
   fi
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
  su -l arm -s /bin/bash -c "node-red flows_fcb83491ce12.json 2>&1 1>/tmp/node-red.log &"
}

main() 
{
   # report_ip_address
   update_hosts
   set_api_token $*
   run_bridge
   run_configurator 
   run_mosquitto
   run_nodered
   run_supervisord
}

main $*
