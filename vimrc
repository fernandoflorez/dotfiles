set nocompatible
set nomodeline

" code details
set nowrap
set tabstop=4
set shiftwidth=4
set softtabstop=4
set expandtab
set autoindent
set number

" cursor stuff
set scrolloff=4

" lots of undos!
set history=100
set undolevels=100

" avoid horrible files
set nobackup
set noswapfile

" search details
set incsearch
set ignorecase
set smartcase
set hlsearch

" filename autocomplete
set wildmode=list:longest

" draw line char 80
set colorcolumn=80

" highlight cursor line
set cursorline

if has('gui_running')
    set guioptions-=T
    set background=light
    autocmd VimEnter * NERDTree
    autocmd BufEnter * NERDTreeMirror
    autocmd VimEnter * wincmd w
else
    let g:solarized_termcolors=256
endif

" gui colors
set background=dark
syntax enable
colorscheme solarized " https://github.com/altercation/vim-colors-solarized
