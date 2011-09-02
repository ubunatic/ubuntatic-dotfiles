"
"
" Author:       Uwe Jugel <uwe.jugel@googlemail.com>
" Last change:  2011 Aug 17
"
"

set nocompatible " This must be first, because it changes other options as a side effect.

function! HotCoffeeFindProject(...)
	if a:0 == 0                                 " inital call: call self on current file
		return call("HotCoffeeFindProject", [expand("%:p:h")] )
	elseif a:0 == 1                             " simple call: start recursion with argument 1
		if isdirectory(expand(a:1))
			return call("HotCoffeeFindProject", [1, expand(a:1)] )
		elseif filereadable(expand(a:1))
			return call("HotCoffeeFindProject", [1, matchstr( expand(a:1), ".*/" )] )
		else
			echo "Path not found: " a:1
		endif
	elseif a:0 == 2 && a:1 < &maxfuncdepth - 10 " stop recursion BEFORE maxdepth (100) is reached
		let l:success = isdirectory(a:2."/.hotcoffee") " test if dir contians the 'src' dir
		if l:success                            " return found dir or recurse once more
			return a:2
		else
			return call("HotCoffeeFindProject", [ a:1 + 1, a:2."/.."] )
		endif
	else
		echo "Could not locate project directory"
		echo "see ~/.vimrc#HotCoffeeFindProject for details"
	endif
	return
endfunction
command! -nargs=* HotCoffeeFindProject :call HotCoffeeFindProject(<f-args>)

function! HotCoffeeGoto(...)
	if a:0 == 0
		return 0                                " no file specified
	elseif a:0 >= 1                             " one filesearch string specified
		let l:file = expand("%:p:h")."/".a:1    " save full path of filesearch string
		if filereadable(l:file.".co")           " try to read filesearch.co
			let l:file = l:file.".co"           "   found it: save it!
		elseif filereadable(l:file.".coffee")   " try to read filesearch.coffee
			let l:file = l:file.".coffee"       "   found it: save it!
		elseif filereadable(l:file)             " try to read filesearch (no extension)
			let l:file = l:file                 "   found it: save it!
		else                                    " no files found, assuming you want to create a new file
			if expand("%:e") == "co"            " check which type of file ext you are cirrently using
				let l:file = l:file.".co"       " and use it for the new file
			else
				let l:file = l:file.".coffee"
			endif
		endif                                    " open the found (or empty/new) file
		exec ":e ".l:file                       
	endif
endfunction
command! HotCoffeeGoto :call HotCoffeeGoto(expand("<cfile>"))

function! HotCoffeeInit()
	noremap <buffer> gf :HotCoffeeGoto<CR>
endfunction

function! HotCoffeeCompile(...)
	let l:pdir  = call("HotCoffeeFindProject", []) " find the 'src' dir; your coffee project should contain one
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
				elseif match( item, '^[a-zA-Z]*[Ee]*rror:' ) >= 0
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
command! -nargs=* HotCoffeeCompile :call HotCoffeeCompile(<f-args>)

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
set foldmethod=indent " use space to fold/unfold code; use syntax or indent
set foldminlines=8    " do not fold small blocks
set novisualbell      " disable blinking terminals
set noerrorbells      " disable any beeps
set wrap              " do not wrap text
set linebreak         " smart brake if wrap is enabled
set wrapmargin=0      " # of chars from RIGHT border where auto wrapping starts
set textwidth=0       " disable fixed text width
set smartindent       " allow smart indenting
set autoindent        " allow auto indenting (supported by smart indenting)
set scrolloff=7       " keep 7 lines visible from current line
set sidescrolloff=10  " keep 10 chars visible from current column
set whichwrap+=b,<,>,[,] " let backspace and arrow keys move to next/prev line in vis and normal mode
set nolazyredraw      " Don't redraw while executing macros
set encoding=utf-8    " force UTF-8 also for windows
set fileencoding=utf-8 " set encoding when writing files
set guioptions+=a     " enable autocopy using mouse or visual. Works independently of :y[ank]
set cpoptions+=$      " indicate change ranges with a $-sign
set virtualedit=all   " allow moving in non-text areas
set wildmenu          " show completion for menu entries, :*TAB
set mousehide         " hide mouse when typing, move it to show again
set report=0          " always report if a command changes some lines
set laststatus=2      " always keep a status line for the last window
set shellslash        " always convert backslash path chars to forward slashes
set shortmess=at      " truncate and abbreviate shell messages
set ttyfast           " indicate fast terminal: better/smooth scrolling, extra screenline characters??
set guioptions-=m     " remove menu bar
set guioptions-=T     " remove toolbar
set guioptions-=r     " remove right-hand scroll bar
set autoindent        " always set autoindenting on

" Plug options:
let g:EasyGrepRecursive=1     "Enable recusrive search. Be careful when using Grep from $HOME, etc.

"-- Status Line ---- adopted from https://github.com/nocash/vim-rc.git --------------------------------
"                +-> Relative file path
"                | +-> Help buffer flag
"                | | +-> Filetype
"                | | | +-> Readonly flag
"                | | | | +-> Modified flag
"                | | | | | +-> Left/right alignment separator
set statusline=%f\ %h%y%r%m%=

" Warn on syntax errors
" set statusline+=%#warningmsg#%{SyntasticStatuslineFlag()}%*

" Warn if fileformat isn't Unix
set statusline+=%#warningmsg#%{&ff!='unix'?'['.&ff.']':''}%*

