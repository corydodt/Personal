for f in ~/.zsh/*; do source $f; done

export PYTHONHOME=C:\\python23
export PYTHONSTARTUP="`cygpath -wa ~/svn/cory/pythonstartup.py`"\

alias echo='echo -E' # disable backslash-escapes; -e will still turn them on
alias ls='ls -F --color'
alias cs='cygstart'
alias open='cygstart'
alias cpwd='cygpath -ma .'
alias newcyg='python "`cygpath -ma ~/svn/cory/newcyg.py`"'
alias -g NS='| grep -v \.svn'
alias -g TR='| tr : \\n'
alias -g DU='| dos2unix'
alias -g DUG='| dos2unix | gvim -'
alias pwd='cygpath -ma .'
p () {
        nohup "c:/program files/putty/putty" -load "$@" > /dev/null 2>& 1 &
}
export p


CLPROFILE='"$TWISTD" -o --profile c:/temp/profile.prof -y "$CYDIR"/debug.tac'


if [ "$TERM" = "cygwin" -o "$TERM" = "xterm" ]; then
    precmd() {
      echo -ne "\033]0;${USER}@${HOST}: $(print -P %1~)\007"
    }
    preexec() {
      echo -ne "\033]0;$1\007"
    }
fi

PATH=~/svn/cory:~/bin:$PATH
DISPLAY=localhost:0.0   # for X11 forwarding over ssh
CVS_RSH=ssh
VISUAL=gvim
SVNURI=svn+ssh://turing.cyberhigh.org/
SVN_EDITOR=notepad


export PATH CVSROOT CVS_RSH VISUAL SVN_EDITOR DISPLAY

HISTFILE=~/.zsh_history
SAVEHIST=3456
HISTSIZE=3456
setopt -oSHARE_HISTORY

cd "${START_DIR:-}"

# this should be last, so PATH and ~ work correctly together
# export HOME="`cygpath -ma \"$HOME\"`"
export MAGICK_CODER_MODULE_PATH='C:\Program Files\ImageMagick-6.1.6-Q16\modules\coders'
export MAGICK_FILTER_MODULE_PATH='C:\Program Files\ImageMagick-6.1.6-Q16\modules\filters'


# lotsa variables for CDS debugging
export CDS_HTMLDIR="$USERPROFILE/svn/cds/code/Cyberhigh/html"
export CDS_PFDIR="$PROGRAMFILES/cyberhigh_service"
