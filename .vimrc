
"
" Author:       Uwe Jugel <uwe.jugel@googlemail.com>
" Last change:  2011 Aug 10
"

" This must be first, because it changes other options as a side effect.
set nocompatible

let g:browsefilter="All files\t*.*\n"
nmap <Esc>o :browse tabe<CR>

function! FindCoffeeProject(...)
  if a:0 == 0
	return call("FindCoffeeProject", [expand("%:p:h")] )
  elseif a:0 == 1
	if isdirectory(expand(a:1))
	  return call("FindCoffeeProject", [1, expand(a:1)] )
	elseif filereadable(expand(a:1))
	  return call("FindCoffeeProject", [1, matchstr( expand(a:1), ".*/" )] )
	else
	  echo "Path not found: " a:1
	endif
  elseif a:0 == 2 && a:1 < &maxfuncdepth - 10
	let l:success = isdirectory(a:2."/src")
	if l:success
	  " echo "Found project dir: " a:2
	  return a:2
	else
	  return call("FindCoffeeProject", [ a:1 + 1, a:2."/.."] )
    endif
  else
	echo "Could not locate project directory"
	echo "see ~/.vimrc#FindProjectFile for details"
  endif
  return
endfunction
command! -nargs=* FindCoffeeProject :call FindCoffeeProject(<f-args>)

function! CompileCoffeeProject(...)
  let l:pdir = call("FindCoffeeProject", [])
  if isdirectory(l:pdir."/src")
	if filereadable(l:pdir."/build.js")
	  echo "Compiling coffee files"
	  let l:result = system("cd ".l:pdir."; node build.js")
	  echo l:result
	  return 1
	else
	  echo "Compile error! Buildfile not found. Please create $PROJECT/build.js."
	endif
  else
	echo "Compile error! Project dir not found. Please create $PROJECT/src."
  endif
  return
endfunction
command! -nargs=* CompileCoffeeProject :call CompileCoffeeProject(<f-args>)

" load plugin bundles via pathogen
filetype off
call pathogen#runtime_append_all_bundles()
filetype on

" allow backspacing over everything in insert mode
set backspace=indent,eol,start

if has("vms")
  set nobackup 		" do not keep a backup file, use versions instead
else
  set backup 		" keep a backup file
endif

" avoid messing up source folders with backup files
if has("unix")
  set backupdir=$HOME/.vim/backup  " store backups centrally
  set directory=$HOME/.vim/tmp     " store swaps centrally
elseif has("win32") || has("win64")
  set backupdir=%VIM%/backup  " store backups centrally
  set directory=%VIM%/tmp     " store swaps centrally
endif

" basics
set history=50      " keep 50 lines of command line history
set ruler           " show the cursor position all the time
set showcmd         " display incomplete commands
set incsearch       " do incremental searching
set hlsearch        " highlight search results
set ignorecase      " ignore case
set tabstop=4       " change tab from 8 to 4
set softtabstop=2   " allow fine grained soft tabs while keeping real tabs stable
set foldcolumn=1    " always show left code folding column
set foldmethod=indent " use space to fold/unfold code; use syntax or indent
" set shiftwidth=4    " set default shiftwidth


" key mappings:    F5: write, compile, check errors (normal AND insert mode)
" toggle mappings: F6: toggle spell checker, F7: toggle line wrap
" ESC mappings:    <ESC>l toggle control characters, <ESC>n toggle line numbers,
"                  <ESC><SPACE> unhighlight search results
"
nmap <F5> :w<CR>:make<CR>:cw<CR>
imap <F5> <ESC><F5>
nmap <F6> :set spell!<CR>
nmap <F7> :set wrap!<CR>
nmap <ESC>l :set list!<CR>
nmap <ESC>n :set number!<CR>
nmap <ESC><SPACE> :nohl<CR>

" remap arrows to hjkl
noremap <left> h
noremap <right> l
noremap <up> k
noremap <down> j

" remap Ctlr+arrows to word/sentence selection
noremap <C-left> b
noremap <C-right> w
noremap <C-up> ( 
noremap <C-down> )

" start select and mark first line (subline)
imap <S-Home> <ESC>v_
imap <S-End> <ESC>v$
nmap <S-Home> v_
nmap <S-End> v$

" init visual mode when starting SHIFT+Arrows selection
" start select and mark first character
imap <S-left> <ESC>vh
imap <S-right> <ESC>vl
nmap <S-left> vh
nmap <S-right> vl

" start select and mark first word
imap <S-C-left> <ESC>vb
imap <S-C-right> <ESC>vw
nmap <S-C-left> vb
nmap <S-C-right> vw

" start select and mark first line
imap <S-up> <ESC>vk
imap <S-down> <ESC>vj
" use remap to prevent old mapping (page up/down)
nnoremap <S-up> vk
nnoremap <S-down> vj

" start select and mark first block
imap <S-C-up> <ESC>v(
imap <S-C-down> <ESC>v)
nmap <S-C-up> v(
nmap <S-C-down> v)

" remap visual up/down keys to prevent unexpected behavior
vnoremap <S-left> h
vnoremap <S-right> l
vnoremap <S-C-left> b
vnoremap <S-C-right> w
vnoremap <S-up> k
vnoremap <S-down> j
vnoremap <S-C-up> (
vnoremap <S-C-down> )
vnoremap <C-up> (
vnoremap <C-down> )

