set nocompatible              " be iMproved, required
filetype off                  " required

set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

Plugin 'VundleVim/Vundle.vim'
"Plugin 'tpope/vim-fugitive'
"Plugin 'junegunn/fzf.vim'
"Plugin 'itchyny/lightline.vim'
Plugin 'scrooloose/nerdtree'
Plugin 'flazz/vim-colorschemes'
"Plugin 'joshdick/onedark.vim'
Plugin 'scrooloose/syntastic'

call vundle#end()            " required
filetype plugin indent on    " required

"""" Basic Behavior

set number              " show line numbers
set wrap                " wrap lines
set encoding=utf-8      " set encoding to UTF-8 (default was "latin1")
set mouse=a             " enable mouse support (might not work well on Mac OS X)
set showmatch           " highlight matching parentheses / brackets [{()}]
set visualbell          " blink cursor on error, instead of beeping
set laststatus=2
"""" Vim Appearance


colorscheme Monokai
"autocmd vimenter * NERDTree
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 1 && isdirectory(argv()[0]) && !exists("s:std_in") | exe 'NERDTree' argv()[0] | wincmd p | ene | endif


let g:lightline = {
      \ 'colorscheme': 'onedark',
      \ 'active': {
      \   'left': [ [ 'mode', 'paste' ],
      \             [ 'gitbranch', 'readonly', 'filename', 'modified' ] ]
      \ },
      \ 'component_function': {
      \   'gitbranch': 'fugitive#head'
      \ },
      \ }

syntax enable                               " use filetype-based syntax highlighting, ftplugins, and indentation

"""" Tab Settings

set tabstop=4           " number of spaces per <TAB>
set expandtab           " convert <TAB> key-presses to spaces
set shiftwidth=4        " set a <TAB> key-press equal to 4 spaces

set autoindent          " copy indent from current line when starting a new line
set smartindent         " even better autoindent (e.g. add indent after '{')

"""" Search Settings

set incsearch           " search as characters are entered
set hlsearch            " highlight matches

"""" Misc Settings
set autoread           " autoreload the file in Vim if it has been changed outside of Vim

