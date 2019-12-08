if exists('g:autoloaded_tmux_focus_events') && g:autoloaded_tmux_focus_events
  finish
endif
let g:autoloaded_tmux_focus_events = 1

let s:has_getcmdwintype = v:version > 704 || v:version == 704 && has("392")

function! s:cursor_in_cmd_line()
  let in_cmd_line = !empty(getcmdtype())
  let in_cmd_window = s:has_getcmdwintype && !empty(getcmdwintype())
  return in_cmd_line || in_cmd_window
endfunction

function! s:delayed_checktime()
  try
    silent checktime
    " clearing out 'emergency' events, if the checktime succeeded
    augroup focus_gained_checktime
      au!
    augroup END
  catch /E523/  " Not allowed here: silent checktime
  catch /E11/   " Invalid in command-line window
    " don't clear the augroup, let it fire again when possible
  endtry
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
