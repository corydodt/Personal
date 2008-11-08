" Vim syntax file
" 
" Author: Cory Dodt
" Remark: Highlights the 'styles' format used by Hermes v2 at Decipher

if exists("b:current_syntax")
  finish
endif

if version < 600
  syntax clear
elseif exists("b:current_syntax")
  finish
endif

highlight clear v2styleComment
highlight clear v2styleSelector
highlight clear v2styleCall
highlight clear v2styleVariable
highlight clear v2styleFlowBegin
highlight clear v2styleKeyword
highlight clear v2styleBlankLine

highlight link v2styleComment Comment
highlight link v2styleSelector Typedef
highlight link v2styleCall Macro
highlight link v2styleKeyword Keyword
highlight link v2styleFlowBegin Special
highlight link v2styleVariable Identifier
highlight link v2styleFlowKeyword Constant

" we define it here so that included files can test for it
if !exists("main_syntax")
  let main_syntax='v2_style'
endif

if version < 600
  so <sfile>:p:h/html.vim
else
  runtime! syntax/html.vim
endif
unlet b:current_syntax
syn case match

syn include @v2Python syntax/python.vim

syn match v2styleComment "#.*$"
syn match v2styleSelector  "^\*[a-zA-Z0-9_\./-]*:"
syn match v2styleCall "^\[[^\]]*\]$"
syn match v2styleBlankLine "^$"

syn region v2styleFlowKeyword start="^\s*@[if|else|endif|for|end]" end="$" contains=@v2Python

syn region v2styleVariable contained start="\${" end="}" contained contains=@v2Python
syn region v2styleVariable contained start="\$(" end=")" contained contains=@v2Python

syn cluster htmlPreproc add=v2styleVariable
"syn cluster v2styleVariable add=

let b:current_syntax = "v2_style"

if main_syntax == 'v2_style'
  unlet main_syntax
endif

