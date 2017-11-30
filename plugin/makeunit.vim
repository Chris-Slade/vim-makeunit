" makeunit: Create a unit test for the Java class in the current buffer.
" Last Change: 2017-11-29
" Maintainer: Chris-Slade (GitHub)
" License: MIT

" Set-up plug-in
if exists('g:loaded_makeunit') || &cp | finish | endif
let g:loaded_makeunit = 1
let s:savecpo = &cpo
set cpo&vim

" Import statements to be placed in the file
let g:makeunit_imports = [ 'org.junit.Test' ]
" Static imports
let g:makeunit_static_imports = [ 'org.junit.assertTrue' ]
" Use Allman brace style (default: no)
let g:makeunit_use_allman_style = 0

command! MakeUnit call makeunit#CreateUnitTest()

" Restore options
let &cpo = s:savecpo
unlet s:savecpo
