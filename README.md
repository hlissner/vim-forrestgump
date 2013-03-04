vim-forrestgump
===============

One thing I miss from textmate? ⌘R and ⌥⌘R.

The former would run the current script and display output in a separate
window. The latter would run selected code (or the current line).

This simple plugin aims to mimic that.

It works out of the box with PHP, Ruby, Python and sh script (interpreted
languages).

## Languages supported

The following interpreters should work out of the box.

    let g:forrestgump_types = {
        "php":        ["php", "<?php "],
        "python":     ["python"],
        "ruby":       ["ruby"],
        "perl":       ["perl"],
        "javascript": ["javascript"],
        "coffee":     ["coffee"],
        "sh":         ["sh"]
        
        " Example:
        "&filetype":  ["/usr/bin/&filetype", "Prepend this to code"]
    }

## Usage

    nmap <leader>r      Run entire file (doesn't have to be saved)
    nmap <leader>R      Run current line(s)
    vmap <leader>r      Run current or selected line(s)
