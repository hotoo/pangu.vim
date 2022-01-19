" @see [全角和半角 - wikipedia](http://zh.wikipedia.org/wiki/%E5%85%A8%E5%BD%A2%E5%92%8C%E5%8D%8A%E5%BD%A2)
" @see [中文文案排版指北](https://github.com/sparanoid/chinese-copywriting-guidelines)

if exists("load_pangu_space")
  finish
endif
let load_pangu_space=1

let g:pangu_enabled=1

function! PanGuSpacingCore()
    let ignore = search("PANGU_DISABLE", 'n')
    if (ignore > 0)
      return
    endif

    if &ft != "diff"
        let l:save_regexpengine = &regexpengine
        let &regexpengine=2

        let b:curcol = col(".")
        let b:curline = line(".")

        " 汉字后的标点符号，转成全角符号。
        silent! %s/\([\u4e00-\u9fa5\u3040-\u30FF]\)\.\($\|\s\+\)/\1。/g
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

        " 连续的句号转成省略号
        " - `……`
        " - `⋯⋯`
        " - `......`
        " - `······`
        " @see [中文省略号应该垂直居中还是沉底？](https://www.zhihu.com/question/19593470)
        silent! %s/。\{3,}/....../g

        " #11: 根据《标点符号用法》，重复的感叹号、问号不允许超过 3 个。
        " [标点符号用法 GB/T 15834 2011](http://www.moe.gov.cn/ewebeditor/uploadfile/2015/01/13/20150113091548267.pdf)
        silent! %s/\([！？]\)\1\{3,}/\1\1\1/g
        silent! %s/\([。，；：、“”『』〖〗《》]\)\1\{1,}/\1/g

        " 全角数字、英文字符、英文标点。
        " 65248 是相对应的全角和半角的 Unicode 偏差。
        silent! %s/\([０-９Ａ-Ｚａ-ｚ＠]\)/\=nr2char(char2nr(submatch(0))-65248)/g

        " 汉字与其前后的英文字符、英文标点、数字间增加空白。
        silent! %s/\([\u4e00-\u9fa5\u3040-\u30FF]\)\([a-zA-Z0-9@&=\[\$\%\^\-\+(\/\\]\)/\1 \2/g " 汉字在前。
        silent! %s/\([a-zA-Z0-9!&;=\]\,\.\:\?\$\%\^\-\+\)\/\\]\)\([\u4e00-\u9fa5\u3040-\u30FF]\)/\1 \2/g " 汉字在后。

        " 修复 markdown 链接所使用的标点。
        silent! %s/[『\[]\([^』\]]\+\)[』\]][『\[]\([^』\]]\+\)[』\]]/[\1][\2]/g " 参考链接
        silent! %s/[『\[]\([^』\]]\+\)[』\]][（(]\([^』)]\+\)[）)]/[\1](\2)/g " 内联链接
        " WiKi 链接：
        " - [『中文条目』] -> [[中文条目]]
        " - [[en 条目』] -> [[en 条目]]
        " - [『条目 en]] -> [[条目 en]]
        silent! %s/\[[『\[]\([^』\]]\+\)[』\]]\]/[[\1]]/g

        silent! %s/^ \[/[/
        silent! %s/\s\+$//

        call cursor(b:curline, b:curcol)
        let &regexpengine=l:save_regexpengine
    endif
endfunction

function! PanGuSpacing()
  if g:pangu_enabled == 1
    call PanGuSpacingCore()
  endif
endfunction

command! -nargs=* Pangu call PanGuSpacingCore()
command! -nargs=0 PanguDisable let g:pangu_enabled=0
command! -nargs=0 PanguEnable let g:pangu_enabled=1
