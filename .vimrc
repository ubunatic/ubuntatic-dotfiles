" === Plugins ===

mapclear
mapclear!

set nocompatible
filetype off
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" let g:polyglot_disabled = ['go']

" common plugins, useful for all kinds of hosts
Plugin 'VundleVim/Vundle.vim'
" Plugin 'sheerun/vim-polyglot'
Plugin 'majutsushi/tagbar'
Plugin 'SyntaxRange'
Plugin 'scrooloose/nerdTree'
Plugin 'moll/vim-bbye'
Plugin 'tpope/vim-surround'
Plugin 'tpope/vim-markdown'
Plugin 'jtratner/vim-flavored-markdown'
Plugin 'Xuyuanp/nerdtree-git-plugin'
Plugin 'chriskempson/base16-vim'
" Plugin 'jiangmiao/auto-pairs' "does not handle dynamic reloads with my mappings

" let Vundle pull some non vim stuff
" TODO: move to .dotfiles/install.sh
Plugin 'chriskempson/base16-gnome-terminal'
Plugin 'chriskempson/base16-shell'
Plugin 'ctrlpvim/ctrlp.vim'
" Plugin 'dhruvasagar/vim-table-mode'
" Plugin 'chrisbra/NrrwRgn'
" Plugin 'ubunatic/colorizer'
" Plugin 'godlygeek/tabular'
" Plugin 'plasticboy/vim-markdown'

" === VIM Plugin Automation ===
"
if filereadable($HOME.'/.vimplugins')
	source $HOME/.vimplugins
endif
"
" create a file HOME/.vimplugins
" then customize it to define host-specific plugins
"
"
" automation examples:
"
" disable: sed -i "s/^[ ]*\(Plugin [ ]*'\(plug1\|plug2\|plug3\)'\)/\" \1/"
" enable:  sed -i "s/^[ ]*\"[ ]*\(Plugin [ ]*'\(plug1\|plug2\|plug3\)'\)/\1/"
"
" in this file you should list plugins with complex dependencies that require
" compilers to be installed or vim to be compiled with specific flags, e.g.:
"
" Plugin 'fatih/vim-go'
" Plugin 'Valloric/YouCompleteMe'
"

call vundle#end()            " required
filetype plugin indent on    " required


" === Colors ===

let base16colorspace=256
set background=dark
"colorscheme base16-eighties
"colorscheme base16-railscasts
"colorscheme base16-twilight
"colorscheme base16-tomorrow
colorscheme base16-default-dark


" === SyntaxRange Setup ===

function! CommonSyntaxRanges() abort
	let eof_end = '\($\| \)'
	for item in items({'SH':'sh', 'SQL':'sql', 'EOF':'sh', 'MD':'ghmarkdown', 'AWK':'awk', 'RUBY':'ruby', 'RB':'ruby'})
		call SyntaxRange#Include('<<[\-]\=' . item[0] . eof_end, item[0], item[1],  'NonText')
	endfor

	call SyntaxRange#Include("^[\t\ ]*shell:\ |$",             "^[\t\ ]*$",   'sh',   'NonText')
	call SyntaxRange#Include("awk\ [^|']*'\ ",                 "\ '",         'awk',  'NonText')
	call SyntaxRange#Include("awk\ [^|']*'$",                  "^[\t\ ]*'",   'awk',  'NonText')
	call SyntaxRange#Include('[a-z]*sql[a-z]*\ \"',            '\"$', 'sql',  'NonText')
	call SyntaxRange#Include('[a-z]*sql[a-z]*.*\ \(-c\)\ \"',  '\"$', 'sql',  'NonText')

endfunction

function! _blockcomment()

	" free text comment
	You can write free text here,
	but vim will try to highlight it as vimscript!

	" markdown heredoc
	test <<MD
	### Nevertheless ###
	* for testing my fuzzy SyntaxRange heredocs
	* having no leading chars is essential
	* and the blockcomment function does the trick
	MD

	" psql one-liner
	psql -c " SELECT 1 "

	" psql heredoc
	psql <<SQL
		SELECT 1
	SQL

	" psql indented heredoc
	psql <<-SQL
		SELECT 1
	SQL

   " awk one-liner
	awk ' /test/ {print $1} '

	" shell heredoc
	zsh <<-SH
		if true; then false; else break; fi
	SH

	cat <<EOF | sort -n
		3
		1
		2
	EOF

endfunction



" === Backups ===

if has("vms")
	set nobackup    " do not keep a backup file, use versions instead
else
	set backup      " keep a backup file
endif




