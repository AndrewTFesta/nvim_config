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
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

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
#force_color_prompt=yes

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
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
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
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

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

# env vars
export HF_TOKEN=...
export HF_HOME="$HOME/models/huggingface"
export OMP_NUM_THREADS=12

# personal aliases
alias py='python3'
alias python='python3'
alias nsmi='nvidia-smi'
alias watch-nsmi='watch -n 0.1 nvidia-smi'

# funky town
# functions for some extra *flavor*
_set_env_var() {
  local var_name="$1"
  shift
  local potential_paths=("$@")
  local found=false
  export "$var_name="

  for path in "${potential_paths[@]}"; do
    if [ -f "$path" ]; then
      export "$var_name=$path"
      echo "✅ Set $var_name: $path"
      found=true
      break
    fi
  done

  if [ "$found" = false ]; then
    echo "⚠️ Warning: File not found for $var_name. Variable not set."
    echo "   Checked the following locations:"
    printf "   - %s\n" "${potential_paths[@]}"
  fi
}

act-env() {
  # Check if a project name was provided
  if [ -z "$1" ]; then
    echo "Error: No project name supplied."
    echo "Usage: act-env <project_name>"
    return 1
  fi

  local project_name="$1"

  local venv_path="$HOME/.virtualenvs/${project_name}/bin/activate"
  if [ -f "$venv_path" ]; then
    source "$venv_path"
    echo "✅ Activated virtual environment for '${project_name}'."
  else
    echo "⚠️ Warning: Virtual environment not found at '$venv_path'."
    return 1
  fi

  local env_path="$HOME/projects/${project_name}/envs/nonprod.env"
  if [ -f "$env_path" ]; then
    set -a
    source "$env_path"
    set +a
    echo "✅ Set environment variables: $env_path"
  else
    echo "⚠️ Warning: Environment variables not found"
    echo "   (Expected at '$env_path')"
  fi

  local creds_paths=(
    "$HOME/projects/${project_name}/creds/onlogic-credentials.json"
    "$HOME/projects/${project_name}/creds/onlogic-ai-nonprod.json"
    "$HOME/creds/${project_name}/onlogic-ai-nonprod.json"
  )
  _set_env_var "GOOGLE_APPLICATION_CREDENTIALS" "${creds_paths[@]}"

  export TORCH_EXTENSIONS_DIR=~/${project_name}-torch-extensions
}

_act_env_completion() {
  local cur
  COMPREPLY=()
  cur="${COMP_WORDS[COMP_CWORD]}"

  # Get a list of directories in ~/.virtualenvs/
  local virtualenvs=$(find ~/.virtualenvs/ -maxdepth 1 -mindepth 1 -type d -printf "%f\n")

  # Filter the list based on what's already typed
  COMPREPLY=( $(compgen -W "${virtualenvs}" -- "${cur}") )
}

complete -F _act_env_completion act-env

export GEMINI_API_KEY="..."

export PATH="$PATH:$HOME/.local/bin"
export PATH=/usr/local/cuda-12.6/bin${PATH:+:${PATH}}

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
