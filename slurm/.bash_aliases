# find in the hystory by key words
alias grh="history|grep"

# fake tree command, the only option to add is the base directory
treef() (
    [ -d "$1" ] && { dir="$1"; shift; } || dir='.'
    find "$dir" "$@" | sed -e 's@/@|@g;s/^\.|//;s/[^|][^|]*|/ |/g;/^[. |]*$/d'
)
# some more ls aliases
alias ll='ls -alF'

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias lt="du ./* -shc"

alias snode="$HOME/scripts/slurmthings/snode.sh"

chmod +x $HOME/scripts/slurmthings/all2.q
chmod +x $HOME/scripts/slurmthings/snode.sh


alias whydown0="sinfo -o %.30P%.30n%.30E%.30A"
alias whydown1="sinfo -o %.30P%.30n%.30E%.30a"
alias whydown2="sinfo -o %.30P%.30n%.30E%.30C"
alias whydown3="sinfo -o %.30P%.30n%.30E%.30T"
