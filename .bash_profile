. ~/.bash/*

PYPEDIR="C:/Program Files/pype"
export PYPEDIR

alias python2.3='c:/python23/python.exe -i'
alias ls='ls -F --color'
alias cs='cygstart'
alias splitpath='echo $PATH | python -c '"'"'import sys; print "\n".join(sys.stdin.read().split(":"))'"'"''
alias python='python -i'
alias pypath='eval "export PYTHONPATH=\$PYTHONPATH\;\$(cygpath -ma .)"'   

cdslogs() { cd /c/Documents\ and\ Settings/cory/Local\ Settings/Temp; command ls -tr1 ~*.log | tail -2 | xargs gvim -o; }


closefixer() {
exit
}
trap closefixer SIGHUP

doubleslash() {
    command python -c '
import sys
print " ".join(sys.argv[1:]).replace("\\", "\\\\").replace(" ", "\\ ")
' $1
}


cypy()  
{ 
    if [ "$#" -eq 0 ]; then
        python
    else
        script=$1
        shift 
        python "`cygpath -ma \"$script\"`" "$@"
    fi
} 

cypy2.3()  
{ 
    if [ "$#" -eq 0 ]; then
        python2.3
    else
        script=$1
        shift 
        python2.3 "`cygpath -ma \"$script\"`" "$@"
    fi
} 

pathtrans() {
    while [ $# -gt 0 ]; do
        echo -n \"`cygpath -ma -- "$1"`\"
        shift
    done
}    

xe() {
    bash nohup bash -c "command winclient $(pathtrans "$@") &" > /dev/null 2>&1
}

gvim() {
    bash nohup bash -c "command gvim $(pathtrans "$@") &" > /dev/null 2>&1
}

pype() {
    bash nohup bash -c "cd \"$PYPEDIR\" && command pype $(pathtrans "$@") &" > /dev/null 2>&1
}

if [ "$TERM" = "cygwin" -o "$TERM" = "xterm" ]; then
  PROMPT_COMMAND='echo -ne "\033]0;${USER}@${HOSTNAME}: $(basename "${PWD}")\007"'
fi

PATH=~/bin:/c/vim/vim61:$(cygpath "$PYPEDIR"):$PATH
if echo $PATH | grep -qv THIS_IS_THE_USERPATH ; then
    PATH="$PATH:THIS_IS_THE_USERPATH:/c/Program Files/XEmacs/XEmacs-21.4.13/i586-pc-win32/:/c/program files/aap:/c/python22:/c/vim/vim62:/c/Program Files/Common Files/GTK/2.0/bin:/c/python22/dlls:/c/Program Files/Common Files/GTK/2.0/lib"
fi

CVS_RSH=ssh
VISUAL=gvim
SVNURI=svn+ssh://turing/

acquire_python_scripts() {
    # convert everything in a dir into a python command line
    for full in "$1"/*; do
        short=$(basename "$full")
        eval $(echo alias $short=\'cypy \"$full\"\')
        eval $(echo alias ${short}2.3=\'cypy2.3 \"$full\"\')
    done
}

acquire_python_scripts ~/scripts


export PATH CVSROOT CVS_RSH VISUAL
export -f cypy
