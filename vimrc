set nocompatible              " be iMproved, required
filetype off                  " required

set number

set tabstop=4
set expandtab
set shiftwidth=4
set softtabstop=4

filetype plugin on
syntax on

call plug#begin('~/.vim/plugged')
Plug 'http://github.com/mattn/emmet-vim'
Plug 'https://github.com/nathanaelkane/vim-indent-guides'
Plug 'https://github.com/jalvesaq/Nvim-R'
call plug#end()

