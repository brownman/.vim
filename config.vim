" http://www.vi-improved.org/vimrc.php
" http://vim.wikia.com/wiki/Vim_Tips_Wiki
" http://stackoverflow.com/questions/tagged/vim
" http://items.sjbach.com/319/configuring-vim-right
" http://push.cx/2008/256-color-xterms-in-ubuntu

set nocompatible               " explicitly get out of vi-compatible mode

"------------------------------------------------------------------------------
" appearance
"------------------------------------------------------------------------------

if has('gui_running') || &t_Co > 2
  syntax on                    " enable syntax highlighting

  if has('gui_running') || &t_Co == 256
    let g:zenburn_high_Contrast = 1
    colorscheme zenburn

  elseif &t_Co == 88
    colorscheme wombat256

  else
    set background=dark        " optimize colors for dark terminals
  endif
endif

set showcmd                    " show your keystrokes in command mode
set number                     " show line numbers
set novisualbell               " don't flash the screen
set list                       " reveal invisible characters:
set listchars=tab:>-,trail:~   " ... TABs and trailing spaces
set scrolloff=3                " maintain more context around the cursor

if has('gui_running')
  set guicursor+=a:blinkwait0  " prevent the cursor from blinking
  set guifont=Monospace\ 11
end

"------------------------------------------------------------------------------
" interaction
"------------------------------------------------------------------------------

let mapleader=','              " the <Leader> key used in shortcuts
set mouse=a                    " enable mouse clicking & selection
set backspace=indent,eol,start " make backspace work as you'd expect

set confirm                    " ask user before aborting an action
set autochdir                  " switch to current file's parent directory
set hidden                     " you can change buffers without saving

set wildmenu                   " turn on command line completion wild style
set wildmode=list:longest,full " turn on wild mode huge list

set incsearch                  " highlight matches while searching
set ignorecase                 " make searching case insensitive
set smartcase                  " ... unless the query contains capital letters

"------------------------------------------------------------------------------
" formatting
"------------------------------------------------------------------------------

set autoindent                 " enable auto-indentation of input
set textwidth=79               " hard-wrap long lines as you type them
match ErrorMsg '\%<81v.\%>80v' " visually indicate the hard-wrap limit

set tabstop=8                  " render TABs using this many spaces
set expandtab                  " insert spaces when TAB is pressed
set softtabstop=2              " ... this many spaces
set shiftwidth=2               " indentation amount for << and >> commands

"------------------------------------------------------------------------------
" file types
"------------------------------------------------------------------------------

filetype on                    " auto-detect the file type
filetype plugin on             " enable file type specific plugins

autocmd FileType make setlocal noexpandtab
autocmd FileType ruby,eruby setlocal omnifunc=rubycomplete#Complete
autocmd FileType gitcommit setlocal textwidth=50

"------------------------------------------------------------------------------
" saving
"------------------------------------------------------------------------------

" keep a history of this Vim session
set history=1000
exec "set viminfo='1000,<500,:". &history . ",/" . &history . ",h"

" remove trailing spaces before saving text files
" http://vim.wikia.com/wiki/Remove_trailing_spaces
autocmd BufWritePre * :call StripTrailingWhitespace()
function! StripTrailingWhitespace()
  if !&binary && &filetype != 'diff'
    normal mz
    normal Hmy
    %s/\s\+$//e
    normal 'yz<Enter>
    normal `z
  endif
endfunction

"------------------------------------------------------------------------------
" loading
"------------------------------------------------------------------------------

" restore cursor position when re-opening files
" http://vim.wikia.com/wiki/Restore_cursor_to_file_position_in_previous_editing_session
augroup JumpCursorOnEdit
  autocmd!

  " when we reload, tell vim to restore the cursor to the saved position
  autocmd BufReadPost *
        \ if expand("<afile>:p:h") !=? $TEMP                                             |
        \   if line("'\"") > 1 && line("'\"") <= line("$")                               |
        \     let JumpCursorOnEdit_foo = line("'\"")                                     |
        \     let b:doopenfold = 1                                                       |
        \     if (foldlevel(JumpCursorOnEdit_foo) > foldlevel(JumpCursorOnEdit_foo - 1)) |
        \        let JumpCursorOnEdit_foo = JumpCursorOnEdit_foo - 1                     |
        \        let b:doopenfold = 2                                                    |
        \     endif                                                                      |
        \     exe JumpCursorOnEdit_foo                                                   |
        \   endif                                                                        |
        \ endif

  " Need to postpone using "zv" until after reading the modelines.
  autocmd BufWinEnter *
        \ if exists("b:doopenfold") |
        \   exe "normal zv"         |
        \   if(b:doopenfold > 1)    |
        \       exe "+".1           |
        \   endif                   |
        \   unlet b:doopenfold      |
        \ endif
augroup END

"------------------------------------------------------------------------------
" shortcuts
"------------------------------------------------------------------------------

" be consistent with the other capitalized EOL operators (C and D)
noremap Y y$

" make the non-graphical Vim recognize <Alt> key combinations
" http://vim.wikia.com/wiki/Fix_meta-keys_that_break_out_of_Insert_mode
if ! has('gui_running')
  for key in [1, 2, 3, 4, 5, 6, 7, 8, 9, 0]
    exec "set <A-". key .">=\e". key
  endfor
endif

" buffers
noremap <C-PageUp> :bprev<Enter>
noremap <C-PageDown> :bnext<Enter>
noremap <A-6> :FufBuffer<Enter>

" splits
noremap <A-PageUp> <C-W>W
noremap <A-PageDown> <C-W>w
noremap <A-1> <C-W>o
noremap <A-2> <C-W>s <C-W><Down>
noremap <A-3> <C-W>v <C-W><Right>
noremap <A-4> <C-W>c
noremap <A-5> <C-W>=
noremap <A-7> <C-W>_
noremap <A-8> <C-W>1_
noremap <A-9> <C-W><Bar>
noremap <A-0> <C-W>1<Bar>

" folds
noremap z<Up> zk
noremap z<Down> zj
noremap zn zk
noremap zp zj

" insert comment header
nmap <Leader>- 78A-<Esc>,cc^

" toggle line numbers
nnoremap <Leader>n :set number!<Enter>

" grep word under cursor in current buffer
nnoremap <Leader>* [I

" switch between single and double quotes using the surround plugin
"
" NOTE: we explictly set a temporary marker (z) and restore
"       it after the surround operation because otherwise the
"       surround plugin will move the cursor to the opening
"       quote of the operand after the operation, instead of
"       keeping the cursor where it was before the operation
"
nmap <Leader>' mzcs"'`z
nmap <Leader>" mzcs'"`z

" tabs for buffers
let g:buftabs_only_basename=1
let g:buftabs_active_highlight_group='Visual'

" recently opened files
let MRU_Exclude_Files='\.git/'
let MRU_Use_Current_Window = 1
nnoremap <Leader>o :MRU<Enter>

" file system browser
nnoremap <Leader>f :NERDTreeToggle<Enter>
nnoremap <Leader>F :NERDTreeFind<Enter>

" source code browser
let Tlist_Sort_Type = 'name'
let Tlist_Use_Right_Window = 1
let Tlist_Enable_Fold_Column = 0
let Tlist_GainFocus_On_ToggleOpen = 1
let Tlist_Exit_OnlyWindow = 1
nnoremap <Leader>s :TlistToggle<Enter>
nnoremap <Leader>S :TlistShowPrototype<Enter>
