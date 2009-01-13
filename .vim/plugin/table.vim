" Script: table.vim
" Version: 0.1 
"
" Maintainer: Usman Latif Email: latif@techuser.net 
" Webpage: http://www.techuser.net
"
" Description:
" This script defines maps for easier editing and alignmnet of tables.
" For usage and installation instructions consult the documentation
" files that came with this script. In case you are missing the 
" documentation files, download a complete distribution of the files
" from http://www.techuser.net/files


map <silent> <Leader><Leader>tt :call TableToggle()<CR>
map <silent> <Leader><Leader>th :call TableHeading()<CR>
map <silent> <Leader><Leader>ta :call TableAlign()<CR>

let s:tablemode = 0
let s:heading = ''
let s:fieldsep = ' \{2,}'

" Function: TableHeading
" Args: None
"
" use current line as the heading line of the table
" current line should be non-empty
 
func! TableHeading() 
    " get heading line and store it in a script variable
    let s:heading = TrimWS(ExpandTabs(getline(".")))

    if !ValidHeading(s:heading)
        return 
    endif

    " map keys to invoke table navigation functions
    call EnableMaps() 

    let s:tablemode = 1
endfunc

" Function: ValidHeading
" Args: None
" Return: boolean
"
" returns 1 if heading is valid, i.e., non-whitespace
" returns 0 otherwise 

func! ValidHeading(heading)
    " heading line empty ==> invalid heading
    let l:str = a:heading
    if strlen(str) == matchend(str,'^ *')
        return 0
    endif
    return 1
endfunc

" Function: TableToggle
" Args: None
"
" Toggle Table Mode
" Enable/Disable maps for tablemode keys

func! TableToggle()

    if !ValidHeading(s:heading)
        return 
    endif

    " enable/disable maps
    if s:tablemode
        call DisableMaps()
    else
        call EnableMaps()
    endif

    " toggle tablemode
    let s:tablemode = !s:tablemode
endfunc

" Function: Enable Maps
" Args: None
"
" Enable maps for tablemode keys

func! EnableMaps()
    nnoremap <silent> <Tab>    :call NextField(0)<CR>
    inoremap <silent> <Tab>    <C-O>:call NextField(1)<CR>
    nnoremap <silent> <S-Tab>  :call PrevField()<CR>
    inoremap <silent> <S-Tab>  <C-O>:call PrevField()<CR>
endfunc

" Function: Disable Maps
" Args: None
"
" Disable maps for tablemode keys

func! DisableMaps()
    nunmap <Tab>
    iunmap <Tab>
    nunmap <S-Tab>
    iunmap <S-Tab>
endfunc


" Function: TableAlign
" Args: None
" Description: align the fields of the row with the fields of the heading

func! TableAlign()
    if !s:tablemode
        return
    endif
    let temp = ""
    let linetext = TrimWS(ExpandTabs(getline('.')))

    let nfhead = LenWS(s:heading,0) + 1
    let nftext = LenWS(linetext,0) + 1
    let error = 0

    while 1
        " flag error if current field too big to fit
        if (nfhead - strlen(temp))  <= 1 && strlen(temp) != 0 
            let error = 1 
            break
        endif

        " pad to next field of heading and add contents of the next text
        " field after that
        let temp = temp . Replicate(' ',nfhead - strlen(temp)-1) . Gettext(linetext,nftext-1)

        let nfhead = NextFieldPos(s:heading,s:fieldsep,nfhead)
        let nftext = NextFieldPos(linetext,s:fieldsep,nftext)

        " If no next field exit loop
        if nfhead == 0 || nftext == 0
            " flag error if row to be aligned has more fields than heading
            if nftext != 0 
                let error = 1
            endif
            break
        endif
    endwhile
    if !error && temp != linetext
        call setline('.',temp)
    endif
endfunc


" Function: PrevField
" Args: None
"
" position the cursor at the start of the prev field position 

func! PrevField()
    let nextpos = 1
    let lastpos = 1
    let pos = col('.')
    let linenum = line('.')
    let fstfield = LenWS(s:heading,0) + 1

    while nextpos != 0
        let lastpos = nextpos
        let nextpos = NextFieldPos(s:heading,s:fieldsep,nextpos) 
        if pos > lastpos && (pos <= nextpos || nextpos == 0)
            let pos = lastpos
        endif
    endwhile

    if pos <= fstfield && linenum != 1 && col('.') <= fstfield
        let linenum = linenum - 1
        let pos = lastpos
    endif

    call cursor(linenum,pos)
endfunc


" Function: NextField
" Args: curmode
"
" position the cursor at the start of next field position
" pad the current line with spaces if needed when in insertion
" or replace mode

func! NextField(curmode)
    let l:pos = Max(col('.') - 2,0)
    let l:startnext = NextFieldPos(s:heading,s:fieldsep,pos)
    let l:linenum = line('.')

    "If no nextfield on line goto next line
    "append an empty line if in insert/replace mode
    if startnext == 0
        if a:curmode 
            call append(linenum,'')
        endif
        let linenum = linenum+1
        let startnext = LenWS(s:heading,0) + 1
    endif

    let l:linetext = ExpandTabs(getline(linenum))
    let l:linelen = strlen(linetext)

    "If padding required
    if linelen < startnext
        let linetext = linetext . Replicate(' ',startnext-linelen+1)
        call setline(linenum,linetext)
    endif

    if linenum > line('$')
        let linenum = line('$')
        let startnext = col('.')
    endif
    call cursor(linenum,startnext)
endfunc


" Function: NextFieldPos
" Args: string,pattern,startposition
"
" returns the position of the end of field in which pos
" is contained

func! NextFieldPos(str,pat,pos)
    return matchend(a:str,a:pat,a:pos) + 1
endfunc


" Function: Gettext
" Args: str, pos 
" Description: Extract the text contents of a field from the 
" string str, starting at position pos

func! Gettext(str,pos)
    let endpos = match(a:str,s:fieldsep,a:pos)
    if endpos == -1
        let endpos = strlen(a:str) - 1
    endif
    return strpart(a:str,a:pos,endpos - a:pos + 1)
endfunc


" Function: TrimWS
" Args: str
" Description: Trim any WS at the end of the string str

func! TrimWS(str)
    let len = match(a:str,' \{1,}$',0)
    if len == -1 
        return a:str 
    else
        return strpart(a:str,0,len)
    endif
endfunc


" Function: LenWS
" Args: str, startpos
" Description: Length of contiguous whitespace starting at
" position startpos in string str

func! LenWS(str,startpos)
    let i = 0
    while a:str[a:startpos+i] == ' '
        let i = i + 1
    endwhile
    return i
endfunc


" Function: Replicate
" Args: str,cnt
"
" Repeat the given string cnt number of times

func! Replicate(str,cnt)
    let l:temp = ""

    let l:i = 0
    while i < a:cnt
        let temp = temp . a:str
        let i = i + 1
    endwhile

    return temp
endfunc


" Function: ExpandTabs
" Args: str
" Return value: string 
"
" Expand all tabs in the string to spaces 
" according to tabstop value

func! ExpandTabs(str)
    let l:str = a:str
    let l:temp = ""

    let l:i = 0
    while i < strlen(str)
        if str[i] == "\t"
            let temp = temp . Replicate(' ',&tabstop)
        else
            let temp = temp . str[i]
        endif
        let i = i + 1
    endwhile

    return temp
endfunc

" Function: Max
" Args: x,y
" Description: return the max of x and y

func! Max(x,y)
    if a:x >= a:y 
        return a:x
    else 
        return a:y
    endif
endfunc
