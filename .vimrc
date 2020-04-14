set autoindent
set backspace=2
set cursorline
set expandtab
set hlsearch
set incsearch
set nocompatible
set noswapfile
set updatetime=300
set signcolumn=yes
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
noremap <Leader>. :Gvsplit master:%<CR>

" vim.coc settings
inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"
autocmd! CompleteDone * if pumvisible() == 0 | pclose | endif
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

:imap jk <Esc>
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

" Move to previous file
nmap <silent> gb :b#<CR>

" Command mode mappings
cnoremap <C-a> <Home>
cnoremap <C-b> <End>

" Plugins
call plug#begin('~/.vim/plugged')
Plug 'sheerun/vim-polyglot'
Plug 'scrooloose/nerdtree'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-rhubarb'
Plug 'ctrlpvim/ctrlp.vim'
Plug 'tpope/vim-surround'
Plug 'tikhomirov/vim-glsl'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'vim-airline/vim-airline'
Plug 'arcticicestudio/nord-vim'
call plug#end()

" Make nerdtree open automatically when calling `vim` on a folder
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 1 && isdirectory(argv()[0]) && !exists("s:std_in") | exe 'NERDTree' argv()[0] | wincmd p | ene | endif

let g:ctrlp_map = '<c-p>'
let g:ctrlp_cmd = 'CtrlP :pwd'

let g:airline_theme='nord'

set t_Co=256
set background=dark
colorscheme nord
