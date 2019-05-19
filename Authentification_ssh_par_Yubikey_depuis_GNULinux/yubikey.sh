#!/bin/bash

pgrep -l gpg-agent &>/dev/null
if [[ "$?" != "0" ]]; then
    gpg-agent --daemon &>/dev/null
fi
export SSH_AUTH_SOCK="/run/user/$(id -u)/gnupg/S.gpg-agent.ssh"
