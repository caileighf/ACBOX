#!/bin/bash                                                                                                                                                             
status=$(amixer sget $1 | tail -n 1)                                                                                                                                    
vol=$(echo ${status} | gawk '{print $5}' | tr -d [%])                                                                                                                   
state=$(echo ${status} | gawk '{print $7}')                                                                                                                             
text="${vol}"                                                                                                                                                           
echo ${text}