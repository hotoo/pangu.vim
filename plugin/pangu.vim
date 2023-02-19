" @see [全角和半角 - wikipedia](http://zh.wikipedia.org/wiki/%E5%85%A8%E5%BD%A2%E5%92%8C%E5%8D%8A%E5%BD%A2)
" @see [中文文案排版指北](https://github.com/sparanoid/chinese-copywriting-guidelines)

if exists("load_pangu_space")
  finish
endif
let load_pangu_space=1

if !exists("g:pangu_enabled")
  let g:pangu_enabled=1
endif

if !exists("g:pangu_rule_fullwidth_punctuation")
  let g:pangu_rule_fullwidth_punctuation=1
endif
if !exists("g:pangu_rule_duplicate_punctuation")
  let g:pangu_rule_duplicate_punctuation=1
endif
if !exists("g:pangu_rule_fullwidth_alphabet")
  let g:pangu_rule_fullwidth_alphabet=1
endif
if !exists("g:pangu_rule_spacing")
  let g:pangu_rule_spacing=1
endif
if !exists("g:pangu_rule_spacing_punctuation")
  let g:pangu_rule_spacing_punctuation=0
endif
if !exists("g:pangu_rule_trailing_whitespace")
  let g:pangu_rule_trailing_whitespace=1
endif
if !exists("g:pangu_rule_date")
  let g:pangu_rule_date = 2
endif
if !exists("g:pangu_rule_remove_zero_width_whitespace")
  let g:pangu_rule_remove_zero_width_whitespace = 1
endif

if !exists("g:pangu_punctuation_brackets")
  let g:pangu_punctuation_brackets = ["【", "】"]
endif
if !exists("g:pangu_punctuation_ellipsis")
  let g:pangu_punctuation_ellipsis = "······"
endif

