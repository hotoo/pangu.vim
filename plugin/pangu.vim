" @see [全角和半角 - wikipedia](http://zh.wikipedia.org/wiki/%E5%85%A8%E5%BD%A2%E5%92%8C%E5%8D%8A%E5%BD%A2)
" @see [中文文案排版指北](https://github.com/sparanoid/chinese-copywriting-guidelines)

if exists("load_pangu_space")
  finish
endif
let load_pangu_space=1

let g:pangu_enabled=1


function! PanGuSpacingCore()
  let text = join(
        \   getline(1, '$'),
        \   "\n"
        \ )
  let text = pangu#spacing(text)
  call setline(1, split(text, '\n'))
endfunction


function! PanGuSpacing()
  if g:pangu_enabled == 1
    call PanGuSpacingCore()
  endif
endfunction

command! -nargs=0 Pangu call PanGuSpacingCore()
command! -nargs=0 PanguDisable let g:pangu_enabled=0
command! -nargs=0 PanguEnable let g:pangu_enabled=1
