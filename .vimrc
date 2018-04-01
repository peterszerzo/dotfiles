" Settings
set autoread
set autoindent
set backspace=2
set cursorline
set expandtab
set hlsearch
set incsearch
set nocompatible
set noswapfile
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
noremap <Leader>p :!node_modules\/.bin\/prettier % --no-semi --write<CR>
noremap <Leader>e :!open -e %<CR>
noremap <Leader>s :update<CR>
" Feed word under the cursor into CtrlP and move to file.
map <Leader>g <C-P><C-\>w<CR>
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
noremap <Leader>v :b#<CR>
" Command mode mappings
cnoremap <C-a> <Home>
cnoremap <C-b> <End>

" Plugins
call plug#begin('~/.vim/plugged')
Plug 'elmcast/elm-vim'
Plug 'sheerun/vim-polyglot'
Plug 'scrooloose/nerdtree'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-fugitive'
Plug 'ctrlpvim/ctrlp.vim'
Plug 'tpope/vim-surround'
Plug 'w0rp/ale'
Plug 'Shougo/vimproc.vim', {'do' : 'make'}
Plug 'vim-airline/vim-airline'
Plug 'Quramy/tsuquyomi'
Plug 'sonph/onehalf', {'rtp': 'vim/'}
call plug#end()

" Plugin configurations
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 1 && isdirectory(argv()[0]) && !exists("s:std_in") | exe 'NERDTree' argv()[0] | wincmd p | ene | endif
let g:polyglot_disabled = ['elm']
let g:elm_detailed_complete = 1
let g:elm_format_autosave = 1
let g:ctrlp_map = '<c-p>'
let g:ctrlp_cmd = 'CtrlP :pwd'
let g:ale_sign_column_always = 1
let g:ale_lint_on_text_changed = 'never'

set t_Co=256
set background=dark
colorscheme onehalfdark
