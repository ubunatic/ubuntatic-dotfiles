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
	elseif a:0 == 2 && a:1 < &maxfuncdepth - 1       " stop recursion BEFORE maxdepth (100) is reached
		if isdirectory(a:2."/src")                   " test if dir contians the 'src' dir
			\ || filereadable(a:2."/Cakefile")       " test if a Cakefile exists
			\ || filereadable(a:2."/Makefile")       " test if a Nakefile exists
			\ || filereadable(a:2."/build.js")       " test if a build.js exists
			\ || filereadable(a:2."/.project")       " test if a .project exists
			return a:2
		else
			return call("HotCoffeeFindProject", [ a:1 + 1, a:2."/.."] )  " increase recursion depth and recall
		endif
	else
		echo "Could not locate project directory"
		echo "see ~/.vimrc#HotCoffeeFindProject for details"
	endif
	return
endfunction
command! -nargs=* HotCoffeeFindProject :call HotCoffeeFindProject(<f-args>)

function! HotCoffeeGetFilePlainJS( path )
	if match( a:path, '\.js$') == -1                               " if no .js repeat match with 'a:path'.js
		let l:file =  HotCoffeeGetFilePlainJS( a:path.".js" )
	else
		if filereadable( a:path )                                  " test if it existis (plain path)
			let l:file = a:path
		else
			let l:pdir = HotCoffeeFindProject()
			if filereadable( l:pdir."/".a:path )                   " test if is exists in project dir
				let l:file = l:pdir."/".a:path
			elseif filereadable( l:pdir."/lib/".a:path )           " test if is exists in 'lib' dir
				let l:file = l:pdir."/lib/".a:path
			else                                                   " JavaScript file not found
				let l:file = ""
			endif
		endif
	endif
	return l:file
endfunction

function! HotCoffeeGetFileJS( path )
	let l:file = ""
	let l:jsfile = HotCoffeeGetFilePlainJS( a:path )               " get direct link to JavaScript <cfile>
	let l:cofile = HotCoffeeGetFile( a:path )                      " get default link to CoffeeScript <cfile>
	if filereadable( l:jsfile )                                    " JavaScript file found for <cfile>
		let l:file = l:jsfile
	elseif filereadable( l:cofile )                                  " CoffeeScript file found fo <cfile>
		let l:jsfile = substitute( l:cofile, '\(^.*\)/src/\(.*\)\.co[fe]*', '\1/lib/\2.js', '')
		let l:jsfile = HotCoffeeGetFilePlainJS( l:jsfile )              " get link to  JavaScript <cfile>
		" if filereadable( l:jsfile )
		" 	let l:file = l:jsfile
		" else
		" 	let l:file = ""
		" endif
		let l:file = l:jsfile
	endif
	return l:file
endfunction

function! HotCoffeeGotoJS( path )
	let l:jsfile = HotCoffeeGetFileJS( a:path )
	let l:lofile = HotCoffeeGetFileJS( expand("%:p") )
	let l:file = ""
	if filereadable( l:jsfile )
		let l:file = l:jsfile
	elseif filereadable( l:lofile )
		let l:file = l:lofile
	endif

	if empty(l:file)
		echo "JavaScript file not found for pattern '".l:file."'"
	else
		"DEBUG: echo a:path.": '".l:jsfile."' -- ".expand("%:p").": '".l:lofile."'"
		exec ":vsplit ".l:file
		"removed, TODO: check if this works  ." | lcd %:p:h"
	endif
endfunction
command! HotCoffeeGotoJS :call HotCoffeeGotoJS(expand("<cfile>"))

