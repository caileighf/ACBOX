#!/bin/bash
USAGE=$(cat <<-END
 usage: copy_ssh_keys_to_remote.sh -u <REMOTE-USER> -i <REMOTE-IP-ADDRESS>

END
)

while getopts u:i: flag
do
    case "${flag}" in
        u) REMOTE_USER=${OPTARG};;
        i) REMOTE_IP=${OPTARG};;
        \? ) echo "Unknown option: -$OPTARG" >&2; ;;
        :  ) echo "Missing option argument for -$OPTARG" >&2; ;;
        *  ) echo "Unimplemented option: -$OPTARG" >&2; ;;
    esac
done

if ((OPTIND == 1)); then
    echo "No options specified";
    kill -SIGINT $$
fi

ssh-copy-id "${REMOTE_USER}@${REMOTE_IP}"