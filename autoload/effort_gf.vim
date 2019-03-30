let g:effort_gf#config = get(g:, 'effort_gf#config', {})
let g:effort_gf#config.debug = get(g:effort_gf#config, 'debug', v:false)
let g:effort_gf#config.root_markers = get(g:effort_gf#config, 'root_markers', ['.git', 'package.json'])
let g:effort_gf#config.get_buffer_path = get(g:effort_gf#config, 'get_buffer_path', { -> expand('%:p:h')})
let g:effort_gf#config.converters = get(g:effort_gf#config, 'converters', {})

function! effort_gf#find(word)
  return s:find(s:convert(a:word))
endfunction

function! effort_gf#is(path)
  return stridx(expand('%:p'), fnamemodify(a:path, ':p')) == 0
endfunction

function! s:convert(word)
  call s:debug('input', a:word)
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
  call s:debug('output', word)
  return word
endfunction

function! s:find(word)
  return findfile(a:word, s:find_root() . '**')
endfunction

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

function! s:debug(name, value)
  if g:effort_gf#config.debug
    echomsg a:name . ': ' . a:value
  endif
endfunction

function! s:take_extension(word)
  for suffix in split(getbufvar(bufnr('%'), '&suffixesadd', ''), ',')
    let regex = escape(suffix, '.') . '$'
    if match(a:word, regex) != -1
      return [substitute(a:word, regex, '', 'g'), suffix]
    endif
  endfor
  return [a:word, '']
endfunction

