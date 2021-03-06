" preview_markdown
" Author: skanehira
" License: MIT

let s:save_cpo = &cpo
set cpo&vim

function! s:echo_err(msg) abort
  echohl ErrorMsg
  echom 'preview-markdown.vim: ' . a:msg
  echohl None
endfunction

function! preview_markdown#preview() abort
  if wordcount().bytes is 0
      call s:echo_err('current buffer is empty')
      return
  endif

  let tmp = tempname()
  call writefile(getline(1, "$"), tmp)

  let parser = get(g:, 'preview_markdown_parser', 'mdr')

  if !executable(parser)
    if parser is 'mdr'
      call s:echo_err('mdr not found, please install from https://github.com/MichaelMure/mdr')
    else
      call s:echo_err(printf('%s not found, please install %s', parser, parser))
    endif
    return
  endif

  if !has('terminal')
    call s:echo_err('this version doesn''t support terminal')
    return
  endif

  let opt = {
        \ 'in_io': 'file',
        \ 'in_name': tmp,
        \ 'exit_cb': function('s:remove_tmp', [tmp]),
        \ 'vertical': get(g:, 'preview_markdown_vertical', 0),
        \ }

  if parser is 'mdr'
    let opt['term_finish'] = 'close'
  endif

  call term_start(parser, opt)
endfunction

function! s:remove_tmp(tmp, channel, msg) abort
  call delete(a:tmp)
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
