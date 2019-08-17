" vim:foldmethod=marker

if exists('g:gitline_autoloaded')
  finish
endif
let g:gitline_autoloaded = 1

let s:save_cpo = &cpo
set cpo&vim

let s:git_root = ''
let s:job_function = ''
let g:gitline_enabled = get(g:, 'gitline_enabled', 1)
let s:gitline_interval = get(g:, 'gitline_interval', 1000)

" Utils {{{
function! s:Head(array) abort
  if len(a:array) == 0
    return ''
  endif

  return a:array[0]
endfunction

function! s:IsFileInPath(file_path, path) abort
  if a:file_path =~? a:path
    return 1
  else
    return 0
  endif
endfunction

function! s:Log(msg) abort
  echom '[gitline.vim] ' . a:msg
endfunction

function! s:StartJob(cmd, options) abort
  if s:job_function == 'jobstart'
    call jobstart(a:cmd, { 
          \'on_stdout': { job_id, data -> a:options.on_out(s:Head(data)) }, 
          \'on_stderr': { job_id, data -> a:options.on_err(join(data)) },
          \'stdout_buffered': v:true
          \})
  elseif s:job_function == 'system'
    let l:result = system(a:cmd)
    let l:result = split(l:result, '\n')
    call a:options.on_out(s:Head(l:result))
  endif
endfunction

function! s:OnJobError(job_name, data) abort
  if a:data == ''
    return
  endif

  call s:Log(a:job_name . ' error: '  . a:data)
endfunction
" }}}

" File Count {{{
let s:gitline_file_count_enabled = get(g:, 'gitline_file_count_enabled', 1)
let s:gitline_file_count_interval = get(g:, 'gitline_file_count_interval', s:gitline_interval)
let s:gitline_file_count_prefix = get(g:, 'gitline_file_count_prefix', '')
let s:gitline_file_count = ''

function! s:OnFileCount(file_count) abort
  if a:file_count == 0
    let s:gitline_file_count = ''
    return
  elseif a:file_count == ''
    let s:gitline_file_count = ''
    return
  endif

  let s:gitline_file_count = s:gitline_file_count_prefix . a:file_count
endfunction

function! gitline#FileCountJob() abort
  let l:cmd = 'git ls-files -o -m --exclude-standard 2>/dev/null | wc -l | awk "{print $1}" | bc'
  let l:options = { 'on_out': function('s:OnFileCount'), 'on_err': function('s:OnJobError', ['file_count']) }
  call s:StartJob(cmd, options)
endfunction

function! gitline#FileCount() abort
  return s:gitline_file_count
endfunction
" }}}

" Branch Name {{{
let s:gitline_branch_name_enabled = get(g:, 'gitline_branch_name_enabled', 1)
let s:gitline_branch_name_interval = get(g:, 'gitline_branch_name_interval', s:gitline_interval)
let s:gitline_branch_name_prefix = get(g:, 'gitline_branch_name_prefix', '')
let s:gitline_branch_name_without_prefix = ''
let s:gitline_branch_name = ''

function! s:OnBranchName(branch_name) abort
  if a:branch_name == ''
    let s:gitline_branch_name_without_prefix = ''
    let s:gitline_branch_name = ''
    return
  endif

  let s:gitline_branch_name_without_prefix = a:branch_name
  let s:gitline_branch_name = s:gitline_branch_name_prefix . a:branch_name
endfunction

function! gitline#BranchNameJob() abort
  let l:cmd = 'git branch 2>/dev/null | grep \* | cut -d " " -f2'
  let l:options = { 'on_out': function('s:OnBranchName'), 'on_err': function('s:OnJobError', ['branch_name']) }
  call s:StartJob(cmd, options)
endfunction

function! gitline#BranchName() abort
  return s:gitline_branch_name
endfunction
" }}}

" Fetch Status {{{
let s:gitline_fetch_status_enabled = get(g:, 'gitline_fetch_status_enabled', 1)
let s:gitline_fetch_status_interval = get(g:, 'gitline_fetch_status_interval', s:gitline_interval)
let s:gitline_ahead_prefix = get(g:, 'gitline_ahead_prefix', '⇡')
let s:gitline_behind_prefix = get(g:, 'gitline_behind_prefix', '⇣')
let s:gitline_fetch_status = ''

