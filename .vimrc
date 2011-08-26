"
"
" Author:       Uwe Jugel <uwe.jugel@googlemail.com>
" Last change:  2011 Aug 17
"
"

" This must be first, because it changes other options as a side effect.
set nocompatible

function! FindCoffeeProject(...)
	if a:0 == 0                                 " inital call: call self on current file
		return call("FindCoffeeProject", [expand("%:p:h")] )
	elseif a:0 == 1                             " simple call: start recursion with argument 1
		if isdirectory(expand(a:1))
			return call("FindCoffeeProject", [1, expand(a:1)] )
		elseif filereadable(expand(a:1))
			return call("FindCoffeeProject", [1, matchstr( expand(a:1), ".*/" )] )
		else
			echo "Path not found: " a:1
		endif
	elseif a:0 == 2 && a:1 < &maxfuncdepth - 10 " stop recursion BEFORE maxdepth (100) is reached
		let l:success = isdirectory(a:2."/.hotcoffee") " test if dir contians the 'src' dir
		if l:success                            " return found dir or recurse once more
			return a:2
		else
			return call("FindCoffeeProject", [ a:1 + 1, a:2."/.."] )
		endif
	else
		echo "Could not locate project directory"
		echo "see ~/.vimrc#FindCoffeeProject for details"
	endif
	return
endfunction
command! -nargs=* FindCoffeeProject :call FindCoffeeProject(<f-args>)

function! CompileCoffeeProject(...)
	let l:pdir  = call("FindCoffeeProject", []) " find the 'src' dir; your coffee project should contain one
	let l:error = ''                            " empty error == success ;)
	cgetexpr ''                                 " clear cwindow
	if isdirectory(l:pdir."/src")               " double check if the 'src' dir there
		if filereadable(l:pdir."/build.js")     " check if build.js exisits
			" echo "Compiling coffee files"
			" build the project and get errors
			exec 'cd '.l:pdir
			let l:output = system('node build.js')
			" echo l:output
			let l:result = ""
			for item in split(l:output, '\n')
				if match( item, '^Error: In' ) >= 0
					let l:line = substitute( item, '.* line \(\d*\).*', '\1', 'g')
					let l:file = substitute( item, '^Error: In \([^,]*\),.*', '\1', 'g' )
					let l:text = substitute( item, '^Error: In .*line \d*[\s:]*\(.*\)$', '\1', 'g' )
					let l:result .= l:pdir.'/'.l:file.'|'.l:line.'| '.l:text.'\n'
					" let l:result .= l:pdir.'/'.substitute( item,'Error: In \(.*\),\(.*\),.*line \(\d*\)', '\1|\3| \2','g')."\n"
				elseif match( item, '^[a-zA-Z]*Error:' ) >= 0
					let l:result .= item."\n"   " also grep other errors. TODO: support more error types
				endif
			endfor
			if strlen(l:result) > 0
				let l:error = l:result
			endif 
		else
			let l:error = "Compile error! Buildfile not found. Please create $PROJECT/build.js."
		endif
	else
		let l.error = "Compile error! Project dir not found. Please create $PROJECT/src."
	endif
	if strlen(l:error) > 0      " check if error is empty. otherwise assume success
		cgetexpr l:error        " pipe error into cwindow
		copen                   " open cwindow (usually only opens if it has errors)
	else
		cclose
		echo "Build successful"
	endif
endfunction
command! -nargs=* CompileCoffeeProject :call CompileCoffeeProject(<f-args>)

" load plugin bundles via pathogen
filetype off
call pathogen#runtime_append_all_bundles()
filetype on

set keywordprg=:help

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
	set backupdir=$VIM/backup  " store backups centrally
	set directory=$VIM/tmp     " store swaps centrally
endif

" basics
set history=1000      " keep 1000 lines of command line history
set undolevels=1000   " keep 1000 undolevels
set ruler             " show the cursor position all the time
set showcmd           " display incomplete commands
set noshowmatch       " display bracket matches
set incsearch         " do incremental searching
set hlsearch          " highlight search results
set ignorecase        " ignore case
set tabstop=4         " change tab from 8 to 4
set softtabstop=4     " allow fine grained soft tabs while keeping real tabs stable
set shiftwidth=4      " set default shift width used for cindent, >>, and <<
set foldcolumn=4      " always show left code folding column
set foldmethod=syntax " use space to fold/unfold code; use syntax or indent
set novisualbell      " disable blinking terminals
set noerrorbells      " disable any beeps
set wrap              " do not wrap text
set linebreak         " smart brake if wrap is enabled 
set wrapmargin=0      " # of chars from RIGHT border where auto wrapping starts
set textwidth=0       " disable fixed text width
set smartindent       " allow smart indenting
set autoindent        " allow auto indenting (supported by smart indenting)
set scrolloff=7       " keep 7 lines visible from current line
set whichwrap+=b,<,>,[,] " let backspace and arrow keys move to next/prev line in vis and normal mode
set nolazyredraw      " Don't redraw while executing macros
set encoding=utf-8    " force UTF-8 also for windows
set guioptions+=a     " enable autocopy using mouse or visual. Works independently of :y[ank]

" With a map leader it's possible to do extra key combinations
" like <leader>w saves the current file
let mapleader=","
let g:mapleader=","
" Fast saving
nmap <leader>w :w!<cr>

" Fast editing of the .vimrc
if has("unix")
	map <leader>e :e! $HOME/.vimrc<cr>
elseif has("win32") || has("win64")
	map <leader>e :e! $VIM/_vimrc<cr>
endif

"Useful when moving accross long lines
map j gj
map k gk

