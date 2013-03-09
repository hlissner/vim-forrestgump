" *vim-forrestgump*     Run code on-the-fly in vim
"
" Version: 1.0.1
" Author:  Henrik Lissner <http://henrik.io>

if exists("g:loaded_forrestgump")
    finish
endif
let g:loaded_forrestgump = 1


" Defaults

if !exists("g:forrestgumps")
    let g:forrestgumps = {}
endif

if !exists("g:forrestgump_no_mappings")
    let g:forrestgump_no_mappings = 0
endif


" Functions {

    " run() {
    func! s:runFile()
        let gump = s:findGump()
        if type(gump) != 3
            return
        endif

        " Run the file or its contents through the gump and store output in
        " a tmepfile
        let tempfile = tempname()
        let file = expand('%:p')
        if strlen(file)
            silent exe "!".gump[0]." ".shellescape(file)." > ".shellescape(tempfile)
        else
            silent exe "w !".gump[0]." > ".shellescape(tempfile)
        endif

        " Open tempfile in preview
        call s:preview(tempfile)
    endfunc
    " }

    " runLines() {
    func! s:runLines() range
        let gump = s:findGump()
        if type(gump) != 3
            return
        endif

        " Grab the code. Prepend the second list item if it exists, and if it
        " isn't present in the code being run.
        let code = join(getline(a:firstline, a:lastline), "\n")
        if len(gump) == 2 && match(code, gump[1]) == -1
            let code = gump[1] . " \n " . code
        endif

        " Run code through the gump and send output to tempfile
        let tempfile = tempname()
        call system(gump[0]." > ".shellescape(tempfile), code)

        " Open tempfile in preview
        call s:preview(tempfile)
    endfunc
    " }
    
    " preview() {
    " Open a preview window and inject output into it
    func! s:preview(tmpfile)
        if !filereadable(expand(a:tmpfile))
            echoe "Tmpfile missing. Preview couldn't be created. (".a:tmpfile.")"
            return
        endif

        " Open preview buffer
        silent exe ":pedit! ".a:tmpfile

        " Switch to preview window
        wincmd P
        setl buftype=nofile noswapfile syntax=none bufhidden=delete
        nnoremap <buffer> <Esc> :pclose<CR>

        " delete the temp file
        if delete(expand(a:tmpfile)) != 0
            echoe "could not delete temp file. (".a:tmpfile.")"
        endif
    endfunc
    " }

    " findGump() {
    " Check to see if a gump for the current filetype exists or not
    func! s:findGump()
        " No filetype? No gump!
        if !strlen(&filetype)
            echom "No filetype specified!"
            return
        endif

        " Find which setting is approrpriate for the current filetype. If one
        " doesn't exist, return 0. If the filetype is a two parter (e.g.
        " scss.css), only use the first part to represent the filetype.
        let ft = split(&filetype, "\\.")[0]
        if has_key(g:forrestgumps, ft)
            let gump = g:forrestgumps[ft]

            if type(gump) != 3 || get(gump, 0) != 0
                echoe "Gump for ".&filetype." isn't set up properly."
                return
            elseif !executable(gump[0])
                echoe "Gump for ".&filetype." isn't executable. Is it installed? (".gump[0].")"
                return
            endif
            return gump
        endif

        echom "No gump available for this filetype!"
        return
    endfunc
    " }

    " defineGump {
    " For associating default filetypes to interpreters 
    func! s:defineGump(filetype, opts)
        if !has_key(g:forrestgumps, a:filetype)
            let g:forrestgumps[a:filetype] = a:opts
        endif
    endfunc
    " }

" }

""""""""""""""""""""""""""
" Bootstrap {

    " Default gumps
    call s:defineGump("php",          ["php", "<?php"])
    call s:defineGump("python",       ["python"])
    call s:defineGump("ruby",         ["ruby"])
    call s:defineGump("perl",         ["perl"])
    call s:defineGump("javascript",   ["node"])
    call s:defineGump("coffee",       ["coffee"])
    call s:defineGump("sh",           ["sh"])

    " Maps
    map <silent> <Plug>ForrestRunFile :call <SID>runFile()<CR>
    map <silent> <Plug>ForrestRunLines :call <SID>runLines()<CR>

    if g:forrestgump_no_mappings != 1
        nmap <leader>r <Plug>ForrestRunFile
        vmap <leader>r <Plug>ForrestRunLines
    endif

" }

" vim: set foldmarker={,} foldlevel=0 foldmethod=marker
