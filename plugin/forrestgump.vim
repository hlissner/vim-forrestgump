" *vim-forrestgump*     Run code on-the-fly in vim
"
" Version: 0.0.2
" Author:  Henrik Lissner <http://henrik.io>

if exists("g:loaded_forrestgump")
    finish
endif
let g:loaded_forrestgump = 1


""""""""""""""""""""""""""
" Defaults {{

    if !exists("b:fg_bin")
        let b:fg_bin = ""
    endif

    if !exists(g:types)
        let g:types = {}
    endif

" }}

""""""""""""""""""""""""""
" Functions {{

    " Run entire current file (or line) through the appropriate interpreter
    " (e.g.  PHP, ruby, etc) and put it in a preview window.
    func! s:run()
        if !exists("b:fg_bin")
            return
        endif

        call s:runGump(tempname())
    endfunc

    " Run selected lines through an interpreter
    func! s:runRange() range
        if !exists("b:fg_bin")
            return
        endif

        " Temporary file to save to
        let dst = tempname()
        let type = g:types[b:fg_bin]

        " Save code to a tmpfile
        redir > dst
        if get(type, 1) != 0
            echom shellescape(type[1])
        endif
        echom join(getline(a:firstline, a:lastline), "\n")
        redir END

        call s:runGump(dst)
    endfunc

    " Open a preview window and inject output into it
    func! s:preview(tmpfile)
        " Open preview buffer
        silent exe ":pedit! ".a:tmpfile

        " Switch to preview window
        wincmd P
        setl buftype=nofile noswapfile syntax=none bufhidden=delete
        nnoremap <buffer> <Esc> :pclose<CR>

        " Delete the temp file
        if call delete(expand(tmpfile)) != 0
            echoe "ForrestGump: Could not delete temp file."
        endif
    endfunc

    " For setting default filetype => bins
    func! s:defineGump(filetype, opts)
        if !has_key(g:types, filetype)
            let g:types[a:filetype] = opts
        endif
    endfunc

    "
    func! s:runGump(file)
        " See if b:fg_bin is set and exists
        if !exists(b:fg_bin)
            echoe "No binary is set for this filetype."
            return
        endif
        if !executable(b:fg_bin) != 1
            echoe "ERROR: ".b:fg_bin." not found. Is it installed?"
            return
        endif

        let prefix = expand("%") == "" ? 'w ' : ''
        
        " Run tmpfile through interpreter and redir back to tmpfile (recycle!)
        redir! > dst
        echo system(prefix."!".b:fg_bin." ".shellescape(a:file))
        redir END

        " Display it in a preview buffer
        call MlPreview(dst)
    endfunc

" }}

""""""""""""""""""""""""""
" Bootstrap {{

    " Default gumps
    call s:defineGump("php",          ["php", "<?php"])
    call s:defineGump("python",       ["python"])
    call s:defineGump("ruby",         ["ruby"])
    call s:defineGump("perl",         ["perl"])
    call s:defineGump("javascript",   ["node"])
    call s:defineGump("coffee",       ["coffee"])
    call s:defineGump("sh",           ["sh"])

    " Maps
    map <Plug>fgRunAll :<C-U>call <SID>run()<CR>
    map <Plug>fgRunRange :<C-U>call <SID>runRange()<CR>

    if g:noMappings != 1
        nmap <leader>r <Plug>fgRunAll
        vmap <leader>r <Plug>fgRunRange

        nmap <D-r> <Plug>fgRunAll
        nmap <D-R> <Plug>fgRunRange
        vmap <D-r> <Plug>fgRunAll
        vmap <D-R> <Plug>fgRunRange
    endif

" }}

" vim: set foldmarker={,} foldlevel=0 foldmethod=marker
