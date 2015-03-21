if exists('g:autoloaded_autoterm') && g:autoloaded_autoterm
  finish
endif
let g:autoloaded_autoterm = 1

function! s:cursor_in_cmd_line()
  return !empty(getcmdtype())
endfunction

function! s:delayed_checktime()
  if <SID>cursor_in_cmd_line()
    return
  endif
  " clearing out 'emergency' events
  augroup focus_gained_checktime
    au!
  augroup END
  silent checktime
endfunction

function! autoterm#focus_gained()
  if <SID>cursor_in_cmd_line()
    augroup focus_gained_checktime
      au!
      " perform checktime ASAP when outside cmd line
      au * * call <SID>delayed_checktime()
    augroup END
  else
    silent checktime
  endif
endfunction