" HotCoffeeGetFile returns full paths for different file lookups
" It uses `a:path` to find (in this order):
"
" 1. direct match                                      (if readable)
" 2. relative .co file                                 (if readable)
" 3. relative .coffee file                             (if readable)
" 4. relative file (matching `a:path`)                 (if readable)
" 5. project-relative file (matching `a:path`)         (if readable)
" 6. new relative .co file (if current file is .co)
" 7. new relative .coffee file
function! HotCoffeeGetFile( path )
	if empty(a:path)
		return ""
	elseif filereadable( a:path )                   " check if a:path is a direct link
		return a:path
	else
		let l:file = expand("%:p:h")."/".a:path     " save full path of filesearch string
		if filereadable(l:file.".co")               " try to read filesearch.co
			let l:file = l:file.".co"               "   found it!
		elseif filereadable(l:file.".coffee")       " try to read filesearch.coffee
			let l:file = l:file.".coffee"           "   found it!
		elseif filereadable(l:file)                 " try to read filesearch (no extension)
			let l:file = l:file                     "   found it!
		else
			let l:pdir = HotCoffeeFindProject()
			if filereadable(l:pdir."/".a:path)      " try to read project related asset file
				let l:file = l:pdir."/".a:path      "   found it!
			else                                    " no files found, assuming you want to create a new file
				if expand("%:e") == "co"            " check which type of file ext you are cirrently using
					let l:ext = ".co"               " and use it for the new file
				else
					let l:ext = ".coffee"
				endif
				let l:file = l:file.l:ext
			endif
		endif
		return l:file                               " return the found (or empty/new) file
	endif
endfunction

function! HotCoffeeGetOtherFile( path )
	if filereadable( a:path )
		if match( a:path, '\.js$') >= 0             " return coffee file for a:path JS file
			return substitute(a:path, '\(^.*\)/lib/\(.*\)\.js$', '\1/src/\2.co', 'g')
		endif
	endif
	return a:path
endfunction

function! HotCoffeeGoto( path )
	let l:file = HotCoffeeGetFile( a:path )
	if !empty(l:file)
		"edit the file, use :e file OR :tab drop file
		if filereadable(l:file)
			echo "opening ".l:file
			exec ':e '.l:file
		else
			if confirm("Creating new file:\n".l:file."\n\n(Press ESC to cancel)")
				echo "creating new file '".l:file."'"
				exec ':e '.l:file
			else
				echo "'".l:file."' not created"
			endif
		endif
	else
		echo "File not found: ".l:file
	endif
endfunction
command! HotCoffeeGoto :call HotCoffeeGoto(expand("<cfile>"))

function! HotCoffeeRunJasmine()
		let l:pdir = HotCoffeeFindProject()
		let l:cwd = getcwd()
		exec 'cd '.l:pdir
		exec '! jasmine-node --coffee --noColor spec'
		exec 'cd '.l:cwd
endfunction
command! HotCoffeeRunJasmine :call HotCoffeeRunJasmine()

function! HotCoffeeInit()
	setlocal filetype=coffee
	"set noexpandtab
	setlocal tabstop=2 shiftwidth=2 softtabstop=2
	noremap <buffer> gf  :HotCoffeeGoto<CR>
	noremap <buffer> gfc :HotCoffeeGoto<CR>
	noremap <buffer> gfj :HotCoffeeGotoJS<CR>
	let pdir = HotCoffeeFindProject()
	let $APP = pdir
	if isdirectory($APP."/spec")
		map <buffer>  <F5> :HotCoffeeRunJasmine<CR>
		imap <buffer> <F5> <ESC>:HotCoffeeRunJasmine<CR>
	endif
	" let coffee_make_options = '-p'
	" exec 'lcd '.pdir
	" coffee-script-vim does not like changed dirs -> call HotCoffeeFindProject manually
	" append this for debugging: .' | cexpr "switching to '.pdir.'" | copen'

	" does not work correctly when opening via gvim --remote-tab
	" therefore, all HotCoffee scripts will make no assumptions on the pwd
	" but search for the correct project path

	" let g:EasyGrepMode=2
	" EasyGrep is broken with *.co *.coffee, I could not figure out what was wrong
	" using a custom grep based on vimgrep instead
endfunction

