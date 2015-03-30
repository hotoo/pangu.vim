" @see [全角和半角 - wikipedia](http://zh.wikipedia.org/wiki/%E5%85%A8%E5%BD%A2%E5%92%8C%E5%8D%8A%E5%BD%A2)
" @see [中文文案排版指北](https://github.com/sparanoid/chinese-copywriting-guidelines)

if exists("load_pangu_space")
  finish
endif
let load_pangu_space=1

let g:pangu_enabled=1

function! PanGuSpacingCore()
    if &ft != "diff"
        let b:curcol = col(".")
        let b:curline = line(".")

        " 剔除多余的非行首多个连续空白。
        silent! %s/\(\S\)\s\+/\1 /g

        " 汉字后的标点符号，转成全角符号。
        silent! %s/\([\u4e00-\u9fa5\u3040-\u30FF]\)\.\s*/\1。/g
        silent! %s/\([\u4e00-\u9fa5\u3040-\u30FF]\),\s*/\1，/g
        silent! %s/\([\u4e00-\u9fa5\u3040-\u30FF]\);\s*/\1；/g
        silent! %s/\([\u4e00-\u9fa5\u3040-\u30FF]\)!\s*/\1！/g
        silent! %s/\([\u4e00-\u9fa5\u3040-\u30FF]\):\s*/\1：/g
        silent! %s/\([\u4e00-\u9fa5\u3040-\u30FF]\)?\s*/\1？/g
        silent! %s/\([\u4e00-\u9fa5\u3040-\u30FF]\)\\\s*/\1、/g
        silent! %s/(\([\u4e00-\u9fa5\u3040-\u30FF]\)/（\1/g
        silent! %s/\([\u4e00-\u9fa5\u3040-\u30FF]\))/\1）/g
        silent! %s/\[\([\u4e00-\u9fa5\u3040-\u30FF]\)/『\1/g
        silent! %s/\([\u4e00-\u9fa5\u3040-\u30FF]\)\]/\1』/g
        silent! %s/<\([\u4e00-\u9fa5\u3040-\u30FF]\)/《\1/g
        silent! %s/\([\u4e00-\u9fa5\u3040-\u30FF]\)>/\1》/g
        " TODO: 半角单双引号无法有效判断起始和结束，以正确替换成全角单双引号。
        " 可以考虑通过标识符号提醒。

        " 重复的标点符号。
        silent! %s/\([。，；？！：；《》]\)\{2,\}/\1/g

        " 全角数字。
        silent! %s/０/0/g
        silent! %s/１/1/g
        silent! %s/２/2/g
        silent! %s/３/3/g
        silent! %s/４/4/g
        silent! %s/５/5/g
        silent! %s/６/6/g
        silent! %s/７/7/g
        silent! %s/８/8/g
        silent! %s/９/9/g

        " 全角英文字符。
        silent! %s/Ａ/A/g
        silent! %s/Ｂ/B/g
        silent! %s/Ｃ/C/g
        silent! %s/Ｄ/D/g
        silent! %s/Ｅ/E/g
        silent! %s/Ｆ/F/g
        silent! %s/Ｇ/G/g
        silent! %s/Ｈ/H/g
        silent! %s/Ｉ/I/g
        silent! %s/Ｊ/J/g
        silent! %s/Ｋ/K/g
        silent! %s/Ｌ/L/g
        silent! %s/Ｍ/M/g
        silent! %s/Ｎ/N/g
        silent! %s/Ｏ/O/g
        silent! %s/Ｐ/P/g
        silent! %s/Ｑ/Q/g
        silent! %s/Ｒ/R/g
        silent! %s/Ｓ/S/g
        silent! %s/Ｔ/T/g
        silent! %s/Ｕ/U/g
        silent! %s/Ｖ/V/g
        silent! %s/Ｗ/W/g
        silent! %s/Ｘ/X/g
        silent! %s/Ｙ/Y/g
        silent! %s/Ｚ/Z/g
        silent! %s/ａ/a/g
        silent! %s/ｂ/b/g
        silent! %s/ｃ/c/g
        silent! %s/ｄ/d/g
        silent! %s/ｅ/e/g
        silent! %s/ｆ/f/g
        silent! %s/ｇ/g/g
        silent! %s/ｈ/h/g
        silent! %s/ｉ/i/g
        silent! %s/ｊ/j/g
        silent! %s/ｋ/k/g
        silent! %s/ｌ/l/g
        silent! %s/ｍ/m/g
        silent! %s/ｎ/n/g
        silent! %s/ｏ/o/g
        silent! %s/ｐ/p/g
        silent! %s/ｑ/q/g
        silent! %s/ｒ/r/g
        silent! %s/ｓ/s/g
        silent! %s/ｔ/t/g
        silent! %s/ｕ/u/g
        silent! %s/ｖ/v/g
        silent! %s/ｗ/w/g
        silent! %s/ｘ/x/g
        silent! %s/ｙ/y/g
        silent! %s/ｚ/z/g

        " 全角英文标点。
        silent! %s/＠/@/g

        " 汉字与其前后的英文字符、英文标点、数字间增加空白。
        silent! %s/\([\u4e00-\u9fa5\u3040-\u30FF]\)\([a-zA-Z0-9@&=\[\$\%\^\-\+(\/\\]\)/\1 \2/g " 汉字在前。
        silent! %s/\([a-zA-Z0-9!&;=\]\,\.\:\?\$\%\^\-\+\)\/\\]\)\([\u4e00-\u9fa5\u3040-\u30FF]\)/\1 \2/g " 汉字在后。

        " 修复 markdown 链接所使用的标点。
        silent! %s/\s*[『\[]\([^』\]]\+\)[』\]][『\[]\([^』\]]\+\)[』\]]\s*/ [\1][\2] /g " 参考链接
        silent! %s/\s*[『\[]\([^』\]]\+\)[』\]][（(]\([^』)]\+\)[）)]\s*/ [\1](\2) /g " 内联链接

        call cursor(b:curline, b:curcol)
    endif
endfunction

function! PanGuSpacing()
  if g:pangu_enabled == 1
    call PanGuSpacingCore()
  endif
endfunction

command! -nargs=0 Pangu call PanGuSpacingCore()
command! -nargs=0 PanguDisable let g:pangu_enabled=0
command! -nargs=0 PanguEnable let g:pangu_enabled=1
