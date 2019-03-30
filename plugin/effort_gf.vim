command! EffortGF call s:effort_gf(<q-mods>, expand('<cfile>'))
function! s:effort_gf(mods, word)
  let candidate = effort_gf#find(a:word)
  if strlen(candidate)
    if strlen(a:mods)
      execute printf('%s split %s', a:mods, fnameescape(candidate))
    else
      execute printf('edit %s', fnameescape(candidate))
    endif
  else
    echomsg printf('`%s` is not found.', a:word)
  endif
endfunction

