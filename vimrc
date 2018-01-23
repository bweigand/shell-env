set nocompatible

if v:version >= 700
  try
    runtime bundle/pathogen/autoload/pathogen.vim
    call pathogen#infect()
    filetype plugin indent on
    let g:racer_cmd = "$HOME/.cargo/bin/racer"
    let g:racer_experimental_completer = 1
    syntax on
  catch /.*/
      echo "Error Loading Plugins: " v:exception
  endtry
endif



" Hide changes
set hidden

" Disable line wrapping
set nowrap

" Better command-line completion
set wildmenu

" Show partial commands in the last line of the screen
set showcmd

" Highlight searches (use <C-L> to temporarily turn off highlighting; see the mapping of <C-L> below)
set hlsearch

" Use case insensitive search, except when using capital letters
set ignorecase
set smartcase

" Allow backspacing over autoindent, line breaks and start of insert action
set backspace=indent,eol,start

" When opening a new line and no filetype-specific indenting is enabled, keep
" the same indent as the line you're currently on. Useful for READMEs, etc.
set autoindent

" Stop certain movements from always going to the first character of a line.
" While this behaviour deviates from that of Vi, it does what most users
" coming from other editors would expect.
set nostartofline

" Display the cursor position on the last line of the screen or in the status
" line of a window
set ruler

" Always display the status line, even if only one window is displayed
set laststatus=2

" Make a little space for the command line
set cmdheight=2

" Enable line numbers
set number

" Set tab width, unless we're editing a tab-delimited file type
let _curfile = expand("%:t")
if _curfile =~ "Makefile" || _curfile =~ "makefile" || _curfile =~ ".*\.mk"
  set noexpandtab
else
  set tabstop=4
  set shiftwidth=4
  set expandtab
endif

