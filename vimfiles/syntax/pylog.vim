" Vim syntax file
" 
" Author: Cory Dodt
" Remark: Highlights python tracebacks within random text (for example, logs)

if exists("b:current_syntax")
  finish
endif

if version < 600
  syntax clear
elseif exists("b:current_syntax")
  finish
endif

""
highlight clear plFilename
highlight clear plLineNumber
highlight clear plInFunc
highlight clear plCodeLine 
highlight clear plException
highlight link plFilename Directory
highlight link plLineNumber LineNr
highlight link plInFunc Identifier
highlight link plCodeLine PreProc
highlight link plException ErrorMsg

syntax match plFilename /  File "[^"]*"/hs=s+8,he=e-1 nextgroup=plLineNumber
syntax match plLineNumber /, line \d\d*/hs=s+7 contained nextgroup=plInFunc
syntax match plInFunc /, in .*/hs=s+5 contained nextgroup=plCodeLine skipnl 
syntax match plCodeLine /\t    .*$/ contained nextgroup=plException skipnl
syntax match plException /\t\S*: .*$/hs=s+1 contained
