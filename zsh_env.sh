#!/bin/zsh

DEVELOPMENT_PATH=${DEVELOPMENT_PATH} || "/Users/rhys/Workspace"
SCRIPT=$(realpath $0)
THIS_SCRIPTS_PATH=`dirname $SCRIPT`
COMMANDS_PATH="$THIS_SCRIPTS_PATH/commands"

# Add commonly used folders to $PATH
if [[ $PATH != *"$COMMANDS_PATH"* ]]; then
  export PATH="$PATH:$COMMANDS_PATH"
fi

# Ensure in correct brew context
if [[ $(arch) == "arm64" ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
else
  eval "$(/usr/local/bin/brew shellenv)"
fi

# NVM loading
export NVM_DIR="$HOME/.nvm"
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"  # This loads nvm
[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion

# zsh auto completions
if type brew &>/dev/null; then
  FPATH=$(brew --prefix)/share/zsh-completions:$FPATH

  autoload -Uz compinit
  compinit
fi

# zsh theme
source /opt/homebrew/opt/powerlevel10k/powerlevel10k.zsh-theme

export PATH="/opt/homebrew/opt/libpq/bin:$PATH"

# Specify default editor. Possible values: vim, nano, ed etc.
export EDITOR=nano
export QUICK_FILE_EDITOR=code

# File search functions
function f() { find . -iname "*$1*" ${@:2} }
function r() { grep "$1" ${@:2} -R . }

# Create a folder and move into it in one command
function mkcd() { mkdir -p "$@" && cd "$_"; }

# Create file and open in the set quick editor
function touch-open { touch "$@" && $QUICK_FILE_EDITOR "$_"; }

# Search history
function search-history { history | grep "$@" }

# Amend last git commit
function git-amend { git commit -m "$@" --amend }

# Kubernetes follow pods logs with matching label tag arg
function ku-follow-logs {
  kubectl logs -l $@ -f
}

function rspec-gmt {
  sudo systemsetup -settimezone Atlantic/Reykjavik
  rspec "$@"
  sudo systemsetup -settimezone Australia/Brisbane
}

# Kubernetes quick context switch
# function ku-change-context {
#   CONTEXT=${1:-docker-desktop}
#   NAMESPACE=${2:-default}
#   echo "Setting up context..."
#   kubectl config set-context $CONTEXT --namespace=$NAMESPACE
#   echo "Switching to context..."
#   kubectl config use-context $CONTEXT
#   echo "Now using following context and namepace..."
#   kubectl config current-context
#   SET_NAMESPACE="$(kubectl config view --minify --output 'jsonpath={..namespace}')"
#   echo $SET_NAMESPACE
#
#   if [[ $SET_NAMESPACE == 'production' ]]; then
#     echo "==============WARNING=============="
#     echo "============PRODUCTION============="
#     echo "=============NAMESPACE============="
#   fi
# }

# Dir name as tab title
if [ $ITERM_SESSION_ID ]; then
  export PROMPT_COMMAND='echo -ne "\033];${PWD##*/}\007"; ':"$PROMPT_COMMAND";
fi

# Command aliases
alias g='git'
alias c='clear'
alias ku="kubectl"
alias ku-watch-pods="kubectl get pods -w"
# alias ku-context-local="ku-change-context docker-desktop"
alias sandbox="rails c --sandbox"
alias ll="ls -lhA"

# File aliases
alias zsh-env-file="$QUICK_FILE_EDITOR ~/Development/terminal/zsh_env.sh"
alias survival-guide="$QUICK_FILE_EDITOR ~/Documents/survival-guide.md"

# Generic useful
alias tail-puma="tail -f ~/Library/Logs/puma-dev.log"

# Yaml lint ignore line length
alias yamllint-relaxed='yamllint -d "{extends: relaxed, rules: {line-length: disable}}"'

# Ensure load correct node version
autoload -U add-zsh-hook
load-nvmrc() {
  local node_version="$(nvm version)"
  local nvmrc_path="$(nvm_find_nvmrc)"

  if [ -n "$nvmrc_path" ]; then
    local nvmrc_node_version=$(nvm version "$(cat "${nvmrc_path}")")

    if [ "$nvmrc_node_version" = "N/A" ]; then
      nvm install
    elif [ "$nvmrc_node_version" != "$node_version" ]; then
      nvm use
    fi
  elif [ "$node_version" != "$(nvm version default)" ]; then
    echo "Reverting to nvm default version"
    nvm use default
  fi
}
add-zsh-hook chpwd load-nvmrc
load-nvmrc

plugins=( 
    # other plugins...
    zsh-autosuggestions
)

setopt autocd

export CLICOLOR=1

source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Workaround for starting blank line when opening new terminal tab
clear

