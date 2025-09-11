# Q pre block. Keep at the top of this file.
[[ -f "${HOME}/Library/Application Support/amazon-q/shell/zshrc.pre.zsh" ]] && builtin source "${HOME}/Library/Application Support/amazon-q/shell/zshrc.pre.zsh"
[ $(uname -s) = "Darwin" ] && export MACOS=1 && export UNIX=1
[ $(uname -s) = "Linux" ] && export LINUX=1 && export UNIX=1

source ~/dotfiles2/aliases.zsh
source ~/dotfiles2/zsh/dot_opts.zsh
source ~/dotfiles2/zsh/aliases.zsh
source $HOME/.bash_profile 
# source ~/dotfiles2/functions/amazon/check-auth.sh
alias grep='nocorrect grep'

alias ibrew="arch -x86_64 /usr/local/bin/brew"

alias HOST="bcd0745e2e97"


export FIRSTCHAR=${$(whoami | head -c 1):u}
export EMOJI='💾'
mkdir -p $HOME/.cache/zsh
HISTFILE=$HOME/.cache/zsh/history

if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then
    export SESSION_TYPE="remote"
else
    export SESSION_TYPE="local"
fi


# for file in ~/dotfiles2/functions/*; do
#     source "$file"
# done

# for file in ~/dotfiles2/functions/amazon*; do
#     source "$file"
# done

# for file in ~/dotfiles2/functions/amazon/crux/*; do
#     source "$file"
# done



# conditionally run kinit
if ! klist -s; then
    echo 'zshrc: Kerberos expired'
    kinit -f
else
    echo 'Valid Kerberos Found!!'
fi

# source "$HOME/dotfiles/mail_sync.sh"

check_cert() {
       # KEY_FILE="$HOME/.ssh/id_rsa-cert.pub"
       KEY_FILE="$HOME/.ssh/id_ecdsa-cert.pub"
       if [ -f $KEY_FILE ]; then
           CERT=$(ssh-keygen -Lf $KEY_FILE | awk 'NR==7{print $5}')
           DATE_NOW=$(date +"%Y-%m-%dT%T")

           if [[ "$DATE_NOW" > "$CERT" ]] ;
           then
                 echo "zshrc: your midway has expired..."
                 mwinit
           fi
       
       else
           echo "zhrc: your midway cannot be found..."
           mwinit
       fi
      # echo "zshrc: Starting davmail"
      # zsh "$HOME/dotfiles/mail_sync.sh" > /dev/null & 

   }
   
# check_cert #run automatically

check_cert2() {
    KEY_FILE="$HOME/.ssh/id_rsa.pub"
    CERT_FILE="$HOME/.ssh/id_rsa-cert.pub"
    if [ -f $KEY_FILE ]; then
        CERT=$(ssh-keygen -Lf $CERT_FILE | awk 'NR==7{print $5}')
        DATE_NOW=$(date +"%Y-%m-%dT%T")
        if [[ "$DATE_NOW" > "$CERT" ]] ;
        then
              echo "zshrc: your midway has expired..."
              mwinit -k $KEY_FILE
        fi
    else
        echo "zhrc: your midway cannot be found..."
        mwinit
    fi
}
#check_cert2 #run automatically

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# export NVM_AUTO_USE=true
export TERM=xterm-256color


if  [ -z "$HOSTNAME" ]; then
    if [ -z "$HOST" ]; then
        echo "ALERT: No hostname. things are gonna break!"
        export HOSTNAME="none"
    else
        export HOSTNAME=$HOST
    fi
fi


export BRAZIL_WORKSPACE_DEFAULT_LAYOUT=short
export ANT_ARGS='-logger org.apache.tools.ant.listener.AnsiColorLogger'



P10K_LOC="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
if [[ ! -d "${P10K_LOC}" ]]; then
      git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${P10K_LOC}"
fi
# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="powerlevel10k/powerlevel10k" # doesn't seem to do anything on devdsk but whatever

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"
source $ZSH/oh-my-zsh.sh

BRAZIL_PLATFORM_OVERRIDE=AL2_x86_64

# Setup PATH variable to include necessary utilities

export RDE__ALLOW_UNSUPPORTED_SYSTEM=1

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH
# If you need to have python@3.8 first in your PATH, run:
export PATH="/opt/homebrew/bin/zsh:$PATH"
export PATH="/usr/local/include:$PATH"
export LIBRARY_PATH="/usr/local/lib:$LIBRARY_PATH"
export PATH="/usr/local/bin:$PATH"
export PATH="/opt/homebrew/bin/:$PATH"
export PATH="$HOME/.toolbox/bin:$PATH"
export PATH=$HOME/.rodar/bin:$PATH
export PATH="/usr/local/opt/ruby/bin:$PATH"
export PATH="$HOME/.rbenv/bin:$PATH"
export PATH="$HOME/.rodar/bin:$PATH"
# export PATH="$PATH:/Users/mcdotrev/Library/Application Support/JetBrains/Toolbox/scripts"

# if [[ -r "/apollo/env/envImprovement/bin" ]]; then
#   path+="/apollo/env/envImprovement/bin"
# fi