function! PanGuSpacingCore(mode) range
  let ignore = search("PANGU_DISABLE", 'nw')
  if (ignore > 0)
    return
  endif

  if &ft == "diff"
    return
  endif

  let savedpos = getpos("v")

  let l:save_regexpengine = &regexpengine
  let &regexpengine=2
  let l:save_gdefault = &gdefault
  setlocal nogdefault

  let firstline = a:firstline
  let lastline = a:lastline
  " 规范化模式：
  " - ALL: 全局规范化
  " - RANGE: 区域规范化
  if a:mode == "ALL"
    let firstline = 1
    let lastline = line("$")
  endif

  " 汉字后的标点符号，转成全角符号。
  if g:pangu_rule_fullwidth_punctuation == 1
    silent! execute firstline . ',' . lastline . 's/\([\u4e00-\u9fa5\u3040-\u30FF]\)\.\($\|\s\+\)/\1。/g'
    silent! execute firstline . ',' . lastline . 's/\([\u4e00-\u9fa5\u3040-\u30FF]\),\s*/\1，/g'
    silent! execute firstline . ',' . lastline . 's/\([\u4e00-\u9fa5\u3040-\u30FF]\);\s*/\1；/g'
    silent! execute firstline . ',' . lastline . 's/\([\u4e00-\u9fa5\u3040-\u30FF]\)!\s*/\1！/g'
    silent! execute firstline . ',' . lastline . 's/\([\u4e00-\u9fa5\u3040-\u30FF]\):\s*/\1：/g'
    silent! execute firstline . ',' . lastline . 's/\([\u4e00-\u9fa5\u3040-\u30FF]\)?\s*/\1？/g'
    silent! execute firstline . ',' . lastline . 's/\([\u4e00-\u9fa5\u3040-\u30FF]\)\\\s*/\1、/g'
    " 处理一对圆括号。注意：由于 VimScript 正则表达式不支持递归，所以这里不支持有嵌套的括号。
    " 注意：即使支持正则表达式递归，或者手工模拟有限递归，也需要注意括号嵌套错乱的问题，即：
    " - `<中<en>>`
    " + `《中<en>》` 正确
    " + `《中<en》>` 错误。
    " Note: 为了视觉上便于区分，上面用书名号示例。
    silent! execute firstline . ',' . lastline . 's/(\([\u4e00-\u9fa5\u3040-\u30FF][^()]*\|[^()]*[\u4e00-\u9fa5\u3040-\u30FF]\))/（\1）/g'
    silent! execute firstline . ',' . lastline . 's/(\([\u4e00-\u9fa5\u3040-\u30FF]\)/（\1/g'
    silent! execute firstline . ',' . lastline . 's/\([\u4e00-\u9fa5\u3040-\u30FF]\))/\1）/g'

    let bracket_left = g:pangu_punctuation_brackets[0]
    let bracket_right = g:pangu_punctuation_brackets[1]
    " 预处理，将中括号(【,】)更换为特定类型的中括号(『』)，避免处理过程中无法正常处理。
    silent! execute firstline . ',' . lastline . 's/' . bracket_left . '/〘/g'
    silent! execute firstline . ',' . lastline . 's/' . bracket_right . '/〙/g'
    " 处理一对方括号。注意：不支持有嵌套的方括号。
    silent! execute firstline . ',' . lastline . 's/\[\([\u4e00-\u9fa5\u3040-\u30FF][^[\]]*\|[^[\]]*[\u4e00-\u9fa5\u3040-\u30FF]\)\]/' . bracket_left . '\1' . bracket_right . '/g'
    silent! execute firstline . ',' . lastline . 's/\[\([\u4e00-\u9fa5\u3040-\u30FF]\)/' . bracket_left . '\1/g'
    silent! execute firstline . ',' . lastline . 's/\([\u4e00-\u9fa5\u3040-\u30FF]\)\]/\1' . bracket_right . '/g'
    " 处理一对书名号，注意：不支持有嵌套的书名号。
    silent! execute firstline . ',' . lastline . 's/<\([\u4e00-\u9fa5\u3040-\u30FF][^<>]*\|[^<>]*[\u4e00-\u9fa5\u3040-\u30FF]\)>/《\1》/g'
    silent! execute firstline . ',' . lastline . 's/<\([\u4e00-\u9fa5\u3040-\u30FF]\)/《\1/g'
    silent! execute firstline . ',' . lastline . 's/\([\u4e00-\u9fa5\u3040-\u30FF]\)>/\1》/g'
    " 双半角书名号 `<<名称>>` 特殊修复处理
    silent! execute firstline . ',' . lastline . 's/<《/《/g'
    silent! execute firstline . ',' . lastline . 's/》>/》/g'

    " 修复 markdown 链接所使用的标点。
    " 参考链接
    silent! execute firstline . ',' . lastline . 's/[' . bracket_left . '[]\([^' . bracket_right . '\]]\+\)[' . bracket_right . '\]][' . bracket_left . '[]\([^' . bracket_right . '\]]\+\)[' . bracket_right . '\]]/[\1][\2]/g'
    " 内联链接
    silent! execute firstline . ',' . lastline . 's/[' . bracket_left . '[]\([^' . bracket_right . '\]]\+\)[' . bracket_right . '\]][（(]\([^' . bracket_right . ')]\+\)[）)]/[\1](\2)/g'
    " WiKi 链接：
    " - [『中文条目』] -> [[中文条目]]
    " - [[en 条目』] -> [[en 条目]]
    " - [『条目 en]] -> [[条目 en]]
    silent! execute firstline . ',' . lastline . 's/\[[' . bracket_left . '[]\([^' . bracket_right . '\]]\+\)[' . bracket_right . '\]]\]/[[\1]]/g'
    " 修复 wiki 链接 [http://www.example.com/ 示例]
    silent! execute firstline . ',' . lastline . 's/[' . bracket_left . '[]\(https\?:\/\/\S\+\s\+[^' . bracket_right . '\]]\+\)[' . bracket_right . '\]]/[\1]/g'

    " 恢复预处理，将之前预处理的字符恢复。
    silent! execute firstline . ',' . lastline . 's/〘/' . bracket_left . '/g'
    silent! execute firstline . ',' . lastline . 's/〙/' . bracket_right . '/g'
  endif

  " TODO: 半角单双引号无法有效判断起始和结束，以正确替换成全角单双引号。
  " 可以考虑通过标识符号提醒。

  " 连续重复的标点符号规则
  if g:pangu_rule_duplicate_punctuation == 1
    " 连续的句号转成省略号
    " - `……`
    " - `⋯⋯`
    " - `......`
    " - `······`
    " @see [中文省略号应该垂直居中还是沉底？](https://www.zhihu.com/question/19593470)
    silent! execute firstline . ',' . lastline . 's/。\{3,}/' . g:pangu_punctuation_ellipsis . '/g'

    " #11: 根据《标点符号用法》，重复的感叹号、问号不允许超过 3 个。
    " [标点符号用法 GB/T 15834 2011](http://www.moe.gov.cn/ewebeditor/uploadfile/2015/01/13/20150113091548267.pdf)
    silent! execute firstline . ',' . lastline . 's/\([！？]\)\1\{3,}/\1\1\1/g'
    silent! execute firstline . ',' . lastline . 's/\([。，；：、“”【】〔〕『』〖〗〚〛《》]\)\1\{1,}/\1/g'
  endif

  " 全角数字、英文字符、英文标点。
  if g:pangu_rule_fullwidth_alphabet == 1
    " 65248 是相对应的全角和半角的 Unicode 偏差。
    silent! execute firstline . ',' . lastline . 's/\([０-９Ａ-Ｚａ-ｚ＠]\)/\=nr2char(char2nr(submatch(0))-65248)/g'
  endif

  " 汉字与其前后的英文字符、英文标点、数字间增加空白。
  if g:pangu_rule_spacing == 1
    silent! execute firstline . ',' . lastline . 's/\([\u4e00-\u9fa5\u3040-\u30FF]\)\([a-zA-Z0-9]\)/\1 \2/g'
    silent! execute firstline . ',' . lastline . 's/\([a-zA-Z0-9]\)\([\u4e00-\u9fa5\u3040-\u30FF]\)/\1 \2/g'
  endif
  if g:pangu_rule_spacing_punctuation == 1
    silent! execute firstline . ',' . lastline . 's/\([\u4e00-\u9fa5\u3040-\u30FF]\)\([@&=\[\$\%\^\-\+(\\]\)/\1 \2/g'
    silent! execute firstline . ',' . lastline . 's/\([!&;=\]\,\.\:\?\$\%\^\-\+\)]\)\([\u4e00-\u9fa5\u3040-\u30FF]\)/\1 \2/g'
  endif

  " 默认日期每个数字都留白，向前兼容。
  " 例：
  " 在 2017 年 8 月 7 日生日。
  " 在2017年8月7日。
  if g:pangu_rule_date == 0
    " 日期两端也不留白
    " 例：
    " 我在2017年8月7日生日。
    " 在2017年8月7日。
    silent! execute firstline . ',' . lastline . 's/\s*\(\d\{4,5}\)\s*年\s*\(\d\{1,2}\)\s*月/\1年\2月/g'
    silent! execute firstline . ',' . lastline . 's/\s*\(\d\{1,2}\)\s*月\s*\(\d\{1,2}\)\s*日/\1月\2日/g'
    silent! execute firstline . ',' . lastline . 's/\s*\(\d\{4,5}\)\s*年\s*\(\d\{1,2}\)\s*月\s*\(\d\{1,2}\)\s*日/\1年\2月\3日/g'
    " 去除两端留白
    silent! execute firstline . ',' . lastline . 's/\(\(\d\{4,5}年\)\?\d\{1,2}月\(\d\{1,2}日\)\?\)\s\+\([\u4e00-\u9fa5\u3040-\u30FF]\)/\1\4/g'
  elseif g:pangu_rule_date == 1
    " 日期两端留白
    " 例：
    " 我在 2019年12月1日 生日。
    " 在 2017年8月7日。
    silent! execute firstline . ',' . lastline . 's/\(\d\{4,5}\)\s*年\s*\(\d\{1,2}\)\s*月/\1年\2月/g'
    silent! execute firstline . ',' . lastline . 's/\(\d\{1,2}\)\s*月\s*\(\d\{1,2}\)\s\+日/\1月\2日/g'
    silent! execute firstline . ',' . lastline . 's/\(\d\{4,5}\)\s*年\s*\(\d\{1,2}\)\s*月\s*\(\d\{1,2}\)\s\+日/\1年\2月\3日/g'
    " 两端留白
    silent! execute firstline . ',' . lastline . 's/\(\(\d\{4,5}年\)\?\d\{1,2}月\(\d\{1,2}日\)\?\)\([\u4e00-\u9fa5\u3040-\u30FF]\)/\1 \4/g'
  endif

  if g:pangu_rule_trailing_whitespace == 1
    silent! execute firstline . ',' . lastline . 's/^ \[/[/'
    silent! execute firstline . ',' . lastline . 's/\s\+$//'
  endif

  if g:pangu_rule_remove_zero_width_whitespace == 1
    silent! execute firstline . ',' . lastline . 's/[\u200c\u200b\u200d\u202c\u2060\u2061\u2062\u2063\u2064\ufeff]//g'
  endif

  let &regexpengine=l:save_regexpengine
  if l:save_gdefault == 1
    setlocal gdefault
  endif
  call setpos(".", savedpos)
endfunction

function! PanGuSpacing(...)
  if g:pangu_enabled != 1
    return
  endif

  let mode = "ALL"
  if exists("a:1")
    let mode = a:1
  endif

  call PanGuSpacingCore(mode)
endfunction

command! -nargs=* -range Pangu <line1>,<line2>call PanGuSpacingCore("RANGE")
command! -nargs=* PanguAll call PanGuSpacingCore("ALL")
command! -nargs=0 PanguDisable let g:pangu_enabled=0
command! -nargs=0 PanguEnable let g:pangu_enabled=1