function! s:OnFetchStatus(fetch_status) abort
  if a:fetch_status == ''
    let s:gitline_fetch_status = ''
    return ''
  endif

	let l:fetch_status = split(matchstr(a:fetch_status,  '\m\C\[\zs.\{-}\ze\]'), ', ')
	let l:ahead = ''
	let l:behind = ''

	for status in l:fetch_status
	  let [l:type, l:value] = split(status, ' ')
    if l:type =~? 'ahead'
      let l:ahead = l:value
    else
      let l:behind = l:value
    endif
  endfor

  let l:fetch_status = []
	if l:ahead != ''
	  call add(l:fetch_status, s:gitline_ahead_prefix . l:ahead)
  endif

  if l:behind != ''
	  call add(l:fetch_status, s:gitline_behind_prefix . l:behind)
  endif

  let s:gitline_fetch_status = join(l:fetch_status)
endfunction

function! gitline#FetchStatusJob() abort
  if s:gitline_branch_name == ''
    return ''
  endif

  let l:cmd = 'git for-each-ref --format="%(refname:short) %(push:track)" refs/heads | grep ' . s:gitline_branch_name_without_prefix
  let l:options = { 'on_out': function('s:OnFetchStatus'), 'on_err': function('s:OnJobError', ['fetch_status']) }
  call s:StartJob(cmd, options)
endfunction

function! gitline#FetchStatus() abort
  return s:gitline_fetch_status
endfunction
" }}}

" File Status {{{
let s:gitline_file_status_enabled = get(g:, 'gitline_file_status_enabled', 1)
let s:gitline_file_status_untracked = get(g:, 'gitline_file_status_untracked', 'U')
let s:gitline_file_status_modified = get(g:, 'gitline_file_status_modified', 'M')
let s:gitline_file_status = ''

function! s:OnFileStatus(file_status) abort
  if a:file_status == '?'
    let s:gitline_file_status = s:gitline_file_status_untracked
  elseif a:file_status == 'M'
    let s:gitline_file_status = s:gitline_file_status_modified
  else
    let s:gitline_file_status = ''
  endif
endfunction

function! gitline#FileStatusJob() abort
  let l:file_path = expand('%:p')
  if s:IsFileInPath(l:file_path, s:git_root) == 0
    return
  endif

  let l:cmd = 'git status --porcelain -- ' . l:file_path . ' 2>/dev/null | cut -c2-2'
  let l:options = { 'on_out': function('s:OnFileStatus'), 'on_err': function('s:OnJobError', ['file_status']) }
  call s:StartJob(cmd, options)
endfunction

function! gitline#FileStatus() abort
  return s:gitline_file_status
endfunction
" }}}

function! gitline#Init() abort " {{{
  if g:gitline_enabled == 0
    return
  endif

  let l:result = split(system('git rev-parse --show-toplevel 2>/dev/null'), '\n')
  let s:git_root = s:Head(l:result)

  if s:git_root == ''
    let g:gitline_enabled = 0
    return
  endif

  if exists('*jobstart')
    let s:job_function = 'jobstart'
  elseif exists('*job_start')
    call s:Log('vim async job not supported yet, fallsback to system')
    let s:job_function = 'system'
  else
    let s:job_function = 'system'
  endif

  if s:gitline_file_count_enabled == 1
    call timer_start(s:gitline_file_count_interval, { tid -> gitline#FileCountJob() }, { 'repeat': -1 })
  endif
  if s:gitline_branch_name_enabled == 1
    call timer_start(s:gitline_branch_name_interval, { tid -> gitline#BranchNameJob() }, { 'repeat': -1 })
  endif
  if s:gitline_fetch_status_enabled == 1
    call timer_start(s:gitline_fetch_status_interval, { tid -> gitline#FetchStatusJob() }, { 'repeat': -1 })
  endif

  if s:gitline_file_status_enabled == 1
    augroup gitline
      autocmd!
      autocmd BufEnter,BufReadPost,FileReadPost,BufWritePost,FileWritePost * :call gitline#FileStatusJob()
    augroup END
  endif
endfunction " }}}

let &cpo = s:save_cpo
unlet s:save_cpo
