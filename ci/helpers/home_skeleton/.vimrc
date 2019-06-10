filetype off

"call pathogen#infect()
"call pathogen#helptags()
syntax on
filetype plugin indent on

set softtabstop=2
set smarttab
set shiftwidth=2
set autoindent
set expandtab
set number

colorscheme ron

autocmd Filetype python set softtabstop=4|set shiftwidth=4
autocmd Filetype php set softtabstop=4|set shiftwidth=4
autocmd Filetype make set noexpandtab
autocmd BufWritePre * :%s/\s\+$//e

autocmd BufRead,BufNewFile *.mw set filetype=mediawiki
autocmd BufRead,BufNewFile *.md set filetype=markdown
autocmd BufRead,BufNewFile *.hamlc set filetype=haml
autocmd BufRead,BufNewFile *.rabl set filetype=ruby
