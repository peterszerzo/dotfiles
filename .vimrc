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
noremap <Leader>s :update<CR>
:imap jk <Esc>
noremap <silent> <c-u> :call smooth_scroll#up(&scroll, 8, 1)<CR>
noremap <silent> <c-d> :call smooth_scroll#down(&scroll, 8, 1)<CR>
noremap <silent> <c-b> :call smooth_scroll#up(&scroll*2, 8, 2)<CR>
noremap <silent> <c-f> :call smooth_scroll#down(&scroll*2, 8, 2)<CR>

" Plugins
call plug#begin('~/.vim/plugged')
Plug 'altercation/vim-colors-solarized'
Plug 'elmcast/elm-vim'
Plug 'terryma/vim-smooth-scroll'
Plug 'sheerun/vim-polyglot'
Plug 'vim-syntastic/syntastic'
Plug 'scrooloose/nerdtree'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-surround'
Plug 'ctrlpvim/ctrlp.vim'
Plug 'sonph/onehalf', {'rtp': 'vim/'}
call plug#end()

" Plugin configurations
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 1 && isdirectory(argv()[0]) && !exists("s:std_in") | exe 'NERDTree' argv()[0] | wincmd p | ene | endif
let g:polyglot_disabled = ['elm']
let g:elm_detailed_complete = 1
let g:elm_format_autosave = 1
let g:elm_syntastic_show_warnings = 1
let g:syntastic_typescript_tsc_fname = ''
let g:ctrlp_map = '<c-p>'
let g:ctrlp_cmd = 'CtrlP :pwd'

set t_Co=256
set background=dark
colorscheme onehalfdark
