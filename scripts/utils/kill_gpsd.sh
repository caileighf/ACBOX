#!/bin/bash

service --status-all | grep gpsd
start-stop-daemon -K --name gpsd
service --status-all | grep gpsd