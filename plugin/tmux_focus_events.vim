if !exists('$TMUX') || has('gui_running')
  finish
endif

if exists('g:loaded_tmux_focus_events') && g:loaded_tmux_focus_events
  finish
endif
let g:loaded_tmux_focus_events = 1

let s:save_cpo = &cpo
set cpo&vim

function s:do_autocmd(event)
  let cmd = getcmdline()
  let pos = getcmdpos()
  exec 'silent doautocmd ' . a:event . ' <nomodeline> %'
  call setcmdpos(pos)
  return cmd
endfunction

" This function copied and adapted from https://github.com/sjl/vitality.vim
" If you want to try to understand what is going on, look into comments from
" that plugin.
function! s:restore_focus_events()
  let save_screen = "\<Esc>[?1049h"
  let restore_screen = "\<Esc>[?1049l"

  let tmux_start = "\<Esc>Ptmux;"
  let tmux_end = "\<Esc>\\"

  " This escape sequence is escaped to get through Tmux without being "eaten"
  let enable_focus_reporting = "\<Esc>[?1004h"
  let escaped_enable_focus_reporting = tmux_start
        \ . "\<Esc>" . enable_focus_reporting
        \ . tmux_end
        \ . enable_focus_reporting

  let disable_focus_reporting = "\<Esc>[?1004l"

  let &t_ti = escaped_enable_focus_reporting . save_screen
  let &t_te = disable_focus_reporting . restore_screen

  " When Tmux 'focus-events' option is on, Tmux will send <Esc>[O when the
  " window loses focus and <Esc>[I when it gains focus.
  exec "set <F24>=\<Esc>[O"
  exec "set <F25>=\<Esc>[I"

  nnoremap <silent> <F24> :silent doautocmd <nomodeline> FocusLost %<CR>
  nnoremap <silent> <F25> :doautocmd <nomodeline> FocusGained %<CR>

  onoremap <silent> <F24> <Esc>:silent doautocmd <nomodeline> FocusLost %<CR>
  onoremap <silent> <F25> <Esc>:silent doautocmd <nomodeline> FocusGained %<CR>

  vnoremap <silent> <F24> <Esc>:silent doautocmd <nomodeline> FocusLost %<CR>gv
  vnoremap <silent> <F25> <Esc>:silent doautocmd <nomodeline> FocusGained %<CR>gv

  inoremap <silent> <F24> <C-\><C-O>:silent doautocmd <nomodeline> FocusLost %<CR>
  inoremap <silent> <F25> <C-\><C-O>:silent doautocmd <nomodeline> FocusGained %<CR>

  cnoremap <silent> <F24> <C-\>e<SID>do_autocmd('FocusLost')<CR>
  cnoremap <silent> <F25> <C-\>e<SID>do_autocmd('FocusGained')<CR>
endfunction

call <SID>restore_focus_events()

" When '&term' changes values for '<F24>', '<F25>', '&t_ti' and '&t_te' are
" reset. Below autocmd restores values for those options.
au TermChanged * call <SID>restore_focus_events()

" restore vim 'autoread' functionality
au FocusGained * call tmux_focus_events#focus_gained()

let &cpo = s:save_cpo
unlet s:save_cpo
