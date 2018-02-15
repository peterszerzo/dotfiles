" Settings
set autoread
set autoindent
set cindent
set cursorline
set expandtab
set hlsearch
set incsearch
set nocompatible
set noswapfile
set nowrap
set number
set relativenumber
set shiftwidth=2
set showcmd
set smartindent
set softtabstop=2
set wildmenu
set wildmode=longest:full,full
set wildignore=*/node_modules/*,*/elm-stuff/*,*/lib/*,*/public/*
filetype plugin on
syntax enable

" Keybindings
noremap <Leader>p :!node_modules\/.bin\/prettier % --no-semi --write<CR>
noremap <Leader>e :!open -e %<CR>
noremap <Leader>s :update<CR>
:imap jk <Esc>
noremap / /\v
noremap Y y$
noremap <C-h> <C-w>h
noremap <C-l> <C-w>l
noremap <C-k> <C-w>k
noremap <C-j> <C-w>j
nnoremap <Enter> @@
" Store big enough changes in the jumplist
nnoremap <expr> k (v:count > 5 ? "m'" . v:count : '') . 'k'
nnoremap <expr> j (v:count > 5 ? "m'" . v:count : '') . 'j'
" Move to previous file
noremap <Leader>v :b#<CR>
" Smooth scroll mappings
noremap <silent> <c-u> :call smooth_scroll#up(&scroll, 8, 1)<CR>
noremap <silent> <c-d> :call smooth_scroll#down(&scroll, 8, 1)<CR>
noremap <silent> <c-b> :call smooth_scroll#up(&scroll*2, 4, 1)<CR>
noremap <silent> <c-f> :call smooth_scroll#down(&scroll*2, 4, 1)<CR>
" Command mode mappings
cnoremap <C-a> <Home>
cnoremap <C-b> <End>

" Plugins
call plug#begin('~/.vim/plugged')
Plug 'ctrlpvim/ctrlp.vim'
Plug 'elmcast/elm-vim'
Plug 'scrooloose/nerdtree'
Plug 'sheerun/vim-polyglot'
Plug 'sonph/onehalf', {'rtp': 'vim/'}
Plug 'terryma/vim-smooth-scroll'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-surround'
Plug 'vim-airline/vim-airline'
call plug#end()

" Plugin configurations
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 1 && isdirectory(argv()[0]) && !exists("s:std_in") | exe 'NERDTree' argv()[0] | wincmd p | ene | endif
let g:polyglot_disabled = ['elm']
let g:elm_detailed_complete = 1
let g:elm_format_autosave = 1
let g:ctrlp_map = '<c-p>'
let g:ctrlp_cmd = 'CtrlP :pwd'

set t_Co=256
set background=dark
colorscheme onehalfdark
