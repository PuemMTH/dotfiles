#
# ~/.bashrc
#

[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
PS1='[\u@\h \W]\$ '

eval "$($HOME/.local/bin/mise activate bash)"

# Oracle Skills CLI
export PATH="$HOME/.oracle-skills/bin:$PATH"
