if exists('g:gitline_loaded')
  finish
endif
let g:gitline_loaded = 1

let s:save_cpo = &cpo
set cpo&vim

call gitline#Init()

let &cpo = s:save_cpo
unlet s:save_cpo