#export JAVA_HOME="/Library/Java/JavaVirtualMachines/amazon-corretto-11.jdk/Contents/Home"

source /opt/homebrew/opt/chruby/share/chruby/auto.sh

# source $HOME/dotfiles2/aliases.zsh
# source $HOME/dotfiles2/functions/amazon/amzn-dev-plugin.zsh
#export JAVA_HOME=$(/usr/libexec/java_home)
export JAVA_HOME=/Library/Java/JavaVirtualMachines/amazon-corretto-8.jdk/Contents/Home

fpath=(
    $HOME/dotfiles2/amazon/cr
    $fpath
)

# source $HOME/dotfiles/functions/vpn-onetouch

# source $HOME/dotfiles2/amazon/vpn-connect.sh

# unalias mwinit

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

#------------------------------------------------------------------
# History
#------------------------------------------------------------------
# setopt EXTENDED_HISTORY        # store time in history
# setopt HIST_EXPIRE_DUPS_FIRST  # unique events are more usefull to me
# setopt HIST_VERIFY             # Make those history commands nice
# setopt INC_APPEND_HISTORY      # immediatly insert history into history file
# HISTSIZE=999999
# SAVEHIST=999999
# HISTFILE=~/.histfile
# setopt histignoredups          # ignore duplicates of the previous event

# ######## Java ########
# export JAVA_HOME=`/usr/libexec/java_home` #-v 1.8`
export JAVA_TOOLS_OPTIONS="-Dlog4j2.formatMsgNoLookups=true"

export PATH="/Library/Java/JavaVirtualMachines/amazon-corretto-8.jdk/Contents/Home/bin:$PATH"

# for f in EnvImprovement AmazonAwsCli NodeJS; do
#     if [[ -d /apollo/env/$f ]]; then
#         export PATH=$PATH:/apollo/env/$f/bin
#     fi
# done

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
    mise
    bundler
    colorize
    colored-man-pages
    emoji
    tmux
    aws
    vscode
    python
    gh
    git
    git-prompt
    git-extra-commands
    gitignore
    git-extras
    command-not-found
    copyfile
    profiles
    pre-commit
    alias-finder
    #dotenv
    #macos
    zsh-autosuggestions
    zsh-syntax-highlighting
    auto-color-ls
    fancy-ctrl-z
    # zsh-auto-notify
    you-should-use
)

export ZSH_DISABLE_COMPFIX=true
source $ZSH/oh-my-zsh.sh

###############################################################################
#                                Zellij
###############################################################################
if [[ -z "$ZELLIJ" &&
  -z "$EMACS" &&
  -z "$VIM" &&
  -z "$INSIDE_EMACS" &&
  -n "$SSH_TTY" &&
  "$TERM_PROGRAM" != "vscode" &&
  "$TERMINAL_EMULATOR" != "JetBrains-JediTerm" ]]; then
  zellij attach -c
fi

# Set notification expiry to 10 mins
export AUTO_NOTIFY_EXPIRE_TIME=1000000

# Add docker to list of ignored commands
AUTO_NOTIFY_IGNORE+=("docker")

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# Homebrew on Apple Silicon
path=('/opt/homebrew/bin' $path)
export PATH


# You may need to manually set your language environment
# export LANG=en_US.UTF-8

alias python='python3'
alias vpn-onetouch='~/dotfiles2/functions/vpn-onetouch'
alias e='emacs'
alias bb='brazil-build'
alias bba='brazil-build apollo-pkg'
alias bball='brc --allPackages'
alias bbb='brc --allPackages brazil-build'
alias bbr='brc brazil-build'
alias bbra='bbr apollo-pkg'
alias brc='brazil-recursive-cmd'
alias bre='brazil-runtime-exec'
alias bws='brazil ws'
alias bwscreate='bws create -n'
alias bwsuse='bws use --gitMode -p'
## alias sam='brazil-build-tool-exec sam'
alias vi='vim'
alias prod_ada="ada credentials update --account 686352220635 --provider conduit --role IibsAdminAccess-DO-NOT-DELETE"
alias beta_ada="ada credentials update --account 126408713107 --provider conduit --role IibsAdminAccess-DO-NOT-DELETE"
alias cdk-pipeline-doctor=/Volumes/workplace/CDKPipelineDoctor/env/CDKPipelineDoctor-1.0-CDKPipelineDoctor-development/bin/darwin_arm64/cdk-pipeline-doctor

alias beta_caam="ada credentials update --account 933202354322 --provider conduit --role IibsAdminAccess-DO-NOT-DELETE"

alias mcdotrev_ada="ada credentials update --account 339756542683 --provider conduit --role IibsAdminAccess-DO-NOT-DELETE"
alias DESKTOP="dev-dsk-mcdotrev-2a-c9cc07fe.us-west-2.amazon.com"

# CLOUD_DESK_OLD_SSH is old??? (Confirmed)
alias CLOUD_DESK_OLD_SSH="ssh dev-dsk-mcdotrev-2a-c9cc07fe.us-west-2.amazon.com"

