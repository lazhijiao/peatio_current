#!/bin/bash

if [ "$1" == "off" ]; then
  echo "switch off maintenance mode"
  ln -sf /home/deploy/exchange/config/nginx.conf /etc/nginx/conf.d/exchange.conf
  service nginx reload
else
  echo "switch on maintenance mode"
  ln -sf /home/deploy/exchange/config/nginx_maintenance.conf /etc/nginx/conf.d/exchange.conf
  service nginx reload
fi
