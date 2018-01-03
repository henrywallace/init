#
# This bashrc configuration was written only to work on OSX.
# TODO: make this flexible enough to work on all *nix.
#
# This config assumes the following conig also exit:
#
#   ~/.aliases
#   /usr/local/google-cloud-sdk/completion.bash.inc
#   /usr/local/google-cloud-sdk/path.bash.inc
#

# git prompt
#GIT_PS1_SHOWDIRTYSTATE="yes"
#GIT_PS1_SHOWSTASHSTATE="yes"
GIT_PS1_SHOWUPSTREAM="verbose"
GIT_PROMPT=~/.git-prompt.sh
test -f $GIT_PROMPT || curl -sS -o $GIT_PROMPT https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh
source $GIT_PROMPT

# git completion
GIT_COMPLETION=~/.git-completion.sh
test -f $GIT_COMPLETION || curl -sS -o $GIT_COMPLETION https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash
source $GIT_COMPLETION

# nice prompt
# https://unix.stackexchange.com/a/275016/162041
# https://wiki.archlinux.org/index.php/Bash/Prompt_customization
PROMPT_COMMAND=__prompt_command
__prompt_command() {
  local status="$?"
  # vvv trim whitespace: https://stackoverflow.com/a/12973694
  local git="$(echo $(__git_ps1) | xargs)"
  local dir="$(sed "s:\([^/\.]\)[^/]*/:\1/:g" <<< ${PWD/#$HOME/\~})"
  #venv=$(echo $(basename $VIRTUAL_ENV) | xargs)
  local prefix="$(hostname)"
  # PS1="$venv$git[$prefix $dir] "
  # PS1="$git[$prefix $dir] "
  PS1="$git[$prefix $dir] "

  # At one point, in time, I thought colorizing the typed command was cool:
  # shopt -s extdebug
  # trap "tput sgr0" DEBUG
}

# pretty ls colors
# https://apple.stackexchange.com/a/33679/192291
export CLICOLOR=1

# add brew installed binaries to path
export PATH="$HOME/bin:$HOME/.cask/bin:$PATH"

# https://unix.stackexchange.com/a/18443/162041
# https://www.gnu.org/software/bash/manual/html_node/Bash-Variables.html
export HISTFILESIZE=10000000    # history 10^7
export HISTSIZE=10000000        # history 10^7
export HISTTIMEFORMAT='%F %T '  # add timestamps to history
HISTCONTROL=ignoredups
shopt -s histappend cmdhist

# emacs daemon
# https://stackoverflow.com/a/5578718
export ALTERNATE_EDITOR=""

# golang
export GOPATH=$HOME/go
PATH=$GOPATH/bin:$PATH

# rustlang
PATH=.cargo/bin:$PATH

# Start ssh-agent if not running: https://unix.stackexchange.com/a/90869/162041
if [ -z "$SSH_AUTH_SOCK" ]; then
  eval $(ssh-agent -s)
  ssh-add
fi

# Standard aliases
source ~/.aliases

# GCP
# TODO: add auto-downloads for this:
source /usr/local/google-cloud-sdk/completion.bash.inc
source /usr/local/google-cloud-sdk/path.bash.inc

# fzf fuzzy searching
FZF_SH=~/.fzf.sh
test -f $FZF_SH || curl -sS -o $FZF_SH https://raw.githubusercontent.com/junegunn/fzf/master/shell/key-bindings.bash
source $FZF_SH
export FZF_DEFAULT_OPTS='--height 6 --reverse'

# Makefile completion: https://stackoverflow.com/a/36044470/2601179
function _makefile_targets {
    local curr_arg;
    local targets;

    # Find makefile targets available in the current directory
    targets=''
    if [[ -e "$(pwd)/Makefile" ]]; then
        targets=$( \
            grep -oE '^[a-zA-Z0-9_-]+:' Makefile \
            | sed 's/://' \
            | tr '\n' ' ' \
        )
    fi

    # Filter targets based on user input to the bash completion
    curr_arg=${COMP_WORDS[COMP_CWORD]}
    COMPREPLY=( $(compgen -W "${targets[@]}" -- $curr_arg ) );
}
complete -F _makefile_targets make

[ -f ~/.fzf.bash ] && source ~/.fzf.bash
