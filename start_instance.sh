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

enable_long_polling() {
   LONG_POLL="$3"
   if [ "$2" = "use-long-polling" ]; then
        LONG_POLL="$2"
   fi
   if [ "${LONG_POLL}" = "use-long-polling" ]; then
        DIR="mds/connector-bridge/conf"
        FILE="gateway.properties"
        cd /home/arm
        sed -e "s/mds_enable_long_poll=false/mds_enable_long_poll=true/g" ${DIR}/${FILE} 2>&1 1> ${DIR}/${FILE}.new
        mv ${DIR}/${FILE} ${DIR}/${FILE}.poll
        mv ${DIR}/${FILE}.new ${DIR}/${FILE}
        chown arm.arm ${DIR}/${FILE}
   fi	
}

set_api_token() {
   API_TOKEN="$2"
   if [ "$2" = "use-long-polling" ]; then
        API_TOKEN="$3" 
   fi
   if [ "${API_TOKEN}X" != "X" ]; then
        DIR="mds/connector-bridge/conf"
        FILE="gateway.properties"
        cd /home/arm
	sed -e "s/Your_Connector_API_Token_Goes_Here/${API_TOKEN}/g" ${DIR}/${FILE} 2>&1 1> ${DIR}/${FILE}.new
        mv ${DIR}/${FILE} ${DIR}/${FILE}.token
        mv ${DIR}/${FILE}.new ${DIR}/${FILE}
	chown arm.arm ${DIR}/${FILE}
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
   enable_long_polling $*
   run_bridge
   run_configurator 
   run_mosquitto
   run_nodered
   run_supervisord
}

main $*