" search in pwd using vimgrep
" searches only in files with same extension
function! HotCoffeeGrep(...)
	if a:0 <= 0
		throw "HotCoffeeGrep: wrong usage, I need arguments"
		return
	else
		let pattern = '/'.expand("<cword>").'/'
		if match( a:1, "class") != -1
			" matches: any 'class <ClassName>' OR lines starting with <ClassName> = do
			" the latter is used for 'static classes' containing consts, etc.
			let pattern = '/[^a-zA-Z0-9_]class.*'.expand("<cword>").'\|'.expand("<cword>").'\s*=\s*do/g'
			" let pattern = '/[^a-zA-Z0-9_]class\s\s*'.expand("<cword>").'\s*$\|[^a-zA-Z0-9_]'.expand("<cword>").'\s*=/g'
			" '/^.*'.expand("<cword>").'\s*[=:]\s*do\|^.*class\s*'.expand("<cword>").'\s*$/'
		elseif match( a:1, "prop") != -1
			" matches: '@<name> =' OR '@<name> :' OR '<name>:'
			" the @<name> syntax is the default for properties
			" the <name>: is used for properties in object notation
			" TODO: add detection for a = { b: } inline assignments
			let pattern = '/[@\.]'.expand("<cword>").'\s*[:=]\|^\s*'.expand("<cword>").'\s*:/'
		elseif match( a:1, "ref" ) != -1
			" similar to property match, but adds '{ <name> }' to detect destructuring assignment
			let pattern = '/[@\.]'.expand("<cword>").'\|^\s*'.expand("<cword>").'\s*:\|{.*'.expand("<cword>").'.*}/'
		endif
		let l:pdir = HotCoffeeFindProject()
		let l:cwd = getcwd()
		let l:grepcmd = 'silent lvimgrep '.pattern.'j ./**/*.'.expand("%:e")
		try
			" the j flag only fills the lwindow instead of opening
			" cd pdir is used to reduce path names in lwindow
			"exec 'cd '.l:pdir.' | '.
			exec 'cd '.l:pdir.' | '.l:grepcmd
			".' | lopen | cd '.l:cwd
		catch /E315/
			" TODO: check funny E315 line number errors. (the try block still works though)
		catch /E480/
			lexpr 'E480, no match for "'.pattern.'", greptype: '.a:1
			ladd  'grepcmd '.l:grepcmd.'
			ladd  'in      '.l:pdir
		endtry
		" the cwd trick allows to use short path names and still make all refs from lwindow work fine
		lopen
		exec 'cd '.l:cwd
		" ladd  'grep '.l:grepcmd
		" ladd  'in   '.l:pdir
	endif
endfunction
command! -nargs=* HotCoffeeGrep :call HotCoffeeGrep(<f-args>)

function! HotCoffeeComplete()
	if !pumvisible()
		" - start complete when '.' is pressed
		" - get inital list
	endif
	" temporary map keys using loop
	" (see https://bitbucket.org/ns9tks/vim-autocomplpop/)
	" - attach TAB/UP/DOWN completion to cycle through list
	" - close popup on ENTER/ESC
	" - close current and trigger new popup on '.'

	" - reduce intital list when typing [a-zA-Z_0-9@$]
	" - updated list
endfunction
command! -nargs=0 HotCoffeeComplete :call HotCoffeeComplete()

