set number
set incsearch
set ignorecase
set smartcase
set scrolloff=4
set backspace=indent,eol,start
set nowrap
set inccommand=split
set noswapfile
set relativenumber
set foldmethod=indent
set autoindent
set autoread
set expandtab
set shiftwidth=2
set softtabstop=2
set smarttab
set clipboard=unnamed
set wildmenu
set wildignore+=*/node_modules/*,*/elm-stuff/*,*/public/*
filetype plugin indent on
syntax enable

call plug#begin()

Plug 'https://github.com/tpope/vim-surround' " Surrounding ysw)
Plug 'https://github.com/tpope/vim-repeat' 
Plug 'https://github.com/easymotion/vim-easymotion' 
Plug 'https://github.com/tpope/vim-unimpaired' 
Plug 'https://github.com/wikitopian/hardmode'
Plug 'https://github.com/tpope/vim-abolish' 
Plug 'https://github.com/tpope/vim-fugitive'
Plug 'https://github.com/AndrewRadev/sideways.vim'
Plug 'https://github.com/preservim/nerdtree' " NerdTree
Plug 'https://github.com/tpope/vim-commentary' " For Commenting gcc & gc
Plug 'https://github.com/vim-airline/vim-airline' " Status bar
Plug 'https://github.com/tpope/vim-rhubarb'
Plug 'https://github.com/ap/vim-css-color' " CSS Color Preview
Plug 'https://github.com/folke/tokyonight.nvim'
Plug 'https://github.com/voldikss/vim-floaterm'
Plug 'https://github.com/junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'https://github.com/junegunn/fzf.vim'
Plug 'https://github.com/neoclide/coc.nvim', {'branch': 'release'}  " Auto Completion
Plug 'https://github.com/preservim/tagbar' " Tagbar for code navigation
Plug 'https://github.com/leafgarland/typescript-vim'
Plug 'https://github.com/tommcdo/vim-exchange'
Plug 'https://github.com/peitalin/vim-jsx-typescript'
Plug 'https://github.com/evanleck/vim-svelte'
Plug 'https://github.com/github/copilot.vim'

set encoding=UTF-8

call plug#end()

noremap <C-h> <C-w>w
nnoremap gd :call CocActionAsync('jumpDefinition')<CR>
nnoremap gh :call CocActionAsync('doHover')<CR>
nnoremap gf :call CocActionAsync('format')<CR>
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)
nmap <silent> ]z zR
nmap <silent> [z zM

" Start NERDTree when Vim starts with a directory argument.
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 1 && isdirectory(argv()[0]) && !exists('s:std_in') |
    \ execute 'NERDTree' argv()[0] | wincmd p | enew | execute 'cd '.argv()[0] | endif

autocmd VimEnter,BufNewFile,BufReadPost * silent! call HardMode()
autocmd TextYankPost * silent! lua vim.highlight.on_yank()

" Keybindings
nmap <silent> gb :b#<CR>
:imap jk <Esc>
noremap Y y$
noremap <Leader>f :NERDTreeFind<CR>
noremap <Leader>t :FloatermNew<CR>
noremap <Leader>e :CocDiagnostics<CR>
noremap <Leader>r :CocRestart<CR>
noremap <Leader>s :update<CR>
noremap <Leader>h :noh<CR>
noremap <Leader>x :q!<CR>
noremap <Leader>o :GBrowse<CR>
nnoremap <c-h> :SidewaysLeft<CR>
nnoremap <c-l> :SidewaysRight<CR>
nnoremap <c-p> :GFiles<CR>

noremap <Leader>u :CocCommand snippets.editSnippets<CR>

inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm()
    \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

set termguicolors
:colorscheme tokyonight
set background=dark

" --- Just Some Notes ---
" :PlugClean :PlugInstall :UpdateRemotePlugins
"
" :CocInstall coc-python
" :CocInstall coc-clangd
" :CocInstall coc-snippets
" :CocCommand snippets.edit... FOR EACH FILE TYPE

" air-line
let g:airline_powerline_fonts = 1

if !exists('g:airline_symbols')
    let g:airline_symbols = {}
endif

" airline symbols
let g:airline_left_sep = ''
let g:airline_left_alt_sep = ''
let g:airline_right_sep = ''
let g:airline_right_alt_sep = ''
let g:airline_symbols.branch = ''
let g:airline_symbols.readonly = ''
let g:airline_symbols.linenr = ''

let g:coc_global_extensions = ['@yaegassy/coc-tailwindcss3', 'coc-prettier', 'coc-vetur', 'coc-tsserver', 'coc-svelte', 'coc-json']

let g:floaterm_width = 0.8
let g:floaterm_height = 0.8
