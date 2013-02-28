" *vim-forrestgump*     Run code on-the-fly in vim
"
" Version: 0.0.1
" Author:  Henrik Lissner <http://henrik.io>

if exists("g:loadedForrestGump")
    finish
endif
let g:loadedForrestGump = 1


""""""""""""""""""""""""""
" Defaults

if !exists("b:fgBin")
    let b:fgBin = ""
endif

if !exists("fgPrepend")
    let b:fgPrepend = ""
endif


""""""""""""""""""""""""""
" Functions

" Run entire current file (or line) through the appropriate interpreter
" (e.g.  PHP, ruby, etc) and put it in a preview window.
func! s:fgRun()
    if !exists("b:fgBin")
        return
    endif

    let src = expand("%")
    let dst = tempname()

    let bin = g:fgTypes[b:fgBin][0]
    " If the file has been saved...
    redir > dst
    if src != ""
        " Run it through the interpreter and save output to a tmpfile
        silent exe "!".bin." ".shellescape(src)
    else
        " Otherwise, run the contents directly through the interpreter
        " (out to a tmpfile)
        silent exe "w !".bin
    endif
    redir END

    " Display it in a preview buffer
    call MlPreview(dst)
endfunc

" Run selected lines through an interpreter
func! s:fgRunRange() range
    if !exists("b:fgBin")
        return
    endif

    " Temporary file to save to
    let dst = tempname()
    let type = g:fgTypes[b:fgBin]

    " Save code to a tmpfile
    redir > dst
    if get(type, 1) != 0
        echo shellescape(type[1])
    endif
    echo join(getline(a:firstline, a:lastline), "\n")
    redir END

    " Run the interpreter on it and save output to file
    redir > dst
    silent exe "!".type[0]." ".shellescape(dst)
    redir END

    call MlPreview(dst)
endfunc

" Open a preview window and inject output into it
func! s:fgPreview(tmpfile)
    silent exe ":pedit! ".a:tmpfile
    wincmd P
    setl buftype=nofile noswapfile syntax=none bufhidden=delete
    nnoremap <buffer> <Esc> :pclose<CR>

    if call delete(expand(tmpfile)) != 0
        echoe "ForrestGump: Could not delete temp file."
    endif
endfunc

" For setting default filetype => bins
func! s:fgDefineGump(filetype, opts)
    if !exists(g:fgTypes)
        let g:fgTypes = {}
    endif
    if !has_key(g:fgTypes, filetype)
        let g:fgTypes[a:filetype] = opts
    endif
endfunc

call s:fgDefineGump("php",    ["php", "<?php"])
call s:fgDefineGump("python", ["python"])
call s:fgDefineGump("ruby",   ["ruby"])
call s:fgDefineGump("sh",     ["sh"])


""""""""""""""""""""""""""
" Mappings

map <Plug>fgRunAll :<C-U>call <SID>fgRun()<CR>
map <Plug>fgRunRange :<C-U>call <SID>fgRunRange()<CR>

if g:fgNoMappings != 1
    nmap <leader>r <Plug>fgRunAll
    vmap <leader>r <Plug>fgRunRange

    nmap <D-r> <Plug>fgRunAll
    nmap <D-R> <Plug>fgRunRange
    vmap <D-r> <Plug>fgRunAll
    vmap <D-R> <Plug>fgRunRange
endif


" vim: set foldmarker={,} foldlevel=0 foldmethod=marker
