if exists('g:loaded_autoterm') && g:loaded_autoterm
  finish
endif
let g:loaded_autoterm = 1

let s:save_cpo = &cpo
set cpo&vim

function! s:cursor_in_cmd_line()
  return !empty(getcmdtype())
endfunction

function! s:delayed_checktime()
  if s:cursor_in_cmd_line()
    return
  endif
  " clearing out 'emergency' events
  augroup focus_gained_checktime
    au!
  augroup END
  call s:silent_checktime()
endfunction

" The command `silent checktime` isn't silent, so using this workaround
function! s:silent_checktime()
  let window_num = 1
  let max_window_num = winnr('$')
  while window_num <=# max_window_num
    let buffer_num = winbufnr(window_num)
    silent exec buffer_num.'checktime'
    let window_num += 1
  endwhile
endfunction

function! s:focus_gained()
  if s:cursor_in_cmd_line()
    augroup focus_gained_checktime
      au!
      " perform checktime ASAP when outside cmd line
      au * * call s:delayed_checktime()
    augroup END
  else
    call s:silent_checktime()
  endif
endfunction

au FocusGained * call s:focus_gained()

let &cpo = s:save_cpo
unlet s:save_cpo