" function! HotCoffeeCompile(...)
	" 	let l:pdir  = HotCoffeeFindProject()      " find the 'src' dir; your coffee project should contain one
	" 	let l:error = ''                            " empty error == success ;)
	" 	cgetexpr ''                                 " clear cwindow
	" 	if isdirectory(l:pdir."/src")               " double check if the 'src' dir there
	" 		if filereadable(l:pdir."/build.js")     " check if build.js exisits
	" 			" echo "Compiling coffee files"
	" 			" build the project and get errors
	" 			exec 'lcd '.l:pdir
	" 			let l:output = system('node build.js')
	" 			" echo l:output
	" 			let l:result = ''
	" 			let l:code = ''
	" 			let l:lastitem = ''
	" 			for item in split(l:output, '\n')
	" 				if match( item, '^\s*^\s*$' ) >= 0     " found code pointer ^, marking above text
	" 					let l:code = substitute( l:lastitem, '^\s*\(.*\)\s*$', '\1', 'g')
	" 				elseif match( item, '^Error: In' ) >= 0
	" 					" find coffeescript errors
	" 					let l:line = substitute( item, '.* line \(\d*\).*', '\1', 'g')
	" 					let l:file = substitute( item, '^Error: In \([^,]*\),.*', '\1', 'g' )
	" 					" let l:text = substitute( item, '^Error: In .*line \d*[\s:]*\(.*\)$', '\1', 'g' )
	" 					let l:text = substitute( item, '^Error: In [^,]*,\(.*\)$', '\1', 'g' )
	" 					let l:result .= l:pdir.'/'.l:file.'|'.l:line.'| '.l:text
	" 					if !empty(l:code)
	" 						let l:result .= ', '.l:code
	" 						let l:code = ''
	" 					endif
	" 					let l:result .= "\n"
	" 					" let l:result .= l:pdir.'/'.substitute( item,'Error: In \(.*\),\(.*\),.*line \(\d*\)', '\1|\3| \2','g')."\n"
	" 				elseif match( item, '^[a-zA-Z\s]*[Ee]*rror:' ) >= 0
	" 					" also grep other errors. TODO: support more error types
	" 					let l:text = item
	" 					if !empty(l:code)
	" 						let l:text .= ', '.l:code
	" 						let l:code = ''          " clear code for later use
	" 					endif
	" 					let l:error = l:item
	" 				elseif !empty(l:error)
	" 					" find node.js errors
	" 					let l:file = substitute( item, '^\s*at \([^:]*\):.*', '\1', 'g' )
	" 					if !empty(l:file) && filereadable(l:file)
	" 						let l:line = substitute( item, '.*:\(\d*\):.*', '\1', 'g')
	" 						let l:result .= HotCoffeeGetOtherFile(l:file).'|'.l:line.'| '.l:text."\n"
	" 						let l:error = ''         " clear error flag for tracking more errors
	" 					endif
	" 				endif
	" 				let l:lastitem = item
	" 			endfor
	" 			if strlen(l:result) > 0
	" 				let l:error = l:result
	" 			endif
	" 		else
	" 			let l:error = "Compile error! Buildfile not found. Please create $PROJECT/build.js."
	" 		endif
	" 	else
	" 		let l.error = "Compile error! Project dir not found. Please create $PROJECT/src."
	" 	endif
	" 	if strlen(l:error) > 0      " check if error is empty. otherwise assume success
	" 		cgetexpr l:error        " pipe error into cwindow
	" 		copen                   " open cwindow (usually only opens if it has errors)
	" 	else
	" 		cclose
	" 		echo "Build successful"
	" 	endif
" endfunction
" command! -nargs=* HotCoffeeCompile :call HotCoffeeCompile(<f-args>)


" load plugin bundles via pathogen
filetype off
set nocp
" set rtp+=/path/to/rtp/that/included/pathogen/vim " if needed
call pathogen#infect()
syntax on
filetype plugin indent on

" call pathogen#runtime_append_all_bundles()
" filetype on

set keywordprg=:help

" allow backspacing over everything in insert mode
set backspace=indent,eol,start

if has("vms")
	set nobackup    " do not keep a backup file, use versions instead
else
	set backup      " keep a backup file
endif

" avoid messing up source folders with backup files
" if has("unix")
set backupdir=$HOME/.vim/backup  " store backups centrally
set directory=$HOME/.vim/tmp     " store swaps centrally
"elseif has("win32") || has("win64")
"	set backupdir=$VIM/backup  " store backups centrally
"	set directory=$VIM/tmp     " store swaps centrally
"endif

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
set nowrap            " do not wrap text
set noexpandtab       " do not use spaces for tabs, TABS rule!
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
set virtualedit=insert,block,onemore " allow moving in non-text areas
set wildmenu          " show completion for menu entries, :*TAB
set mousehide         " hide mouse when typing, move it to show again
set report=0          " always report if a command changes some lines
set laststatus=2      " always keep a status line for the last window
set shellslash        " do not convert backslash path chars to forward slashes ATTENTION:(luac may need noshellslash)
set shortmess=at      " truncate and abbreviate shell messages
set ttyfast           " indicate fast terminal: better/smooth scrolling, extra screenline characters??
set guioptions-=m     " remove menu bar
set guioptions-=T     " remove toolbar
set guioptions-=r     " remove right-hand scroll bar
set autoindent        " always set autoindenting on
set hidden            " allow buffer switches from unsaved files.
set switchbuf=usetab  " respect open tabs when swtiching buffers

set laststatus=2              " always show ths status line
let g:buftabs_only_basename=1 " show only the filename in as buftab label
let g:buftabs_in_statusline=1 " always show open files in status line

let tlist_coffee_settings = 'coffee;c:class;v:variable;f:function'

" EasyGrep is broken with *.co *.coffee, disabled it for now
" let g:EasyGrepRecursive=1     "Enable recusrive search. Be careful when using Grep from $HOME, etc.
" let g:EasyGrepMode=2          "Set Grep to use only specific filetypes

