# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
#[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
    # We have color support; assume it's compliant with Ecma-48
    # (ISO/IEC-6429). (Lack of such support is extremely rare, and such
    # a case would tend to support setf rather than setaf.)
    color_prompt=yes
    else
    color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w \$\[\033[00m\] '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# some more ls aliases
#alias ll='ls -l'
#alias la='ls -A'
#alias l='ls -CF'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

#
#   ACBOX Related additions
#
export PATH=$PATH:~/ACBOX/scripts:~/ACBOX/scripts/debug:~/ACBOX/scripts/utils:~/ACBOX/scripts/status
export PATH=$PATH:~/ACBOX/MCC_DAQ:~/ACBOX/MCC_DAQ/test:~/ACBOX/MCC_DAQ/scripts
export PYTHON_EXE=~/venv/bin/python
export PROMPT_COMMAND='RETRN_VAL=$?;echo "$(whoami) $(date) [$$]: $(history 1 | sed "s/^[ ]*[0-9]\+[ ]*//" ) [$RETRN_VAL]" >> ~/shell_history'

alias python=/home/pi/venv/bin/python

alias on_ssh='$HOME/ACBOX/scripts/utils/auto_ssh_screen.sh'
alias help='$HOME/ACBOX/scripts/debug/echo_help.sh | less'
alias help_cli='$HOME/ACBOX/scripts/debug/echo_help.sh --cli | less'
alias help_daq='$HOME/ACBOX/scripts/debug/echo_help.sh --mccdaq | less'
alias help_debug='$HOME/ACBOX/scripts/debug/echo_help.sh --debug | less'
alias get_loc='$HOME/ACBOX/scripts/status/get_loc.sh'
alias get_cpu_temp='$HOME/ACBOX/scripts/status/get_cpu_temp.sh'
alias get_free_mem='$HOME/ACBOX/scripts/status/get_free_mem.sh'
alias get_volume='$HOME/ACBOX/scripts/status/get_volume.sh Headphone'
alias config_daq='$HOME/ACBOX/MCC_DAQ/config_daq'
alias start_collect='$HOME/ACBOX/MCC_DAQ/start_collect'
alias daq_state='$HOME/ACBOX/scripts/status/get_daq_state.sh'

alias has_fix="gpspipe -n 4 -w | grep 'TPV' | grep -oE 'mode\":0,|mode\":1,' > /dev/null && echo 'GPS HAS NO FIX' || echo 'GPS HAS FIX'"
alias has_pps="gpspipe -n 3 -w | grep 'WATCH' | grep -oE 'pps\":true' > /dev/null && echo 'HAS PPS' || echo 'NO PPS'"
alias see_daq="lsusb | grep 'Measurement Computing Corp' > /dev/null && echo 'DAQ Connected' || echo 'DAQ Not Found'"