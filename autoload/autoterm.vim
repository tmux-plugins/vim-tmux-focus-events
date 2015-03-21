function! autoterm#cursor_in_cmd_line()
  return !empty(getcmdtype())
endfunction

function! autoterm#delayed_checktime()
  if autoterm#cursor_in_cmd_line()
    return
  endif
  " clearing out 'emergency' events
  augroup focus_gained_checktime
    au!
  augroup END
  silent checktime
endfunction

function! autoterm#focus_gained()
  if autoterm#cursor_in_cmd_line()
    augroup focus_gained_checktime
      au!
      " perform checktime ASAP when outside cmd line
      au * * call autoterm#delayed_checktime()
    augroup END
  else
    silent checktime
  endif
endfunction
