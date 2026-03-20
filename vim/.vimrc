" ─── General ─────────────────────────────────────────────────────────────────

set nocompatible
filetype plugin indent on
syntax on

set encoding=utf-8
set fileencoding=utf-8

" ─── Appearance ───────────────────────────────────────────────────────────────

set number                  " line numbers
set relativenumber          " relative line numbers
set cursorline              " highlight current line
set termguicolors           " true color support
set background=dark
set signcolumn=yes          " always show sign column

" ─── Indentation ──────────────────────────────────────────────────────────────

set expandtab               " spaces instead of tabs
set tabstop=2
set shiftwidth=2
set softtabstop=2
set autoindent
set smartindent

" Per-language indentation
autocmd FileType python     setlocal tabstop=4 shiftwidth=4 softtabstop=4
autocmd FileType go         setlocal noexpandtab tabstop=4 shiftwidth=4
autocmd FileType lua        setlocal tabstop=2 shiftwidth=2
autocmd FileType yaml,json  setlocal tabstop=2 shiftwidth=2

" ─── Syntax Highlighting ──────────────────────────────────────────────────────

" Lua
autocmd BufNewFile,BufRead *.lua setfiletype lua

" Shell
autocmd BufNewFile,BufRead *.sh,*.zsh,*.bash setfiletype sh

" JSON / JSONC
autocmd BufNewFile,BufRead *.json,*.jsonc setfiletype json

" Markdown
autocmd BufNewFile,BufRead *.md setfiletype markdown

" Tmux config
autocmd BufNewFile,BufRead .tmux.conf,tmux.conf setfiletype tmux

" WezTerm config (Lua)
autocmd BufNewFile,BufRead .wezterm.lua setfiletype lua

" ─── Search ───────────────────────────────────────────────────────────────────

set hlsearch                " highlight search results
set incsearch               " incremental search
set ignorecase
set smartcase               " case-sensitive if uppercase used
nnoremap <Esc><Esc> :nohlsearch<CR>

" ─── UI ───────────────────────────────────────────────────────────────────────

set showcmd
set showmatch               " highlight matching brackets
set wildmenu                " command completion menu
set laststatus=2            " always show status line
set ruler
set scrolloff=8             " keep 8 lines above/below cursor
set sidescrolloff=8
set wrap
set linebreak

" Status line
set statusline=\ %f\ %m%r%h%w\ %=%y\ [%{&fileencoding}]\ %l:%c\ %p%%\

" ─── Usability ────────────────────────────────────────────────────────────────

set backspace=indent,eol,start
set clipboard=unnamed       " use system clipboard
set mouse=a                 " enable mouse
set hidden                  " allow switching buffers without saving
set autoread                " reload file if changed outside vim
set splitright              " vsplit opens to the right
set splitbelow              " split opens below

" ─── Backup / Swap ────────────────────────────────────────────────────────────

set noswapfile
set nobackup
set nowritebackup
