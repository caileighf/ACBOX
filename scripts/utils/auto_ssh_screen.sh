#!/bin/bash
#
#  Attaches to the first Detached Screen. Otherwise starts a new Screen.
# https://superuser.com/questions/580087/automatically-start-screen-upon-ssh-login

# Only run if we are not already inside a running screen and only if in an SSH session.
if [[ -z "${STY}" && ! -z "${SSH_CLIENT}" ]]; then
  screen -S ACBOX -rd || screen -S ACBOX -p 0 -X stuff "help --welcome^M"
fi