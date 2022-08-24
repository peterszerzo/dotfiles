set number
set nowrap
set noswapfile
set relativenumber
set autoindent
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
Plug 'https://github.com/jwoudenberg/elm-pair', { 'rtp': 'editor-integrations/neovim' }
Plug 'https://github.com/tpope/vim-abolish' 
Plug 'https://github.com/tpope/vim-fugitive'
Plug 'https://github.com/preservim/nerdtree' " NerdTree
Plug 'https://github.com/tpope/vim-commentary' " For Commenting gcc & gc
Plug 'https://github.com/vim-airline/vim-airline' " Status bar
Plug 'https://github.com/tpope/vim-rhubarb'
Plug 'https://github.com/ap/vim-css-color' " CSS Color Preview
Plug 'https://github.com/rafi/awesome-vim-colorschemes' " Retro Scheme
Plug 'https://github.com/neoclide/coc.nvim', {'branch': 'release'}  " Auto Completion
Plug 'https://github.com/preservim/tagbar' " Tagbar for code navigation
Plug 'https://github.com/ctrlpvim/ctrlp.vim'
Plug 'https://github.com/leafOfTree/vim-svelte-plugin'

set encoding=UTF-8

call plug#end()

nnoremap <C-f> :NERDTreeFocus<CR>
nnoremap <C-n> :NERDTree<CR>
nnoremap <C-t> :NERDTreeToggle<CR>
noremap <C-h> <C-w>w
nnoremap gd :call CocActionAsync('jumpDefinition')<CR>
nnoremap gh :call CocActionAsync('doHover')<CR>
nnoremap gf :call CocActionAsync('format')<CR>
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)

" Start NERDTree when Vim starts with a directory argument.
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 1 && isdirectory(argv()[0]) && !exists('s:std_in') |
    \ execute 'NERDTree' argv()[0] | wincmd p | enew | execute 'cd '.argv()[0] | endif

" Keybindings
nmap <silent> gb :b#<CR>
:imap jk <Esc>
noremap Y y$
noremap <Leader>p :!prettier % --write<CR>
noremap <Leader>f :!elm-format % --yes<CR>
noremap <Leader>e :!open -e %<CR>
noremap <Leader>s :update<CR>
noremap <Leader>h :noh<CR>
noremap <Leader>x :q!<CR>
noremap <Leader>o :GBrowse!<CR>
noremap <Leader>. :Gvsplit master:%<CR>

nmap <F8> :TagbarToggle<CR>

:set completeopt-=preview " For No Previews

set termguicolors
:colorscheme pink-moon
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

let g:coc_global_extensions = ['coc-tailwindcss', 'coc-prettier', 'coc-vetur', 'coc-tsserver', 'coc-svelte', 'coc-json']