" === Auto Groups ===

if has("autocmd")

	"wrap auto command in group
	augroup vimrc
		"clear all auto commands in this group
		au!
		highlight Pmenu guifg='Black' guibg='White'
		highlight PmenuSel guifg='Black' guibg='Gray'
		highlight Search guibg='Purple' guifg='NONE'
		au Syntax * call CommonSyntaxRanges()
		au BufWritePost .vimrc      source ~/.vimrc
		au BufWritePost .vimplugins source ~/.vimrc
	augroup END

	augroup myfiletypes
		au!
		au BufRead,BufNewFile *.cql setfiletype sql
		" reopen current fold after saving go file
		" since goformat destroys folds on write
		au BufNewFile,BufRead *.md,*.markdown,*.txt setlocal filetype=ghmarkdown
	augroup END

	augroup vimgo
		au!
		"au BufWritePost *.go normal! zv

		au FileType go nmap <leader>x <Plug>(go-run)
		au FileType go nmap <leader>b <Plug>(go-build)
		au FileType go nmap <leader>t <Plug>(go-test)
		au FileType go nmap <leader>c <Plug>(go-coverage)

		"au FileType go nmap <Leader>ds <Plug>(go-def-split)
		"au FileType go nmap <Leader>dv <Plug>(go-def-vertical)
		"au FileType go nmap <Leader>dt <Plug>(go-def-tab)
		au FileType go nmap <Leader>d  <Plug>(go-def-split)

		au FileType go nmap <Leader>gd <Plug>(go-doc)
		au FileType go nmap <Leader>gv <Plug>(go-doc-vertical)
		au FileType go nmap <Leader>gb <Plug>(go-doc-browser)

		au FileType go nmap <Leader>s <Plug>(go-implements)
		au FileType go nmap <Leader>i <Plug>(go-info)
		au FileType go nmap <Leader>r <Plug>(go-rename)

		let g:go_highlight_functions = 1
		let g:go_highlight_methods = 1
		let g:go_highlight_structs = 1
		let g:go_highlight_interfaces = 1
		let g:go_highlight_operators = 1
		let g:go_highlight_build_constraints = 1

	augroup END

endif

" === Window Sizing and Fonts ===

if has("gui")
	let g:myfontnum = 0
	let g:myfonts   = [
				\ 'Ubuntu\ Mono\ 11',
				\ 'Ubuntu\ Mono\ 12',
				\ 'Ubuntu\ Mono\ 13',
				\ 'Ubuntu\ Mono\ 14',
				\ 'Ubuntu\ Mono\ 15',
				\ 'Ubuntu\ Mono\ 16',
				\ 'Liberation\ Mono\ 10',
				\ 'Liberation\ Mono\ 11',
				\ 'Liberation\ Mono\ 12',
				\ 'Liberation\ Mono\ 13',
				\ 'Liberation\ Mono\ 14',
				\ 'Liberation\ Mono\ 15',
				\ 'DejaVu\ Sans\ Mono\ 10',
				\ 'DejaVu\ Sans\ Mono\ 11',
				\ 'DejaVu\ Sans\ Mono\ 12',
				\ 'DejaVu\ Sans\ Mono\ 13',
				\ 'DejaVu\ Sans\ Mono\ 14',
				\ 'DejaVu\ Sans\ Mono\ 15'
				\]
	function! NextFont(...)
		let g:myfontnum += 1
		if a:0 > 0
			let g:myfontnum = a:1
		elseif g:myfontnum >= len(g:myfonts)
			let g:myfontnum = 0
		endif
		let g:myfont = g:myfonts[g:myfontnum]
		exec "set guifont=".g:myfont
	endfunction

	nmap <leader>f :call NextFont()<CR>
	nmap <leader>- :call NextFont(g:myfontnum - 1)<CR>

	call NextFont(1)
	" only fiddle with lines and cols if window is very small
	" this basically overrides too small default window sizes
	" but ignores larger settings caused by window resizing
	if &lines < 30
		set lines=40
	endif
	if &columns < 100
		set columns=120
	endif
endif



" === File Handling ===

if ! isdirectory($HOME."/.vim/backup")
	call mkdir($HOME."/.vim/backup", "p")
endif

if ! isdirectory($HOME."/.vim/tmp")
	call mkdir($HOME."/.vim/tmp", "p")
endif

" avoid messing up source folders with backup files
set backupdir=$HOME/.vim/backup  " store backups centrally
set directory=$HOME/.vim/tmp     " store swaps centrally



