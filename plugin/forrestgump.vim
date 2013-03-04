" *vim-forrestgump*     Run code on-the-fly in vim
"
" Version: 0.1.0
" Author:  Henrik Lissner <http://henrik.io>

" if exists("g:loaded_forrestgump")
"     finish
" endif
" let g:loaded_forrestgump = 1


""""""""""""""""""""""""""
" Defaults {

    if !exists("g:forrestgump_no_mappings")
        let g:forrestgump_no_mappings = 0 
    endif

    if !exists("g:forrestgump_types")
        let g:forrestgump_types = {}
    endif

    if !exists("b:forrestgump_bin")
        let b:forrestgump_bin = ""
    endif

" }

""""""""""""""""""""""""""
" Functions {

    " run() {
    " Run entire current file (or line) through the appropriate interpreter
    " (e.g.  PHP, ruby, etc) and put it in a preview window.
    func! s:run()
        if s:findGump() == 0
            return
        endif

        call s:runGump(tempname())
    endfunc
    " }

    " runRage() {
    " Run selected lines through an interpreter
    func! s:runRange() range
        if s:findGump() == 0
            return
        endif

        " Temporary file to save to
        let dst = tempname()
        let type = g:forrestgump_types[b:forrestgump_bin]

        let code = join(getline(a:firstline, a:lastline), "\n")

        " Save code to a tmpfile
        redir! > dst
        if get(type, 1) != 0
            let prepend = shellescape(type[1])
            if match(code, "\V".prepend) == -1
                echom prepend
            endif
        endif
        echom code
        redir END

        call s:runGump(dst)
    endfunc
    " }

    " runGump(file) {
    func! s:runGump(file)
        " See if b:forrestgump_bin exists
        if !executable("b:forrestgump_bin") != 1
            echoe "ERROR: ".b:forrestgump_bin." not found. Is it installed?"
            return
        endif

        let prefix = strlen(expand("%")) != 0 ? '' : 'w '
        let file = shellescape(a:file)
        let current_file = expand("%")

        " Run tmpfile through interpreter and redir back to tmpfile (recycle!)
        if strlen(current_file) != 0
            silent exe "!".b:forrestgump_bin." ".current_file." > ".file
        else
            silent exe "w !".b:forrestgump_bin." > ".file
        endif
        
        " Display it in a preview buffer
        call s:preview(a:file)
    endfunc
    " }

    " preview() {
    " Open a preview window and inject output into it
    func! s:preview(tmpfile)
        if !filereadable(expand(a:tmpfile))
            echoe "ERROR: Tmpfile does not exist. Preview couldn't be created. (".a:tmpfile.")"
            return
        endif

        " Open preview buffer
        silent exe ":pedit! ".a:tmpfile

        " Switch to preview window
        wincmd P
        setl buftype=nofile noswapfile syntax=none bufhidden=delete
        nnoremap <buffer> <Esc> :pclose<CR>

        " Delete the temp file
        if delete(expand(a:tmpfile)) != 0
            echoe "ERROR: Could not delete temp file. (".a:tmpfile.")"
        endif
    endfunc
    " }

    " defineGump {
    " For setting default filetype => bins
    func! s:defineGump(filetype, opts)
        if !has_key(g:forrestgump_types, a:filetype)
            let g:forrestgump_types[a:filetype] = a:opts
        endif
    endfunc
    " }

    " findGump() {
    " Check to see if a gump for the current filetype exists or not
    func! s:findGump()
        if !exists("b:forrestgump_bin") || strlen(b:forrestgump_bin) == 0
            let ft = split(&filetype, "\\.")[0]
            if has_key(g:forrestgump_types, ft)
                let b:forrestgump_bin = g:forrestgump_types[ft][0]
            else
                return 0
            endif
        endif
        return 1
    endfunc
    " }

" }

""""""""""""""""""""""""""
" Bootstrap {

    " Default gumps
    call s:defineGump("php",          ["php", "<?php "])
    call s:defineGump("python",       ["python"])
    call s:defineGump("ruby",         ["ruby"])
    call s:defineGump("perl",         ["perl"])
    call s:defineGump("javascript",   ["node"])
    call s:defineGump("coffee",       ["coffee"])
    call s:defineGump("sh",           ["sh"])

    " Maps
    map <Plug>fgRunFile :<C-U>call <SID>run()<CR>
    map <Plug>fgRunRange :<C-U>call <SID>runRange()<CR>

    if g:forrestgump_no_mappings != 1
        nmap <leader>r <Plug>fgRunFile
        nmap <leader>R <Plug>fgRunRange
        vmap <leader>r <Plug>fgRunRange

        nmap <D-r> <Plug>fgRunFile
        nmap <D-R> <Plug>fgRunRange
        vmap <D-r> <Plug>fgRunFile
        vmap <D-R> <Plug>fgRunRange
    endif

" }

" vim: set foldmarker={,} foldlevel=0 foldmethod=marker
