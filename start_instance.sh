#!/bin/bash

update_hosts()
{
    sudo /home/arm/update_hosts.sh
    rm /home/arm/update_hosts.sh
}

run_supervisord()
{
   /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf 2>&1 1>/tmp/supervisord.log
}

run_connector_bridge()
{
   cd /home/arm
   su -l arm -s /bin/bash -c "/home/arm/restart.sh &"
}

run_properties_editor()
{
  cd /home/arm/properties-editor
  su -l arm -s /bin/bash -c "/home/arm/properties-editor/runPropertiesEditor.sh 2>&1 1> /tmp/properties-editor.log &"
}

enable_long_polling() {
   LONG_POLL="$3"
   if [ "$2" = "use-long-polling" ]; then
        LONG_POLL="$2"
   fi
   if [ "${LONG_POLL}" = "use-long-polling" ]; then
        DIR="connector-bridge/conf"
        FILE="service.properties"
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
        DIR="connector-bridge/conf"
        FILE="service.properties"
        cd /home/arm
	sed -e "s/Your_Connector_API_Token_Goes_Here/${API_TOKEN}/g" ${DIR}/${FILE} 2>&1 1> ${DIR}/${FILE}.new
        mv ${DIR}/${FILE} ${DIR}/${FILE}.token
        mv ${DIR}/${FILE}.new ${DIR}/${FILE}
	chown arm.arm ${DIR}/${FILE}
   fi
}

run_mosquitto() {
  cd /home/arm
  mosquitto -d -c /etc/mosquitto/mosquitto.conf &
}

set_perms() {
  cd /home/arm
  chown -R arm.arm .
}

run_nodered() {
  cd /home/arm
  su -l arm -s /bin/bash -c "node-red flows_fcb83491ce12.json 2>&1 1>/tmp/node-red.log &"
}

main() 
{
   update_hosts
   set_api_token $*
   enable_long_polling $*
   set_perms $*
   run_mosquitto
   run_nodered
   run_properties_editor
   run_connector_bridge
   run_supervisord
}

main $*
