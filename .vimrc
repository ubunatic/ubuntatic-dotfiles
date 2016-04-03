" === Plugins ===

set nocompatible
filetype off
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

Plugin 'VundleVim/Vundle.vim'
Plugin 'fatih/vim-go'
Plugin 'Valloric/YouCompleteMe'
Plugin 'Tagbar'
Plugin 'scrooloose/nerdTree'
Plugin 'Xuyuanp/nerdtree-git-plugin'
Plugin 'sheerun/vim-polyglot'
Plugin 'moll/vim-bbye'
Plugin 'ubunatic/colorizer'
Plugin 'tpope/vim-surround'

call vundle#end()            " required
filetype plugin indent on    " required



" === Colors ===

colorscheme desert
set background=dark

if has("autocmd")
	highlight Pmenu guifg='Black' guibg='White'
	highlight PmenuSel guifg='Black' guibg='Gray'
	highlight Search guibg='Purple' guifg='NONE'
endif



" === Window Sizing ===
if has("gui")
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

if exists($HOME."/.vim/backup")
	call mkdir($HOME."/.vim/backup", "p")
endif

if exists($HOME."/.vim/tmp")
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

let mapleader = ","

nmap <F8> :TagbarToggle<CR>

map <leader>ev :e ~/.vimrc<CR>
map <leader>ez :e ~/.zshrc<CR>
map <leader>eb :e ~/.bashrc<CR>
map <leader>ep :e ~/.profile<CR>
map <leader>z  :set spell!<CR>

" When pressing <leader>cd switch to the directory of the open buffer
map <leader>cd :cd %:p:h<cr>



" === Auto Groups ===

" repen current fold after saving go file
" since goformat destroys folds on write 
autocmd BufWritePost *.go normal! zv

" augroup filetypedetect
"   au! BufRead,BufNewFile *.cql setfiletype sql
" augroup END

if has("vms")
	set nobackup    " do not keep a backup file, use versions instead
else
	set backup      " keep a backup file
endif

" ...



" === Common Variables ===

set history=1000      " keep 1000 lines of command line history
set undolevels=1000   " keep 1000 undolevels
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
nmap <ESC>s :set spell!<CR>
nmap <ESC>w :set wrap!<CR>
nmap <ESC>l :set list!<CR>
nmap <ESC>n :set number!<CR>
nmap <ESC>x :set nonumber<CR>:set nolist<CR>:set nowrap<CR>:set nospell<CR>

" hide highlights
nmap <ESC><space> :nohl<CR>

nmap <leader>ee :tabe %:p:h/<cfile><CR>
" test here .zshrc

" open file dialog mapped to <leader>o
" let g:browsefilter="All files\t*.*\n"
nmap <leader>o :browse tabe<CR>

map <leader>n :NERDTreeToggle<CR>
map <A-left> :NERDTreeToggle<CR>

" save file dialog mapped to <C-S-s>
nnoremap <leader>s :browse saveas<CR>
vnoremap <leader>s <ESC>:browse saveas<CR>gv

" close current buffer after switching to previous buffer
nnoremap <leader>q :Bdelete<CR>
" manual buffer hack does not work!
" nmap <leader>q :b#<bar>bd#<CR>

" save using <C-s>
nnoremap <C-s>  <ESC>:w<CR>
vnoremap <C-s>  <ESC>:w<CR>gv
noremap! <C-s>  <ESC>:w<CR>gi
" test here in insertmode: 123

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

" del,backspace,S-insert start insert mode
nnoremap <del> i<del>
nnoremap <bs> i<bs>

" work on whole words. changes the whole word and not only its tail
" used for example with d, y, c, v, etc.
onoremap w iw
vnoremap w iw

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

" add  braces and brackets to öäü
map! ö [
map! Ö {
map! ä ]
map! Ä }