map <A-left> <ESC>:NERDTreeToggle<CR>
map <A-down> <ESC>:bn<CR>
map <A-right> <ESC>:Tlist<CR>
map <A-up> <ESC>:bp<CR>

" Add fontsizes to F8-F12
if has("unix")
  map <F8>  <ESC>:set guifont=Monospace\ 8<CR>
  map <F9>  <ESC>:set guifont=Monospace\ 10<CR>
  map <F10> <ESC>:set guifont=Monospace\ 12<CR>
  map <F11> <ESC>:set guifont=Monospace\ 16<CR>
  map <F12> <ESC>:set guifont=Monospace\ 20<CR>
elseif has("win32") || has("win64")
  map <F8>  <ESC>:set guifont=Lucida_Console:h8:cANSI<CR>
  map <F9>  <ESC>:set guifont=Lucida_Console:h10:cANSI<CR>
  map <F10> <ESC>:set guifont=Lucida_Console:h12:cANSI<CR>
  map <F11> <ESC>:set guifont=Lucida_Console:h16:cANSI<CR>
  map <F12> <ESC>:set guifont=Lucida_Console:h20:cANSI<CR>
endif

" Don't use Ex mode, use Q for formatting
map Q gq
nmap <space> za
nmap <C-space> zi
map <C-Tab> gt<CR>
map <C-S-Tab> gT<CR>
map <A-j> :bn<CR>
map <A-k> :bp<CR>


" CTRL-U in insert mode deletes a lot.  Use CTRL-G u to first break undo,
" so that you can undo CTRL-U after inserting a line break.
inoremap <C-U> <C-G>u<C-U>

" Fix problems with German layout
noremap <C-ü> <C-[>
noremap <C-Ü> <C-{>
noremap <C-ä> <C-]>
noremap <C-Ä> <C-}>
noremap ö ;
noremap Ö :
noremap ä ]
noremap Ä }
noremap ü [
noremap Ü {

" use old english 'search key' on german layout (first key left of R-Shift)
noremap - /
noremap ß _
noremap _ ?

" escape out of insert mode using Shift+Enter 
imap <S-CR> <ESC>
vnoremap <S-CR> <ESC>

" In many terminal emulators the mouse works just fine, thus enable it.
if has('mouse')
  set mouse=a
endif

" Switch syntax highlighting on, when the terminal has colors
" Also switch on highlighting the last used search pattern.
if &t_Co > 2 || has("gui_running")
  syntax on
  set hlsearch
  " Use filetype to add new types to highlighting patterns
"Pmenu		normal item  |hl-Pmenu|
"PmenuSel	selected item  |hl-PmenuSel|
"PmenuSbar	scrollbar  |hl-PmenuSbar|
"PmenuThumb	thumb of the scrollbar  |hl-PmenuThumb|

endif

if has("gui_running")
  " GUI is running or is about to start.
  " Maximize gvim window.
  set lines=100 columns=100
else
  " This is console Vim.
  if exists("+lines")
    set lines=50
  endif
  if exists("+columns")
    set columns=100
  endif
endif

" Only do this part when compiled with support for autocommands.
if has("autocmd")

  " Enable file type detection.
  " Use the default filetype settings, so that mail gets 'tw' set to 72,
  " 'cindent' is on in C files, etc.
  " Also load indent files, to automatically do language-dependent indenting.  
  

  filetype plugin indent on

  " Put these in an autocmd group, so that we can delete them easily.
  aug vimrcEx
  au!

  " add coffee files to autocomplete
  au BufNewFile,BufRead *.co set filetype=coffee

  " For all text files set 'textwidth' to 78 characters.
  au FileType text setlocal textwidth=78

  " When editing a file, always jump to the last known cursor position.
  " Don't do it when the position is invalid or when inside an event handler
  " (happens when dropping a file on gvim).
  " Also don't do it when the mark is in the first line, that is the default
  " position when opening a file.
  au BufReadPost *
    \ if line("'\"") > 1 && line("'\"") <= line("$") |
    \   exe "normal! g`\"" |
    \ endif

  if has("unix")
  " au FileType coffee set makeprg=coffee\ -c\ %
  " auto compile coffee files silently but show errors add '| redraw!' for
  " au BufWritePost coffee silent CoffeeMake! -b | cwindow | redraw! 
    au BufWritePost,FileWritePost *.co,*.coffee !cat <afile> | coffee -scb 2>&1 
  " au BufWritePost,FileWritePost coffee :silent !coffee -c <afile> 
	au BufWritePost,FileWritePost *.co,*.coffee CompileCoffeeProject
  elseif has("win32") || has("win64")
	au BufWritePost,FileWritePost *.co,*.coffee CompileCoffeeProject
  endif

  " autoload vimrc if it has been changed
  au BufWritePost *.vimrc,_vimrc so %

  aug END

  " color magic
  set background=dark
  colorscheme desert
  highlight Pmenu guifg='Black' guibg='White'
  highlight PmenuSel guifg='Black' guibg='Gray'

else
  set autoindent		" always set autoindenting on
endif " has("autocmd")

" Convenient command to see the difference between the current buffer and the
" file it was loaded from, thus the changes you made.
" Only define it when not defined already.
if !exists(":DiffOrig")
  command DiffOrig vert new | set bt=nofile | r # | 0d_ | diffthis
		  \ | wincmd p | diffthis
endif

" switch to the users Home dir instead of the systems root
" or switch to my windows project dir
if has("win32") || has("win64")
  cd E:\projects
else
  cd $HOME
endif

