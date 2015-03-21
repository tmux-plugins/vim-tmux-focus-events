if exists('g:loaded_autoterm') && g:loaded_autoterm
  finish
endif
let g:loaded_autoterm = 1

let s:save_cpo = &cpo
set cpo&vim

if exists('$TMUX')
  au FocusGained * call autoterm#focus_gained()
endif

let &cpo = s:save_cpo
unlet s:save_cpo
