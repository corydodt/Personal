source ~/.zsh/myPrompt
source ~/.zsh/`uname`

myColor="magenta bold" # may also be "yellow bold" for example
# colors are: white red yellow green magenta blue black cyan

# If running interactively, then:
if [ "$PS1" ]; then
    # enable color support of ls and also add handy aliases
    if [ ! -r ~/.dircolors ]; then
        dircolors -p | sed '/^DIR /d' > ~/.dircolors
        echo "DIR 01;36" >> ~/.dircolors
    fi
    eval `dircolors -b ~/.dircolors`

    alias -g su='su -m'


    # If this is an xterm set the title to user@host:dir
    case $TERM in
      cygwin*|xterm*)
        precmd() {
            echo -ne "\033]0;${USER}@${HOST}: ${PWD}\007"
            myPrompt $myColor
        }
        ;;
      screen*)
        precmd() {
            echo -ne "\033]0;${USER}@${HOST}: ${PWD} ${WINDOW}\007"
            myPrompt $myColor
        }
        ;;
      *)
        ;;
    esac
    #if [ -n "$SSH_CLIENT" -a -z "$DISPLAY" ]; then
    #  export DISPLAY=`echo $SSH_CLIENT | cut -d\  -f 1`:0
    #fi
    #if [ -e ~/display_var ]; then
    #  export DISPLAY=`cat ~/display_var`
    #fi


    if ! echo $STY | cut -d. -f1 | xargs ps -p 2> /dev/null | grep -i screen > /dev/null 2>&1; then
        exec screen -RR
    fi

    if [ $(id -u) -ne 0 ] && which keychain >/dev/null 2>&1; then
        # eval `keychain --eval ~/.ssh/id_dsa 70221D07` # don't use a gpg key that often
        eval `keychain --eval ~/.ssh/id_dsa`
    fi
fi

umask 002

## DEBEMAIL=corydodt@twistedmatrix.com
## DEBFULLNAME="Cory Dodt"
## export DEBEMAIL

export PATH=$PATH:~/bin:~/wc/Twisted/bin:~/wc/Divmod/Axiom/bin

HISTFILE=~/.zsh_history
SAVEHIST=3456
HISTSIZE=34556
setopt -oSHARE_HISTORY
