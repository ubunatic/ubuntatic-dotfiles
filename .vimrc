" === Plugins ===

mapclear
mapclear!

set nocompatible
filetype off
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" common plugins, useful for all kinds of hosts
Plugin 'VundleVim/Vundle.vim'
Plugin 'Tagbar'
Plugin 'SyntaxRange'
Plugin 'scrooloose/nerdTree'
Plugin 'sheerun/vim-polyglot'
Plugin 'moll/vim-bbye'
Plugin 'tpope/vim-surround'
Plugin 'tpope/vim-markdown'
Plugin 'jtratner/vim-flavored-markdown'
Plugin 'Xuyuanp/nerdtree-git-plugin'
Plugin 'ctrlpvim/ctrlp.vim'

" Plugin 'dhruvasagar/vim-table-mode'
" Plugin 'chrisbra/NrrwRgn'
" Plugin 'ubunatic/colorizer'
" Plugin 'godlygeek/tabular'
" Plugin 'plasticboy/vim-markdown'

" === VIM Plugin Automation ===
"
if filereadable("~/.vimplugins")
  source ~/.vimplugins
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



" === Colors ===

colorscheme desert
set background=dark



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
		au BufWritePost .vimrc source ~/.vimrc
	augroup END

	augroup myfiletypes
		au!
		au BufRead,BufNewFile *.cql setfiletype sql
		" reopen current fold after saving go file
		" since goformat destroys folds on write
		au BufWritePost *.go normal! zv
		au BufNewFile,BufRead *.md,*.markdown,*.txt setlocal filetype=ghmarkdown
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



" === Leader/Plugin Mappings ===

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

" When pressing <leader>cd switch to the directory of the open buffer
map <leader>cd :cd %:p:h<cr>





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
set foldmethod=syntax " use space to fold/unfold code; use syntax or indent
set foldminlines=8    " do not fold small blocks
set novisualbell      " disable blinking terminals
set noerrorbells      " disable any beeps
set nowrap            " do not wrap text
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

set wrap              " enable "visual" wrapping
set textwidth=0       " turn off physical line wrapping
set wrapmargin=0      " turn off physical line wrapping



" === Key Mappings ===

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
map <C-Tab> <ESC>gt<CR>
map <C-S-Tab> <ESC>gT<CR>

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
nnoremap <C-kPlus> <C-A>
nnoremap <C-kMinus> <C-X>
" try here: 1 2 3 095 01 010 100

" cut using common shortcuts
vnoremap  <S-del>       "+x
vnoremap  <C-x>         "+x
nnoremap  <S-del>       ^v$"+x
nnoremap  <C-x>         ^v$"+x
" copy using common shortcuts
vnoremap  <C-c>         "+y
vnoremap  <C-insert>    "+y
nnoremap  <C-c>         ^v$"+y
nnoremap  <C-insert>    ^v$"+y
" paste using common shortcuts
nnoremap  <S-insert>    I<Middlemouse>
inoremap  <S-insert>    <Middlemouse>
vnoremap  <S-insert>    c<Middlemouse>

" backspace deletes selection
vmap <BS> d

" del, backspace, S-insert start insert mode
nnoremap <del> i<del>
nnoremap <bs> i<bs>

" work on whole words. changes the whole word and not only its tail
" used for example with d, y, c, v, etc.
onoremap w iw
vnoremap w iw

" map umlauts to more useful chars
map! ö [
map! Ö {
map! ä ]
map! Ä }

" TODO: How to make ü work in movements
" Example:
" try dfü here to delete this line | ...
" Expexted Result:
" | ...
"
" Char Codes:
" Ä 196
" Ö 214
" Ü 220
" ß 223
" ä 228
" ö 246
" ü 252
"
" Failed Tests:
" map! ü ...
" map  Ü ...
" onoremap <Char-252> ...
"

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


