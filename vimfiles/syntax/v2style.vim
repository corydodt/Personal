" Vim syntax file
" 
" Author: Cory Dodt
" Remark: Highlights the 'styles' format used by Hermes v2 at Decipher

if exists("b:current_syntax")
  finish
endif

if version < 600
  synax clear
elseif exists("b:current_syntax")
  finish
endif

""
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
highlight link v2styleFlowArgument Constant

" top-level tokens
syn match v2styleComment "^#.*$"

syn match v2styleSelector  "^\*[a-zA-Z0-9_\./-]*:.*$"

syn match v2styleFlowBegin "^\s*@" nextgroup=v2styleKeyword

syn region v2styleVariable start="\${" end="}" oneline
syn region v2styleVariable start="\$(" end=")" oneline

syn match v2styleCall "^\[[^\]]*\]$"

syn match v2styleBlankLine "^$"


" contained in flow lines:
syn match v2styleKeyword "if\|else\|endif" contained nextgroup=v2styleFlowArgument
syn match v2styleFlowArgument ".*$" contained