" Warn if file encoding isn't UTF-8
set statusline+=%#warningmsg#%{(&fenc!='utf-8'&&&fenc!='')?'['.&fenc.']':''}%*

" Warn if expandtab is wrong or there is mixed indenting
" set statusline+=%#warningmsg#%{StatuslineTabWarning()}%*
" set statusline+=%#warningmsg#%{StatuslineTrailingSpaceWarning()}%*

" Warn if paste is enabled
set statusline+=%#warningmsg#%{&paste?'[paste]':''}%*

"               +-> Column number
"               | +-> Line number
"               | | +-> Percentage through file
set statusline+=\ %c,%l\ %P

" With a map leader it's possible to do extra key combinations
" like <leader>w saves the current file
let mapleader=","
let g:mapleader=","
" Fast saving nmap <leader>w :w!<cr>

" Fast editing of the .vimrc
if has("unix")
	map <leader>ev :e! $HOME/.vimrc<cr>
elseif has("win32") || has("win64")
	map <leader>ev :e! $VIM/_vimrc<cr>
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
nnoremap <leader>p "+gP     " Paste using ,p in normal mode
nnoremap <leader>c "+y      " Copy using ,c in normal mode
nnoremap <leader>y "+y      " Copy using ,y in normal mode

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
" map <C-V> "+gP
" don't this we need C-V for linewise editing

map <S-Insert> "+gP

cmap <C-V> <C-R>+
cmap <S-Insert> <C-R>+

" CTRL-A selects all
vnoremap <C-A> <Esc>ggvG$
nnoremap <C-A> ggvG$
inoremap <C-A> <Esc>ggvG$

" use ^ as additional <Esc>
map ^ <Esc>
inoremap ^ <Esc>
inoremap <C-^> ^

" easy access to @
map <A-q> @

" Re-select visual area after indenting
vnoremap > >gv
vnoremap < <gv

" some settings comments copied from:  https://github.com/yodiaditya/vim-netbeans/blob/master/.vimrc
" TODO: copy more stuff later ;)

" key mappings:    F5: write, compile, check errors (normal AND insert mode)
" toggle mappings: F6: toggle spell checker, F7: toggle line wrap
" ESC mappings:    <ESC>l toggle control characters, <ESC>n toggle line numbers,
"                  <ESC><SPACE> unhighlight search results

" generate html of current view and copy html code
nmap <C-h> :runtime syntax/2html.vim<cr>ggvG$"+x

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
" map <C-ü> <C-[>
" map <C-Ü> <C-{>
" map <C-ä> <C-]>
" map <C-Ä> <C-}>
map ö ;
map Ö :
map ä ]
map Ä }
map ü [
map Ü {

" use old english 'search key' on german layout (first key left of R-Shift)
noremap - /
noremap ß _
noremap _ ?

" escape out of insert mode using Shift+Enter
imap <S-CR> <ESC>
vnoremap <S-CR> <ESC>

nnoremap d<S-Space> :%s/\s\+$//gc<CR>
nnoremap d<Space> $a<space><Esc>diw$

" In many terminal emulators the mouse works just fine, thus enable it.
if has('mouse')
	set mouse=a
endif

if has("gui_running")
	" GUI is running or is about to start.
	" Maximize gvim window.
	set lines=61 columns=138
else
	" This is console Vim.
	if exists("+lines")
		set lines=61
	endif
	if exists("+columns")
		set columns=138
	endif
endif

" Only do this part when compiled with support for autocommands.
if has("autocmd")

	" Enable file type detection.
	" Use the default filetype settings, so that mail gets 'tw' set to 72,
	" 'cindent' is on in C files, etc.
	" Also load indent files, to automatically do language-dependent indenting.


	filetype plugin indent on


	highlight link localWhitespaceError Error

 	" color magic
	set background=dark
	colorscheme molokai
	highlight Pmenu guifg='Black' guibg='White'
	highlight PmenuSel guifg='Black' guibg='Gray'
	highlight Search guibg='Purple' guifg='NONE'

	" Put these in an autocmd group, so that we can delete them easily.
	aug vimrcEx
		au!
		" highlight ExtraWhitespace ctermbg=red guibg=red
		" match ExtraWhitespace /\s\+$/
		" au InsertEnter * syntax match ExtraWhitespace /\s\+\%#\@<!$/
		" au InsertLeave * sytax match ExtraWhitespace /\s\+$/
		" au BufLeave * call clearmatches()

		" au VIMEnter * winpos 0,0
		au GUIEnter * winpos 0 0

	    au BufWrite,Syntax * syntax match localWhitespaceError /\s\+$/ display

		" add coffee files to autocomplete
		au BufNewFile,BufRead *.co set filetype=coffee
		au BufNewFile,BufRead *.co,*.coffee :call HotCoffeeInit()

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

		" au FileType coffee set makeprg=coffee\ -c\ %
		" auto compile coffee files silently but show errors add '| redraw!' for
		" au BufWritePost *.co,*.coffee silent CoffeeMake! -b | cwindow
		" au BufWritePost *.co,*.coffee silent CoffeeCompile | cwindow
		" au BufWritePost,FileWritePost *.co,*.coffee !cat <afile> | coffee -scb 2>&1
		" au BufWritePost,FileWritePost coffee :silent !coffee -c <afile>
		" au BufNewFile,BufReadPost *.co,*.coffee setl foldmethod=indent nofoldenable
		au BufWritePost,FileWritePost *.co,*.coffee HotCoffeeCompile

		" autoload vimrc if it has been changed
		au BufWritePost *.vimrc,_vimrc so %

	aug END
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