"-- Status Line ---- adopted from https://github.com/nocash/vim-rc.git --------------------------------
"                +-> Relative file path
"                | +-> Help buffer flag
"                | | +-> Filetype
"                | | | +-> Readonly flag
"                | | | | +-> Modified flag
"                | | | | | +-> Left/right alignment separator
set statusline=%f\ %h%y%r%m%=

" adding buftabs to the status line
set statusline+=%{buftabs#statusline()}

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
" if has("unix")
map <leader>ev :e! $HOME/.vimrc<cr>
" elseif has("win32") || has("win64")
"	map <leader>ev :e! $VIM/_vimrc<cr>
"endif

map <leader>b :FufFileWithCurrentBufferDir **/<C-M>
map <leader>bb :FufBuffer<C-M>

" f/fw: find word, fc: find class, fp: find property, fu/fr: find usings/references
nnoremap <leader>ff :HotCoffeeGrep word<CR>
nnoremap <leader>fw :HotCoffeeGrep word<CR>
nnoremap <leader>fc :HotCoffeeGrep class<CR>
nnoremap <leader>fp :HotCoffeeGrep prop<CR>
nnoremap <leader>fu :HotCoffeeGrep ref<CR>
nnoremap <leader>fr :HotCoffeeGrep ref<CR>

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

set pastetoggle=<C-F3>        " Press F3 for toggle paste mode
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

" nnoremap <S-I> $_<S-I>

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

" use C-V and Shift-Ins as paste
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
imap <A-q> @

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

vnoremap <F4> :CoffeeCompile vert<CR>
nnoremap <F4> :CoffeeCompile vert<CR>
nmap <F5> :CoffeeRun<CR>
" :w<CR>:make<CR>:cw<CR>
imap <F5> <ESC><F5>
vmap <F5> :CoffeeRun<CR>
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

nnoremap <Esc>e :tabe %:p:h/<cfile><CR>

" open file dialog mapped to <Esc>o and <A-o>
let g:browsefilter="All files\t*.*\n"
nmap <Esc>o :browse tabe<CR>
nmap <A-o> <Esc>o
imap <A-o> <Esc><Esc>o

" work on whole words. changes the whole word and not only its tails
" used for example with d, y, c, v, etc.
onoremap w iw
vnoremap w iw

" <end> moves one char right
" (works only if virtualedit is set to onemore or all)
nnoremap <end> <end>l

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
imap <S-home> <ESC>v<home>
imap <S-end> <ESC>v$
nmap <S-home> v<home>
nmap <S-end> v$

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
map <S-q> gq
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
noremap <HOME> _

" escape out of insert mode using Shift+Enter
imap <S-CR> <ESC>
vnoremap <S-CR> <ESC>

nnoremap d<S-Space> :%s/\s\+$//gc<CR>
nnoremap d<Space> $a<space><Esc>diw$

" map del/backspace to start insert mode from normal mode
nnoremap <del> i<del>
nnoremap <bs> i<bs>

" In many terminal emulators the mouse works just fine, thus enable it.
if has('mouse')
	set mouse=a
endif

if has("gui_running")
	" GUI is running or is about to start.
	" Maximize gvim window.
	"if has("win32") || has("win64")
		" set fixed height in windows (vertical screen)
		"set lines=62
	"else
		" maximize window height in linux (wide tft)
		"set lines=999
	"endif
	set columns=195
else
	" This is console Vim.
	if exists("+lines")
		set lines=62
	endif
	if exists("+columns")
		set columns=195
	endif
endif

" Only do this part when compiled with support for autocommands.
if has("autocmd")

	" Enable file type detection.
	" Use the default filetype settings, so that mail gets 'tw' set to 72,
	" 'cindent' is on in C files, etc.
	" Also load indent files, to automatically do language-dependent indenting.


	filetype plugin indent on


	" highlight link localWhitespaceError Error
	" highlight link localIndentError Error
	" highlight link ExtraWhitespace Ignore
	" highlight link ExtraWhitespace Error
	" highlight link BadWhitespaceError Ignore
	" highlight link ExtraWhitespace2 Error
	" highlight link ExtraWhitespace3 Error
	" highlight link ExtraWhitespace4 Error

	" color magic
	set background=dark
	colorscheme molokai2
	highlight Pmenu guifg='Black' guibg='White'
	highlight PmenuSel guifg='Black' guibg='Gray'
	highlight Search guibg='Purple' guifg='NONE'

	" The following comments are used for testing whitespace matching
  	" This line has wrong leading whitespace
	" This line has traling whitespace    
	" The line below has wrong leading whitespace
  	
	" The line below has a leading TABs (not highlighted)
		
	highlight BadWhitespace ctermbg=blue guibg=blue

	function! BadWhitespaceMatch()
		match BadWhitespace /[^\t ]\s\+$/
	endfunction

	function! BadWhitespaceMatchInsert()
		match BadWhitespace /[^\t ]\s\+\%#\@<!$/
	endfunction

	function! BadWhitespaceMatchCoffee()
		match BadWhitespace /[^\t ]\s\+$\|^\s* \s*/
	endfunction

	function! BadWhitespaceMatchCoffeeInsert()
		match BadWhitespace /[^\t ]\s\+\%#\@<!$\|^\s* \s*/
	endfunction

	function! JumpToCursor()
		if filereadable(expand("%")) > 0
			" do default cursor stuff (copied from example)
			if line("'\"") > 1 && line("'\"") <= line("$")
				exe "normal! g`\""
			endif
		endif
	endfunction

	" Put these in an autocmd group, so that we can delete them easily.
	aug vimrcEx
		au!

		" au VIMEnter * winpos 0,0
		if has("win32") || has("win64")
			" vertical monitor at work
			au GUIEnter * winpos 0 0 | set lines=62 | cd $HOME
		else
			" big wide tft at home
			au GUIEnter * winpos 336 0 | set lines=59 | cd $HOME
		endif

		" Highlight non-TAB leading whitespace and ALL traling whitespace
		" does NOT highlight TABs on empty lines, as prodiced by many tools
		au BufWinEnter,BufWrite,InsertLeave * call BadWhitespaceMatch()
		au InsertEnter * call BadWhitespaceMatchInsert()

		au BufWinEnter,BufWrite,InsertLeave *.co,*.coffee call BadWhitespaceMatchCoffee()
		au InsertEnter * call BadWhitespaceMatchCoffeeInsert()

		" au BufWinEnter,BufWrite,InsertLeave * match BadWhitespace /[^\t ]\s\+$\|^\s* \s*/
		" au InsertEnter * match BadWhitespace /[^\t ]\s\+\%#\@<!$\|^\s* \s*/

		au BufWinLeave * call clearmatches()
		" matching code adopted from http://vim.wikia.com/wiki/Highlight_unwanted_spaces
		
		" add coffee files to autocomplete
		" added BufWinEnter to force correct path detection in HotCoffeeInit
		" -> not using BufWinEnter sets the pwd to a wrong dir (base path)
		"
		" BufWinEnter called in gvim when entering tabs, windows, etc.
		" no other BufEnter, etc. needed (at least in gvim)
		au BufNewFile,BufReadPost,BufWinEnter *.co,*.coffee,Cakefile :call HotCoffeeInit()

		" For all text files set 'textwidth' to 78 characters.
		au FileType text setlocal textwidth=78
		"au FileType jade set noexpandtab
		"au FileType less set noexpandtab
		" tabstop=2 softtabstop=2 shiftwidth=2

		" When editing a file, always jump to the last known cursor position.
		" Don't do it when the position is invalid or when inside an event handler
		" (happens when dropping a file on gvim).
		" Also don't do it when the mark is in the first line, that is the default
		" position when opening a file.
		" au BufReadPost * :call JumpToCursor()

		" au FileType coffee set makeprg=coffee\ -c\ %
		" auto compile coffee files silently but show errors add '| redraw!' for
		" au BufWritePost *.co,*.coffee silent CoffeeMake! -b | cwindow
		" au BufWritePost *.co,*.coffee silent CoffeeCompile | cwindow
		" au BufWritePost,FileWritePost *.co,*.coffee !cat <afile> | coffee -scb 2>&1
		" au BufWritePost,FileWritePost coffee :silent !coffee -c <afile>
		" au BufNewFile,BufReadPost *.co,*.coffee setl foldmethod=indent nofoldenable
		" au BufWritePost,FileWritePost *.co,*.coffee silent CoffeeCompile
		au BufWritePost *.coffee silent CoffeeMake! -p | cwindow | redraw!
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