" === Plugin Configuration ===
" use goimports for formatting
let g:go_fmt_command = "goimports"

" turn highlighting on
let g:go_highlight_functions = 1
let g:go_highlight_methods   = 1
let g:go_highlight_structs   = 1
let g:go_highlight_operators = 1
let g:go_highlight_build_constraints = 1

let g:colorizer_maxlines = 1000

" NERDTree options
let g:NERDTreeShowHidden = 1

" CtrlP options
" TODO (uj): check why the ctrlp_map has no effect
" workaround: directly define mappings in leader section
" let g:ctrlp_map = ',p'
" let g:ctrlp_cmd = 'CtrlP'
" let g:ctrlp_prompt_mappings = {}


" === Leader/Plugin Mappings ===

" EchoToggle toggles the given setting and prints the resulting value.
function! EchoToggle(setting)
	exec 'set '.a:setting.'!'
	exec 'set '.a:setting.'?'
endfunction

let mapleader = ","

nmap <F8> :TagbarToggle<CR>

map <leader>ev :e ~/.vimrc<CR>
map <leader>ez :e ~/.zshrc<CR>
map <leader>eb :e ~/.bashrc<CR>
map <leader>ep :e ~/.profile<CR>
map <leader>et :e ~/.tmux.conf<CR>
map <leader>eh :e ~/.hosts<CR>
map <leader>es :e ~/.ssh/config<CR>
map <leader>pf :CtrlP<CR>
map <leader>pb :CtrlPBuffer<CR>
map <leader>pp :CtrlPMixed<CR>
map <leader>p  :CtrlPMixed<CR>

function! MyCD(...)
	if a:0 == 0
		let path = $PWD
	else
		let path = a:1
	endif
	echo "cd ".path
	exec "cd ".path
	if exists("*NERDTreeCWD")
		call NERDTreeCWD()
	endif
endfunction
command! -nargs=* CD :call MyCD(<f-args>)

" When pressing <leader>cd switch to the directory of the open buffer
map <leader>cd  :call MyCD(expand("%:p:h"))<CR>
map <leader>ncd :call MyCD()<CR>

" === Grep Mappings ===

function! s:get_visual_selection()
	" Why is this not a built-in Vim script function?!
	" source: http://stackoverflow.com/questions/1533565/how-to-get-visually-selected-text-in-vimscript?rq=1
	let [lnum1, col1] = getpos("'<")[1:2]
	let [lnum2, col2] = getpos("'>")[1:2]
	let lines = getline(lnum1, lnum2)
	let lines[-1] = lines[-1][: col2 - (&selection == 'inclusive' ? 1 : 2)]
	let lines[0] = lines[0][col1 - 1:]
	return join(lines, "\n")
endfunction

function! MyGrep(...)
	if a:0 == 1
		if a:1 == 'n'
			let text = expand("<cword>")
		elseif a:1 == 'v'
			let text = s:get_visual_selection()
		else
			let text = a:1
		endif
	elseif a:0 == 2
		let text = a:2
	else
		echo "too many arguments"
		return
	endif

	if text == ""
		echo "nothing to grep"
		return
	endif

	let name = "*."
	let ext = expand("%:e")
	if ext == ""
		let name = expand("%:t")
	endif
	let file = name.ext
	echo "searching for '".expand(text)."' **/".file
	silent exec "lgrep! '".expand(text)."' **/".file
	lopen
	" TODO (uj): squelch errors
endfunction

map  <leader>gr :call MyGrep('n')<CR>
vmap <leader>gr :call MyGrep('v')<CR>

" === Common Variables ===

set history=1000      " keep 1000 lines of command line history
set undolevels=1000   " keep 1000 undo levels
set ruler             " show the cursor position all the time
set showcmd           " display incomplete commands
set noshowmatch       " display bracket matches
set incsearch         " do incremental searching
set hlsearch          " highlight search results
set ignorecase        " ignore case
set tabstop=3         " change tab from 8 to 4
set softtabstop=3     " allow fine grained soft tabs while keeping real tabs stable
set shiftwidth=3      " set default shift width used for cindent, >>, and <<
set foldcolumn=4      " always show left code folding column
set foldnestmax=1     " max folding depth
set foldmethod=manual " use space to fold/unfold code; use syntax or indent
set foldignore=       " do not ignore comments '#', just fold them!
set foldminlines=8    " do not fold small blocks
set novisualbell      " disable blinking terminals
set noerrorbells      " disable any beeps
set noexpandtab       " do not use spaces for tabs, real TABS rule!
set linebreak         " smart brake if wrap is enabled
set wrapmargin=1      " # of chars from RIGHT border where auto wrapping starts
set textwidth=0       " disable fixed text width
set smartindent       " allow smart indenting
set autoindent        " allow auto indenting (supported by smart indenting)
set scrolloff=3       " keep n lines visible from current line
set sidescrolloff=5   " keep m chars visible from current column
set whichwrap+=b,s,<,>,[,] " let backspace and arrow keys move
                           " to next/prev line in vis and normal mode
