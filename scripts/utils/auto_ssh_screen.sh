#!/bin/bash
#
#  Attaches to the first Detached Screen. Otherwise starts a new Screen.
# https://superuser.com/questions/580087/automatically-start-screen-upon-ssh-login

# Only run if we are not already inside a running screen and only if in an SSH session.
if [[ -z "${STY}" && ! -z "${SSH_CLIENT}" ]]; then
  detached_screens=($(screen -ls | grep pts | grep -v Attached))

  for screen in "${detached_screens[@]}"; do
    if [[ "${screen}" == *".pts"* ]]; then
      IFS='.pts' read -ra split <<< "${screen}"
      for id in "${split[@]}"; do
        first_id="${id}"
        break
      done 
      break
    fi
  done

  screen -R $first_id
fi