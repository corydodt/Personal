" Vim color file
" Maintainer:   Yuheng Xie <elephant@linux.net.cn>
" Last Change:  2005 Apr 6

" This color scheme uses a black background.

" First remove all existing highlighting.
set background=dark
highlight clear
if exists("syntax_on")
	syntax reset
endif

let colors_name = "greener"

hi Cursor                         guifg=Black      guibg=#FFBF00
hi Normal      ctermfg=Gray       guifg=#B8B8B0    guibg=Black        ctermbg=Black
hi Visual                         guifg=Black      guibg=#C4C090      gui=NONE

hi Comment     ctermfg=DarkGreen  guifg=DarkGreen
hi Constant    ctermfg=Red        guifg=#F86677
hi Special     ctermfg=DarkRed    guifg=#CC6000
hi Identifier  ctermfg=Cyan       guifg=Cyan
hi Statement   ctermfg=Yellow     guifg=Yellow                        gui=NONE
hi PreProc     ctermfg=Green      guifg=Green
hi Type        ctermfg=White      guifg=White                         gui=NONE
hi Ignore      ctermfg=DarkGrey   guifg=#22201C

hi FoldColumn                     guifg=#C4C0B0    guibg=#42403C
hi Folded                         guifg=LightCyan  guibg=#22201C

hi DiffAdd                        guifg=White      guibg=DarkBlue
hi DiffDelete                     guifg=Black      guibg=LightCyan
hi DiffText                       guifg=White      guibg=DarkRed      gui=NONE
hi DiffChange                     guifg=Black      guibg=LightYellow

hi TabLine term=underline cterm=underline ctermfg=7 ctermbg=0 gui=underline guibg=DarkGrey
hi TabLineSel term=bold cterm=bold gui=bold 
" vim: ts=2 sw=2

