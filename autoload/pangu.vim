" Constants: {{{

let s:PATTERNS = {
      \   'CJK':              '[\u4e00-\u9fa5\u3040-\u30FF]',
      \   'CJK_PUNCTUATIONS': '[。，；？！：；《》]',
      \   'FULL_WIDTH_DIGIT': '[\uff10-\uff19]',
      \   'FULL_WIDTH_ALPHA': '[\uff21-\uff3a\uff41-\uff5a]',
      \   'FULL_WIDTH_PUNCT': '[\uff20-\uff20]',
      \   'NON_CJK_PREFIXED': '[a-zA-Z0-9@&=\[\$\%\^\-\+(\/\\]',
      \   'NON_CJK_SUFFIXED': '[a-zA-Z0-9!&;=\]\,\.\:\?\$\%\^\-\+\)\/\\]'
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

let s:CHAR_NUMBER_DIFF = {
      \   'DIGIT': char2nr('０', 1) - char2nr('0', 1),
      \   'ALPHA': char2nr('Ａ', 1) - char2nr('A', 1),
      \   'PUNCT': char2nr('＠', 1) - char2nr('@', 1)
      \ }

let s:PATTERNS['MARKDOWN_REF_LINK_FIX'] = join([
      \   '\v',
      \   '[「\[]' . '([^」\]]+)' . '[」\]]',
      \   '[「\[]' . '([^」\]]+)' . '[」\]]'
      \ ], '')
let s:PATTERNS['MARKDOWN_INLINE_LINK_FIX'] = join([
      \   '\v',
      \   '[「\[]' . '([^」\]]+)' . '[」\]]',
      \   '[（\(]' . '([^」\)]+)' . '[）\)]'
      \ ], '')

let s:LANG_OVERRIDES = {}
let s:LANG_OVERRIDES['mappings'] = {
      \   'CN': {
      \     'punctuations': {
      \       ']'   :   '』',
      \       '>'   :   '》'
      \     },
      \     'punctuations_prefixed': {
      \       '['   :   '『',
      \       '<'   :   '《'
      \     }
      \   }
      \ }

" }}} Constants


" Main Functions: {{{

function! pangu#spacing(text)
  let t = a:text

  " 汉字后的标点符号，转成全角符号。
  let t = substitute(
        \   t,
        \   printf(
        \     '\v%s' . '\zs([%s])' . '(\s+%s)?',
        \     s:PATTERNS.CJK,
        \     join(
        \       map(keys(s:get_mappings('punctuations')), 's:escape_pattern(v:val)'),
        \       ''
        \     ),
        \     s:PATTERNS.NON_CJK_PREFIXED
        \   ),
        \   '\=s:replace_with_mapping("punctuations", submatch(1))',
        \   'g'
        \ )

  " 中文字前的標點符號，轉為全形
  let t = substitute(
        \   t,
        \   printf(
        \     '\zs[%s]\ze%s',
        \     join(
        \       map(keys(s:get_mappings('punctuations_prefixed')), 's:escape_pattern(v:val)'),
        \       ''
        \     ),
        \     s:PATTERNS.CJK
        \   ),
        \   '\=s:replace_with_mapping("punctuations_prefixed")',
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


  " 修复 markdown 链接所使用的标点。
  let t = substitute(
        \   t,
        \   s:PATTERNS.MARKDOWN_REF_LINK_FIX,
        \   '[\1][\2]',
        \   'g'
        \ )
  let t = substitute(
        \   t,
        \   s:PATTERNS.MARKDOWN_INLINE_LINK_FIX,
        \   '[\1](\2)',
        \   'g'
        \ )

  " 移除頭尾空白
  let t = substitute(
        \   t,
        \   '^ \[',
        \   '[',
        \   ''
        \ )
  let t = substitute(
        \   t,
        \   '\s\+$',
        \   '',
        \   ''
        \ )

  return t
endfunction

" }}} Main Functions


" Utils: {{{

function! s:replace_with_mapping(type, ...) "{{{
  let mappings = s:get_mappings(a:type)
  let key      = a:0 ? a:1 : submatch(0)
  let result   = ''

  if has_key(mappings, key)
    " type specific operations
    if a:type == 'punctuations'
      let result = get(mappings, key)
      let head = submatch(2)
      if len(head)
        let result = result . head[1:]
      endif
    else
      let result = get(mappings, key)
    endif
  else
    throw printf(
          \   'pangu.vim: undefine mapping for %s (of type %s)',
          \   key,
          \   a:type
          \ )
  endif

  return result
endfunction "}}}


function! s:down_width(char) "{{{
  let diff = ''

  for type in keys(s:CHAR_NUMBER_DIFF)
    if a:char =~ s:PATTERNS['FULL_WIDTH_' . type]
      let diff = s:CHAR_NUMBER_DIFF[type]
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


function! s:get_mappings(type) "{{{
  let mappings = get(s:MAPPINGS, a:type, {})
  let region   = matchstr(v:ctype, '\c\vzh.\zs(TW|HK|CN)\ze')

  if len(region)
    let overrides = get(
          \   get(s:LANG_OVERRIDES.mappings, region, {}),
          \   a:type,
          \   {}
          \ )
    if !empty(overrides)
      let mappings = extend(copy(mappings), overrides)
    endif
  endif

  return mappings
endfunction "}}}


function! s:escape_pattern(pattern) "{{{
  return escape(a:pattern, '.*~\[]^$')
endfunction "}}}


function! s:SID() "{{{
  return matchstr(expand('<sfile>'), '<SNR>\d\+_\zeSID$')
endfunction "}}}


function! pangu#sid() "{{{
  return s:SID()
endfunction "}}}

" }}} Utils
