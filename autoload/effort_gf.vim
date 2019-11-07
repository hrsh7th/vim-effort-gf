let g:effort_gf#config = get(g:, 'effort_gf#config', {})
let g:effort_gf#config.debug = get(g:effort_gf#config, 'debug', v:false)
let g:effort_gf#config.root_markers = get(g:effort_gf#config, 'root_markers', ['.git', 'package.json'])
let g:effort_gf#config.get_buffer_path = get(g:effort_gf#config, 'get_buffer_path', { -> expand('%:p:h')})
let g:effort_gf#config.converters = get(g:effort_gf#config, 'converters', {})

"
" effort_gf#find
"
function! effort_gf#find(word)
  let l:word = a:word
  call s:debug('input', l:word)
  let l:word = s:convert(l:word)
  call s:debug('converted', l:word)
  let l:word = s:find(l:word)
  call s:debug('found', l:word)
  return l:word
endfunction

"
" effort_gf#is
"
function! effort_gf#is(path)
  return stridx(expand('%:p'), fnamemodify(a:path, ':p')) == 0
endfunction

"
" s:convert
"
function! s:convert(word)
  let word = a:word
  let [word, ext] = s:take_extension(word)
  let word = substitute(word, '^[\./]*', '', 'g') " remove relative path.
  let word = substitute(word, '\.', '/', 'g') " java namespace
  let word = substitute(word, '\\', '/', 'g') " php namespace
  let word = word . ext
  for key in keys(get(g:effort_gf#config, 'converters', {}))
    let word = g:effort_gf#config.converters[key](word)
    call s:debug(key, word)
  endfor
  return word
endfunction

"
" s:find
"
function! s:find(path)
  let l:path = ''
  let l:path = strlen(l:path) == 0 ? findfile(a:path, g:effort_gf#config.get_buffer_path() . ';') : l:path
  let l:path = strlen(l:path) == 0 ? findfile(a:path, s:find_root() . '**') : l:path
  return l:path
endfunction

"
" s:find_root
"
function! s:find_root()
  let path = g:effort_gf#config.get_buffer_path()
  while path !=# ''
    for marker in g:effort_gf#config.root_markers
      let candidate = resolve(path . '/' . marker)
      if filereadable(candidate) || isdirectory(candidate)
        return path
      endif
    endfor
    let path = substitute(path, '/[^/]\{-}$', '', 'g')
  endwhile
  return ''
endfunction

"
" s:debug
"
function! s:debug(name, value)
  if g:effort_gf#config.debug
    echomsg a:name . ': ' . a:value
  endif
endfunction

"
" s:take_extension
"
function! s:take_extension(word)
  for suffix in split(getbufvar(bufnr('%'), '&suffixesadd', ''), ',')
    let regex = escape(suffix, '.') . '$'
    if match(a:word, regex) != -1
      return [substitute(a:word, regex, '', 'g'), suffix]
    endif
  endfor
  return [a:word, '']
endfunction