alias dev='ssh mcdotrev.aka.corp.amazon.com'

alias sshodin="ssh -L2009:localhost:2009 mcdotrev.aka.corp.amazon.com -f -N"
alias zelliz='zellij options --no-pane-frames --attach-to-session true'



alias brow='arch --x86_64 /usr/local/Homebrew/bin/brew'

# export DOCKER_HOST=tcp://127.0.0.1:4243
# export DOCKER_HOST=unix:///var/run/docker.sock
# I am uncertain why this fixes docker. but it does.
unset DOCKER_HOST
unset DOCKER_TLS_VERIFY

# alias authWork="/usr/bin/env expect -f "/Users/mcdotrev/dotfiles2/amazon/vpn-connect.sh""

# alias authWork2="/usr/bin/env expect -f "/Users/mcdotrev/dotfiles2/amazon/vpn-onetouch.sh""

alias git-stats-to-csv="sh /Users/mcdotrev/dotfiles2/functions/git/git-stats-to-csv.sh"
alias rtx='mise'

function when_mw_expire() {

    MW_EXPIRE_PROMPT="EXPIRED 00:00:00"

    if [[ -f "${HOME}/.midway/cookie" ]]
    then

        MW_EXPIRES_TIMESTAMP="$(( $(grep HttpOnly_midway-auth.amazon.com ~/.midway/cookie | cut -d $'\t' -f 5) - $(date +%s) ))"

        if [[ $MW_EXPIRES_TIMESTAMP -gt 0 ]]
        then

            HRS="$(printf "%02d\n" $(($MW_EXPIRES_TIMESTAMP/3600)))"
            MIN="$(printf "%02d\n" $((($MW_EXPIRES_TIMESTAMP/60) % 60)))"
            SEC="$(printf "%02d\n" $(($MW_EXPIRES_TIMESTAMP % 60)))"

            MW_EXPIRE_PROMPT="EXPIRES IN $HRS:$MIN:$SEC"

        fi
    fi

    echo $MW_EXPIRE_PROMPT
}

# alias yubi='eval $(ssh-agent) && mwinit -s  && ssh-add -D && ssh-add && ssh midway-ssh-verification-global-corp.aka.amazon.com echo "-- MIDWAY IS WORKING TODAY --"  '

gitconew ()
{
  git stash && git checkout mainline && git checkout -b $1 && git stash apply
}

# Add completions from Homebrew packages
if [[ "$(uname)" == 'Darwin' ]]; then
	FPATH="$(brew --prefix)/share/zsh/site-functions:$FPATH"
fi


# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/dotfiles2/.p10k.zsh ]] || source ~/dotfiles2/.p10k.zsh
#[[ ! -f ~/dotfiles2/zsh/.p10k.rtx.zsh ]] || source ~/dotfiles2/zsh/.p10k.rtx.zsh


# export NVM_DIR="/Users/mcdotrev/.nvm"
# [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm


eval "$(rbenv init -)"
export PATH="~/.rbenv/shims:$PATH"

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

if type brew &>/dev/null; then
    FPATH="$(brew --prefix)/share/zsh/site-functions:$FPATH"
    FPATH="$(brew --prefix)/share/zsh-completions:$FPATH"

    autoload -Uz compinit && compinit -i
fi

alias python=/usr/bin/python3
export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

# export VOLTA_HOME="$HOME/.volta"
# export PATH="$VOLTA_HOME/bin:$PATH"

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/Users/mcdotrev/anaconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/Users/mcdotrev/anaconda3/etc/profile.d/conda.sh" ]; then
        . "/Users/mcdotrev/anaconda3/etc/profile.d/conda.sh"
    else
        export PATH="/Users/mcdotrev/anaconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<


autoload -U +X bashcompinit && bashcompinit
complete -o nospace -C /opt/homebrew/bin/terraform terraform

# pnpm
export PNPM_HOME="/Users/mcdotrev/.pnpm/store"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end
export PATH="/Applications/Fortify/Fortify_SCA_23.1.0/bin:$PATH"

eval "$(/opt/homebrew/bin/brew shellenv)"
eval "$(direnv hook zsh)"
# eval "$(rtx activate zsh)" 
# eval "$(rtx env)"
# Set up rtx for runtime management
rtx_loc="${HOME}/.local/share/rtx/bin/rtx"
[ -f "${rtx_loc}" ] && eval "$(${rtx_loc} activate -s zsh)"
# Set up rtx for runtime management
eval "$(mise activate zsh)"
eval "$(rtx activate zsh)" 

# Added by serverless binary installer
export PATH="$HOME/.serverless/bin:$PATH"
source /Users/mcdotrev/.brazil_completion/zsh_completion
PATH=~/.console-ninja/.bin:$PATH

export PATH=~/usr/bin:/bin:/usr/sbin:/sbin:$PATH

# Q post block. Keep at the bottom of this file.
[[ -f "${HOME}/Library/Application Support/amazon-q/shell/zshrc.post.zsh" ]] && builtin source "${HOME}/Library/Application Support/amazon-q/shell/zshrc.post.zsh"