set nolazyredraw      " Don't redraw while executing macros
set encoding=utf-8    " force UTF-8 also for windows
set cpoptions-=$      " do not indicate change ranges with a $-sign
set virtualedit=insert,block " ,onemore " allow moving in non-text areas
set wildmenu          " show completion for menu entries, :*TAB
set mousehide         " hide mouse when typing, move it to show again
set mouse=a           " allow mouse selection in all modes (incl. non-gui)
set report=0          " always report if a command changes some lines
set laststatus=2      " always keep a status line for the last window
set shellslash        " do not convert backslash path chars to forward slashes ATTENTION:(luac may need noshellslash)
" set shortmess=+atT    " truncate and abbreviate shell messages
set ttyfast           " indicate fast terminal: better/smooth scrolling
                      " extra screenline characters??
set guioptions-=a     " disable autocopy using mouse and visual;
set guioptions+=A     " enable  autocopy using mouse but not visual;
                      " works independently of :y[ank]
set guioptions-=m     " remove menu bar
set guioptions-=T     " remove toolbar
set guioptions-=R     " remove right-hand scroll bar
set guioptions-=r     " remove right-hand scroll bar
set guioptions-=L     " remove left-hand scroll bar
set guioptions-=l     " remove left-hand scroll bar
set autoindent        " always set autoindenting on
set hidden            " allow buffer switches from unsaved files.
" set switchbuf=        " respect open tabs when swtiching buffers,
                      " 'split' window before quickfix

set nowrap            " disable 'visual' wrapping
set textwidth=0       " turn off physical line wrapping
set wrapmargin=0      " turn off physical line wrapping

set isfname-=:        " ignore colon after filenames


" === Key Mappings ===

noremap gv :vertical wincmd f<CR>
noremap gs :wincmd f<CR>

map  <C-f> :promptfind<CR>
map  <C-h> :promptrepl<CR>
vmap <C-f> y/<C-R>"<CR>N:promptfind<CR>
vmap <C-h> y/<C-R>"<CR>N:promptrepl<CR>

" fold/unfold + toggle folding
nnoremap <space> za
nnoremap <C-space> zi

" switch buffers
map <A-up>   <ESC>:bp<CR>
map <A-down> <ESC>:bn<CR>

" switch tabs
" disabled for utilsnip plugin
" map <C-Tab> <ESC>gt<CR>
" map <C-S-Tab> <ESC>gT<CR>

" show tag list
map <A-right> <ESC>:TagbarToggle<CR>

" toggle editing aids
nmap <leader>z :call EchoToggle('spell')<CR>
nmap <leader>w :call EchoToggle('wrap')<CR>
nmap <leader>l :call EchoToggle('list')<CR>
nmap <leader>n :call EchoToggle('number')<CR>
nmap <leader>x :set nonumber<CR>:set nolist<CR>:set nowrap<CR>:set nospell<CR>:echo "[n]umber, [w]rap, [l]ist, and [s]pell disabled"<CR>

nnoremap zn ]s
nnoremap zp [s
nnoremap zb zw
nnoremap zz zg]s

" hide highlights
nmap <ESC><space> :nohl<CR>

nmap <leader>ee :tabe %:p:h/<cfile><CR>
" test here .zshrc

" open file dialog mapped to <leader>o
" let g:browsefilter="All files\t*.*\n"
nmap <leader>o :browse tabe<CR>

" save file dialog mapped to <C-S-s>
nnoremap <leader>s :browse saveas<CR>
vnoremap <leader>s <ESC>:browse saveas<CR>gv

" close current buffer after switching to previous buffer
nnoremap <leader>q :Bdelete<CR>
" manual buffer hack does not work!
" nmap <leader>q :b#<bar>bd#<CR>

" other leader mappings
map <A-left>  :NERDTreeToggle<CR>

" save using <C-s>
nnoremap <C-s>  <ESC>:w<CR>
vnoremap <C-s>  <ESC>:w<CR>gv
noremap! <C-s>  <ESC>:w<CR>gi
" test here in insert mode: 123