" Tab configuration
map <leader>tn :tabnew! %<cr>
map <leader>te :tabedit
map <leader>tc :tabclose<cr>
map <leader>tm :tabmov

" When pressing <leader>cd switch to the directory of the open buffer
map <leader>cd :cd %:p:h<cr>e

set pastetoggle=<F3>        " Press F3 for toggle paste mode
nnoremap <leader>v "+gP     " Paste using ,v in normal mode

" map increase/decrease to new keys
nnoremap <C-kPlus> <C-A>
nnoremap <C-kMinus> <C-X>

" copied from $VIM/mswin.vim
" backspace in Visual mode deletes selection
vnoremap <BS> d

" CTRL-X and SHIFT-Del are Cut
vnoremap <C-X> "+x
vnoremap <S-Del> "+x

" CTRL-C and CTRL-Insert are Copy
vnoremap <C-C> "+y
vnoremap <C-Insert> "+y

" CTRL-V and SHIFT-Insert are Paste
map <C-V> "+gP
map <S-Insert> "+gP

cmap <C-V> <C-R>+
cmap <S-Insert> <C-R>+

" CTRL-A selects all
vnoremap <C-A> <ESC>ggvG
nnoremap <C-A> ggvG
inoremap <C-A> <ESC>ggvG

" some settings comments copied from:  https://github.com/yodiaditya/vim-netbeans/blob/master/.vimrc 
" TODO: copy more stuff later ;)

" key mappings:    F5: write, compile, check errors (normal AND insert mode)
" toggle mappings: F6: toggle spell checker, F7: toggle line wrap
" ESC mappings:    <ESC>l toggle control characters, <ESC>n toggle line numbers,
"                  <ESC><SPACE> unhighlight search results
"
nmap <F5> :CoffeeRun<CR>
" :w<CR>:make<CR>:cw<CR>
imap <F5> <ESC><F5>
nmap <F6> :set spell!<CR>
nmap <F7> :set wrap!<CR>
nmap <ESC>l :set list!<CR>
nmap <ESC>n :set number!<CR>
nmap <ESC><SPACE> :nohl<CR>
nmap <leader><SPACE> :nohl<CR>

" save file dialog mapped to <Ctrl-[Alt]-s>
nnoremap <C-A-s> :browse saveas<CR>
inoremap <C-A-s> <Esc>:browse saveas<CR>
nnoremap <C-s> :w<CR> 
inoremap <C-s> <Esc>:w<CR> 

" try to open file under cursor in new tab
" nnoremap <F3> :sp %:p:h/<cfile><CR>
" <F3> used for  pastetoggle

nnoremap <Esc>e :tabe %:p:h/<cfile><CR>

" allow pure Ctrl-w closing of windows
nnoremap <C-w><C-w> <C-w>q

" open file dialog mapped to <Esc>o and <A-o>
let g:browsefilter="All files\t*.*\n"
nmap <Esc>o :browse tabe<CR>
nmap <A-o> <Esc>o
imap <A-o> <Esc><Esc>o

" work on whole words. changes the whole word and not only its tails
" used for example with d, y, c, v, etc.
onoremap w iw
vnoremap w iw

" remap arrows to hjkl
noremap <left> h
noremap <right> l
noremap <up> gk
noremap <down> gj

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
imap <S-up> <ESC>vgk
imap <S-down> <ESC>vgj
" use remap to prevent old mapping (page up/down)
nnoremap <S-up> vgk
nnoremap <S-down> vgj

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
vnoremap <S-up> gk
vnoremap <S-down> gj
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
	map  <F8> <ESC>:set guifont=Monospace\ 8<CR>
	map  <F9> <ESC>:set guifont=Monospace\ 10<CR>
	map <F10> <ESC>:set guifont=Monospace\ 12<CR>
	map <F11> <ESC>:set guifont=Monospace\ 16<CR>
	map <F12> <ESC>:set guifont=Monospace\ 20<CR>
elseif has("win32") || has("win64")
	map  <F8> <ESC>:set guifont=DejaVu_Sans_Mono:h8:cANSI<CR>
	map  <F9> <ESC>:set guifont=DejaVu_Sans_Mono:h10:cANSI<CR>
	map <F10> <ESC>:set guifont=DejaVu_Sans_Mono:h12:cANSI<CR>
	map <F11> <ESC>:set guifont=DejaVu_Sans_Mono:h16:cANSI<CR>
	map <F12> <ESC>:set guifont=DejaVu_Sans_Mono:h20:cANSI<CR>
	set guifont=DejaVu_Sans_Mono:h10:cANSI
endif

" Don't use Ex mode, use Q for formatting
map Q gq
nnoremap <space> za
nnoremap <C-space> zi
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
	set lines=56 columns=137
else
	" This is console Vim.
	if exists("+lines")
		set lines=56
	endif
	if exists("+columns")
		set columns=137
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
			" au BufWritePost *.co,*.coffee silent CoffeeMake! -b | cwindow
			" au BufWritePost *.co,*.coffee silent CoffeeCompile | cwindow 
			" au BufWritePost,FileWritePost *.co,*.coffee !cat <afile> | coffee -scb 2>&1 
			" au BufWritePost,FileWritePost coffee :silent !coffee -c <afile>
			" au BufNewFile,BufReadPost *.co,*.coffee setl foldmethod=indent nofoldenable
			au BufWritePost,FileWritePost *.co,*.coffee CompileCoffeeProject | cwindow
			" au BufWritePost,FileWritePost *.mycode CompileMyCode 
		elseif has("win32") || has("win64")
			"	au BufWritePost,FileWritePost *.co,*.coffee CompileCoffeeProject
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
	highlight Search guibg='Purple' guifg='NONE'

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

