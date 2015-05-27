" Constants: {{{

let s:PATTERNS = {
      \   'CJK':              '[\u4e00-\u9fa5\u3040-\u30FF]',
      \   'CJK_PUNCTUATIONS': '[。，；？！：；《》]',
      \   'FULL_WIDTH_DIGIT': '[\uff10-\uff19]',
      \   'FULL_WIDTH_ALPHA': '[\uff21-\uff3a\uff41-\uff5a]',
      \   'FULL_WIDTH_PUNCT': '[\uff20-\uff20]',
      \   'NON_CJK_PREFIXED':   '[a-zA-Z0-9@&=\[\$\%\^\-\+(\/\\]',
      \   'NON_CJK_SUFFIXED':   '[a-zA-Z0-9!&;=\]\,\.\:\?\$\%\^\-\+\)\/\\]'
      \ }
let s:MAPPINGS = {
      \   'punctuations': {
      \     '.'   :   '。',
      \     ','   :   '，',
      \     ';'   :   '；',
      \     '!'   :   '！',
      \     ':'   :   '：',
      \     '?'   :   '？',
      \     '\'   :   '、',
      \     ')'   :   '）',
      \     ']'   :   '」',
      \     '>'   :   '〉'
      \   },
      \   'punctuations_prefixed': {
      \     '('   :   '（',
      \     '['   :   '「',
      \     '<'   :   '〈'
      \   }
      \ }
let s:CHAR_DIFF = {
      \   'DIGIT': char2nr('０', 1) - char2nr('0', 1),
      \   'ALPHA': char2nr('Ａ', 1) - char2nr('A', 1),
      \   'PUNCT': char2nr('＠', 1) - char2nr('@', 1)
      \ }

" }}} Constants


" Main Functions: {{{

function! pangu#spacing(text)
  let t = a:text

  if &ft != "diff"
      let b:curcol = col(".")
      let b:curline = line(".")

      " 剔除多余的非行首多个连续空白。
      let t = substitute(t, '\S\zs\s\+', '\1', 'g')

      " 汉字后的标点符号，转成全角符号。
      let t = substitute(
            \   t,
            \   printf(
            \     '%s\zs[%s]\ze\s*',
            \     s:PATTERNS.CJK,
            \     join(
            \       map(keys(s:MAPPINGS.punctuations), 's:escape_pattern(v:val)'),
            \       ''
            \     )
            \   ),
            \   '\=s:replace_with_mapping("punctuations", submatch(0))',
            \   'g'
            \ )

      " 中文字前的標點符號，轉為全形
      let t = substitute(
            \   t,
            \   printf(
            \     '\zs[%s]\ze%s',
            \     join(
            \       map(keys(s:MAPPINGS.punctuations_prefixed), 's:escape_pattern(v:val)'),
            \       ''
            \     ),
            \     s:PATTERNS.CJK
            \   ),
            \   '\=s:replace_with_mapping("punctuations_prefixed", submatch(0))',
            \   'g'
            \ )
      " TODO: 半角单双引号无法有效判断起始和结束，以正确替换成全角单双引号。
      " 可以考虑通过标识符号提醒。

      " 重复的标点符号。
      let t = substitute(
            \   t,
            \   printf(
            \     '\(%s\)\{2,\}',
            \     s:PATTERNS.CJK_PUNCTUATIONS
            \   ),
            \   '\1',
            \   'g'
            \ )

      " 全角数字。
      let t = substitute(
            \   t,
            \   s:PATTERNS.FULL_WIDTH_DIGIT,
            \   '\=s:down_width(submatch(0))',
            \   'g'
            \ )

      " 全角英文字符。
      let t = substitute(
            \   t,
            \   s:PATTERNS.FULL_WIDTH_ALPHA,
            \   '\=s:down_width(submatch(0))',
            \   'g'
            \ )

      " 全角英文标点。
      let t = substitute(
            \   t,
            \   s:PATTERNS.FULL_WIDTH_PUNCT,
            \   '\=s:down_width(submatch(0))',
            \   'g'
            \ )

      " 汉字与其前后的英文字符、英文标点、数字间增加空白。
      let t = substitute(
            \   t,
            \   printf(
            \     '\zs%s\ze%s',
            \     s:PATTERNS.NON_CJK_PREFIXED,
            \     s:PATTERNS.CJK
            \   ),
            \   '\0 ',
            \   'g'
            \ )
      let t = substitute(
            \   t,
            \   printf(
            \     '%s\zs%s\ze',
            \     s:PATTERNS.CJK,
            \     s:PATTERNS.NON_CJK_SUFFIXED,
            \   ),
            \   ' \0',
            \   'g'
            \ )

      return t

      " FIXME: implement below...

      " 修复 markdown 链接所使用的标点。
      silent! %s/\s*[『\[]\([^』\]]\+\)[』\]][『\[]\([^』\]]\+\)[』\]]\s*/ [\1][\2] /g " 参考链接
      silent! %s/\s*[『\[]\([^』\]]\+\)[』\]][（(]\([^』)]\+\)[）)]\s*/ [\1](\2) /g " 内联链接

      silent! %s/^ \[/[/
      silent! %s/\s\+$//

      call cursor(b:curline, b:curcol)
  endif
endfunction

" }}} Main Functions


" Utils: {{{

function! s:replace_with_mapping(type, string) "{{{
  let mappings = get(s:MAPPINGS, a:type, {})

  if has_key(mappings, a:string)
    return get(mappings, a:string)
  else
    throw printf(
          \   'pangu.vim: undefine mapping for %s (of type %s)',
          \   a:string,
          \   a:type
          \ )
  endif
endfunction "}}}


function! s:down_width(char) "{{{
  let diff = ''

  for type in keys(s:CHAR_DIFF)
    if a:char =~ s:PATTERNS['FULL_WIDTH_' . type]
      let diff = s:CHAR_DIFF[type]
      break
    endif
  endfor

  if empty(diff)
    throw printf(
          \   'pangu.vim: fail convert %s (to half-width)',
          \   a:char
          \ )
  endif

  return nr2char(
        \   char2nr(a:char, 1) - diff,
        \   1
        \ )
endfunction "}}}


function! s:escape_pattern(pattern) "{{{
  return escape(a:pattern, '.*~\[]^$')
endfunction "}}}

" }}} Utils