" map increase/decrease to new keys
nnoremap <C-kPlus>  <C-A>
nnoremap <C-kMinus> <C-X>
" try here: 1 2 3 095 01 010 100

" cut using common shortcuts
vnoremap  <S-del>       "+x
vnoremap  <C-x>         "+x
nnoremap  <S-del>       "+dd
nnoremap  <C-x>         "+dd
" copy using common shortcuts
vnoremap  <C-c>         "+y
vnoremap  <C-insert>    "+y
nnoremap  <C-c>         "+yy
nnoremap  <C-insert>    "+yy
" paste using common shortcuts
nnoremap  <S-ins>       "+p
inoremap  <S-ins>       <C-R><C-P>+
vnoremap  <S-ins>       c<C-R><C-P>+
cnoremap  <S-ins>       <C-R>+

" Note: do not use <C-v> for pasting, as it is used for typing chars and keys
"       literally, independent of their binding (see examples below).
" <C-v>ä      types: 'ä'
" <C-v><C-v>  types: '^V'
" <S-ins>     types: '<S-Insert>'

" delete (without copying) using common shortcuts
vnoremap <del> "_d

" del and backspace start insert mode
vnoremap <bs>  "_c
nnoremap <del> i<del>
nnoremap <bs>  i<bs>

" work on whole words. changes the whole word and not only its tail
" used for example with d, y, c, v, etc.
onoremap w iw
vnoremap w iw

" map umlauts to more useful chars n insert mode
map! ö [
map! Ö {
map! ä ]
map! Ä }
map! ü <bar>
" also in normal mode
map  ü <bar>

" use ö and ä as { and } in normal/visual mode for paragraph movement
noremap ö {
noremap ä }
noremap Ö {
noremap Ä }
noremap ü <bar>
noremap Ü <bar>

" allow umlauts in movements
map fü f<bar>
map fÜ f<bar>
map fö f[
map fÖ f{
map fä f]
map fÄ f}

map rü r<bar>
map rÜ r<bar>
map rö r[
map rÖ r{
map rä r]
map rÄ r}

" TODO: How to make umlauts work in movements more generally
"
" Test Case:       Try ^dfü here to delete this line | ...rest
" Expexted Result: ...rest
"
" Char Codes: Ä 196  ä 228  ß 223 
"             Ö 214  ö 246   
"             Ü 220  ü 252   
"
" Failed Attempts: map ü <bar>, map Ü <bar>, map <Char-252> <bar>

" mark lines
map  <S-up>     v<up>
vmap <S-up>      <up>
map! <S-up>     <ESC>v<up>
map  <S-down>   v<down>
vmap <S-down>    <down>
map! <S-down>   <ESC><right>v<down>
map  <S-home>   v<home>
vmap <S-home>    <home>
map! <S-home>   <ESC>v<home>
map  <S-end>    v<end>
vmap <S-end>     <end>
map! <S-end>    <ESC><right>v<end>
" marks paragraphs
map  <C-S-up>   v(
vmap <C-S-up>    (
map! <C-S-up>   <ESC>v(
map  <C-S-down> v)
vmap <C-S-down>  )
map! <C-S-down> <ESC>v)
" mark chars
map  <S-left>        v<left>
vmap <S-left>         <left>
map! <S-left>   <ESC>v<left>
map  <S-right>              v<right>
vmap <S-right>               <right>
map! <S-right>  <ESC><right>v<right>
" mark words
map  <C-S-left>   vB
vmap <C-S-left>    B
map! <C-S-left>   <ESC>vB
map  <C-S-right>  vW
vmap <C-S-right>   W
map! <C-S-right>  <ESC><right>vW

" remap Ctrl+arrows to word/sentence selection
noremap <C-left> B
noremap <C-right> W
noremap <C-up> (
noremap <C-down> )

" re-select visual area after indenting
vnoremap > >gv
vnoremap < <gv
vnoremap <tab>   >gv
vnoremap <S-tab> <gv

" easy access to @
map  <A-q> @
imap <A-q> @
" example usage:
" 1. 'qq' to start recording in 'q'
" 2. '@q' to playback recorded 'q'

" CTRL-A selects all
vnoremap <C-A> <Esc>ggvG$
nnoremap <C-A> ggvG$
inoremap <C-A> <Esc>ggvG$

" escape out of insert mode using Shift+Enter
imap     <S-CR> <ESC>
vnoremap <S-CR> <ESC>

" remove EOL whitespace
nnoremap d<S-Space> :%s#\s\+$##gc<CR>
nnoremap d<Space> $a<space><Esc>diw$


