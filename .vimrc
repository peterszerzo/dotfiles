set autoread
set autoindent
set backspace=2
set cursorline
set expandtab
set hlsearch
set incsearch
set nocompatible
set noswapfile
set clipboard=unnamed
set nowrap
set encoding=utf-8
set number
set relativenumber
set shiftwidth=2
set softtabstop=2
set showcmd
set wildmenu
set wildmode=longest:full,full
set wildignore=*/node_modules/*,*/elm-stuff/*,*/lib/*,*/public/*
filetype plugin indent on
syntax enable

" Keybindings
noremap <Leader>p :!prettier % --write<CR>
noremap <Leader>e :!open -e %<CR>
noremap <Leader>s :update<CR>
noremap <Leader>h :noh<CR>
noremap <Leader>x :q!<CR>
noremap <Leader>o :Gbrowse!<CR>
noremap <Leader>n :ALENext<CR>
noremap <Leader>m :ALEPrevious<CR>
noremap <Leader>, :ALEDetail<CR>
noremap <Leader>. :Gvsplit master:%<CR>
:imap jk <Esc>
noremap / /\v
noremap Y y$
" Make Ctrl+H bounce between panes instead of going left explicitly.
" Since I only use a single Vim window + NERDTree, this replicates
" a move-to-left motion in addition to jumping back and forth the 
" same way tmux bindings work.
noremap <C-h> <C-w>w
noremap <C-l> <C-w>l
noremap <C-k> <C-w>k
noremap <C-j> <C-w>j
nnoremap <Enter> @@
" Store big enough changes in the jumplist
nnoremap <expr> k (v:count > 5 ? "m'" . v:count : '') . 'k'
nnoremap <expr> j (v:count > 5 ? "m'" . v:count : '') . 'j'
" Move to previous file
noremap <Leader>b :b#<CR>
" Command mode mappings
cnoremap <C-a> <Home>
cnoremap <C-b> <End>

" coc.nvim settings
inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"
autocmd! CompleteDone * if pumvisible() == 0 | pclose | endif
inoremap <silent><expr> <cr> pumvisible() ? coc#_select_confirm() : "\<C-g>u\<CR>"

" Plugins
call plug#begin('~/.vim/plugged')
Plug 'andys8/vim-elm-syntax'
Plug 'sheerun/vim-polyglot'
Plug 'scrooloose/nerdtree'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-rhubarb'
Plug 'posva/vim-vue'
Plug 'ctrlpvim/ctrlp.vim'
Plug 'tpope/vim-surround'
Plug 'udalov/kotlin-vim'
Plug 'tikhomirov/vim-glsl'
Plug 'w0rp/ale'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'Shougo/deoplete.nvim'
Plug 'Shougo/vimproc.vim', {'do' : 'make'}
Plug 'vim-airline/vim-airline'
Plug 'Quramy/tsuquyomi'
Plug 'arcticicestudio/nord-vim'
call plug#end()

" Make nerdtree open automatically when calling `vim` on a folder
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 1 && isdirectory(argv()[0]) && !exists("s:std_in") | exe 'NERDTree' argv()[0] | wincmd p | ene | endif

let g:polyglot_disabled = ['elm']

let g:tsuquyomi_disable_quickfix = 1

let g:ctrlp_map = '<c-p>'
let g:ctrlp_cmd = 'CtrlP :pwd'

let g:ale_sign_column_always = 1
let g:ale_linters = {
\   'javascript': ['eslint'],
\   'css': ['prettier'],
\}
let g:ale_fixers = {
\   'javascript': ['prettier'],
\   'haskell': ['stylish-haskell'],
\   'vue': ['prettier'],
\   'typescript': ['prettier'],
\   'css': ['prettier'],
\   'elm': ['elm-format'],
\}
let g:ale_fix_on_save = 1

let g:airline#extensions#ale#enabled = 1
let g:airline_theme='nord'

set t_Co=256
set background=dark
colorscheme nord
