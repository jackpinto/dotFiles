"{{{ syntax highlighting

" allow syntax highlight inside code blocks for these languages
let g:markdown_fenced_languages = ['r', 'python', 'vim', 'js=javascript', 'lua']

"}}}
"{{{ pdf

" open pdf with the same filename - to use with pandoc
if executable("zathura")
  nnoremap <space>op :!zathura %<.pdf<CR>
endif

"}}}
"{{{ formatting

" format with markdown github style and atx headers using pandoc
if executable("pandoc")
  setlocal formatprg=pandoc\ -f\ gfm\ -t\ gfm\ --atx-headers
endif

"}}}
"{{{ surround

let b:surround_{char2nr("p")} = "``` python\r```"
let b:surround_{char2nr("r")} = "``` r\r```"

"}}}
"{{{ conceal

setl conceallevel=0

"}}}
"{{{ matchit

let b:match_words = '^```.\+$:^```$'

"}}}
