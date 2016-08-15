#!/usr/bin/python

ip = "192.168.1.230"
port = 1883

import paho.mqtt.client as paho
mqttc = paho.Client()
topic = "mbed/request/endpoints/cc69e7c5-c24f-43cf-8365-8d23bb01c707/86/0/1"
message = "{\"path\":\"/86/0/1\",\"new_value\":\"arm1234\",\"ep\":\"cc69e7c5-c24f-43cf-8365-8d23bb01c707\",\"coap_verb\":\"post\",\"options2\":\"noResp=true\"}"
mqttc.connect(ip, port, 60)
mqttc.publish(topic,message)
mqttc.disconnect();
