if exists('g:autoloaded_tmux_focus_events') && g:autoloaded_tmux_focus_events
  finish
endif
let g:autoloaded_tmux_focus_events = 1

function! s:cursor_in_cmd_line()
  return !empty(getcmdtype()) || !empty(getcmdwintype())
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

function! tmux_focus_events#focus_gained()
  if !&autoread
    return
  endif
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
