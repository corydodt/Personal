. /etc/profile

zsh_locals=($(echo ~/.zsh.d/*))
for source in ${zsh_locals[@]}; do
    source $source
done

myColor=red # may also be "yellow bold" for example
# colors are: white red yellow green magenta blue black cyan
#
SCREEN_HOST=`hostname`

export PATH=$PATH:~/bin

# If running interactively, then:
if [ "$PS1" ]; then
    # enable color support of ls and also add handy aliases
    if [ ! -r ~/.dircolors ]; then
        dircolors -p | sed '/^DIR /d' > ~/.dircolors
        echo "DIR 01;36" >> ~/.dircolors
    fi
    if which dircolors > /dev/null 2>&1 && ! alias dircolors > /dev/null 2>&1; then
        eval `dircolors -b ~/.dircolors`
    fi
    
    alias ls > /dev/null 2>&1 || alias ls='ls -F'
    alias vim='vim -X'
    alias pvim='(tf=`tempfile -pvim-r_ -d/tmp`; cat > $tf && command gvim --remote-tab-silent-wait $tf; rm -f $tf) >/dev/null 2>&1 &'
    alias gvim='echo \*\* no gvim 1>&2 && false'

    # If this is an xterm set the title to user@host:dir
    case $TERM in
      cygwin*|xterm*)
        precmd() {
            myPrompt $myColor
        }
        ;;
      screen*)
         :
         precmd() {
             myPrompt $myColor
             echo -ne "\033]83;title zsh\007"
         }

         preexec() {
             echo -ne "\033]83;title '${2[0,25]}'\007"
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
        which screenpick && exec screenpick
    fi

    if [ $(id -u) -ne 0 ] && which keychain >/dev/null 2>&1; then
        # eval `keychain --eval ~/.ssh/id_dsa 70221D07` # don't use a gpg key that often
        # eval `keychain --nogui --eval ~/.ssh/id_dsa`
    fi
fi


umask 002

DEBEMAIL=launchpad@spam.goonmill.org
DEBFULLNAME="Cory Dodt"
export DEBEMAIL DEBFULLNAME

HISTFILE=~/.zsh_history
SAVEHIST=3456
HISTSIZE=34556

export EDITOR=vim

setopt -oSHARE_HISTORY
