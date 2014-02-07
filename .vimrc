"http://statico.github.io/vim.html
"http://www.cs.swarthmore.edu/help/vim
"see also
"http://vim.wikia.com/wiki/Have_Vim_check_automatically_if_the_file_has_changed_externally
execute pathogen#infect()
syntax on
filetype plugin indent on

if $TERM == "xterm-256color" || $TERM == "screen-256color"
  set t_Co=256
  colorscheme zenburn
endif

" I've read this is nice
set nocompatible

" Allow hiding modified buffers (plays nice with Ctrl-P plugin)
set hidden

" Highlight tabs and trailing spaces
set listchars=tab:>\ ,trail:·,extends:>,precedes:<,nbsp:+
set list

"highlight column 80
set cc=80

" toggle line numbers
nmap \l :setlocal number!<CR>
set nu

" Gently highlight the current line
set cursorline

"toggle paste mode
nmap \o :set paste!<CR>

"tab modes
nmap \t :set expandtab tabstop=4 shiftwidth=4 softtabstop=4<CR>
nmap \T :set expandtab tabstop=8 shiftwidth=8 softtabstop=4<CR>
nmap \M :set noexpandtab tabstop=8 softtabstop=4 shiftwidth=4<CR>
nmap \m :set expandtab tabstop=2 shiftwidth=2 softtabstop=2<CR>

" toggle wrap
nmap \w :setlocal wrap!<CR>:setlocal wrap?<CR>

"everybody's buffering...
nmap <C-b> :CtrlPBuffer<CR>
nmap <F9> :CtrlPMRU<CR>
let g:ctrlp_reuse_window = 1
nmap <C-e> :e#<CR>
nmap \n :bnext<CR>
nmap \p :bprev<CR>

"nerd
nmap \e :NERDTreeToggle<CR>

" * Enable vim-airline tabline
let g:airline#extensions#tabline#enabled = 1

" Always display the status line, even if only one window is displayed
set laststatus=2

set nocompatible

" Use visual bell instead of beeping when doing something wrong
set visualbell

" Enable use of the mouse for all modes
set mouse=a

" Natural splits
set splitbelow
set splitright
