"http://statico.github.io/vim.html
"http://www.cs.swarthmore.edu/help/vim
"see also
"http://vim.wikia.com/wiki/Have_Vim_check_automatically_if_the_file_has_changed_externally
execute pathogen#infect()
syntax on
filetype plugin indent on

  set t_Co=256
if $TERM == "xterm-256color" || $TERM == "screen"
endif

colorscheme zenburn

" Highlight tabs and trailing spaces
set listchars=tab:>\ ,trail:·,extends:>,precedes:<,nbsp:+
set list

"highlight column 80
set cc=80

" toggle line numbers
nmap \l :setlocal number!<CR>

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
nmap <C-e> :e#<CR>
nmap \n :bnext<CR>
nmap \p :bprev<CR>

"nerd
nmap \e :NERDTreeToggle<e bufCR>

" Natural splits
set splitbelow
set splitright
