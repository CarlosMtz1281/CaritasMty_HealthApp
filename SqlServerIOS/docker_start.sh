#!/bin/bash
echo "alias 'll=ls -lh'" >> /root/.bashrc
/bin/sleep 2; /etc/init.d/ssh start 
