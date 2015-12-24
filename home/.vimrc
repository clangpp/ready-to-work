set nocompatible
syntax on


function! SetupVAM()
  " Copied from
  " https://github.com/MarcWeber/vim-addon-manager/blob/master/README.md

  let c = get(g:, 'vim_addon_manager', {})
  let g:vim_addon_manager = c
  let c.plugin_root_dir = expand('$HOME', 1) . '/.vim/vim-addons'

  " Force your ~/.vim/after directory to be last in &rtp always:
  " let g:vim_addon_manager.rtp_list_hook =
  "     \ 'vam#ForceUsersAfterDirectoriesToBeLast'

  " most used options you may want to use:
  " let c.log_to_buf = 1
  " let c.auto_install = 0
  let &rtp.=(empty(&rtp)?'':',').c.plugin_root_dir.'/vim-addon-manager'
  if !isdirectory(c.plugin_root_dir.'/vim-addon-manager/autoload')
    execute '!git clone --depth=1 git://github.com/MarcWeber/vim-addon-manager '
        \ shellescape(c.plugin_root_dir.'/vim-addon-manager', 1)
  endif

  " This provides the VAMActivate command, you could be passing plugin names,
  " too.
  call vam#ActivateAddons([], {})
endfunction
call SetupVAM()


function! ConfigCodefmt()
  VAMActivate github:google/vim-maktaba
  VAMActivate github:google/vim-codefmt
  VAMActivate github:google/vim-glaive
  call glaive#Install()
  Glaive codefmt plugin[mappings]

  VAMActivate github:rhysd/vim-clang-format

  augroup auto_codefmt
    autocmd!

    " [ACTION REQUIRED]: install clang-format 3.4+
    autocmd FileType c,cpp AutoFormatBuffer clang-format
    autocmd FileType proto AutoFormatBuffer clang-format
    autocmd FileType javascript AutoFormatBuffer clang-format

    autocmd FileType go AutoFormatBuffer gofmt
  augroup END
endfunction
call ConfigCodefmt()


function! ConfigUlitSnips()
  VAMActivate github:SirVer/ultisnips
  VAMActivate github:honza/vim-snippets

  " Trigger configuration. Do not use <tab> if you use
  " https://github.com/Valloric/YouCompleteMe.
  "
  " NOTE: If you have g:UltiSnipsExpandTrigger and g:UltiSnipsJumpForwardTrigger
  " set to the same value then the function you are actually going to use is
  " UltiSnips#ExpandSnippetOrJump.
  let g:UltiSnipsExpandTrigger = '<c-j>'
  let g:UltiSnipsJumpForwardTrigger = '<c-j>'
  let g:UltiSnipsJumpBackwardTrigger = '<c-k>'
endfunction
call ConfigUlitSnips()


VAMActivate github:vim-scripts/mru.vim


VAMActivate github:ntpeters/vim-better-whitespace


VAMActivate github:Valloric/MatchTagAlways


VAMActivate github:scrooloose/nerdcommenter


VAMActivate github:scrooloose/syntastic


function! ConfigHighlights()
  set cursorline  " Highlights cursor line.
  set textwidth=80
  set colorcolumn=+1,+2,+3  " Highlights the print margin
  set hlsearch  " Highlights previous search results

  " Highlights status line
  highlight StatusLine ctermfg=Cyan
  highlight StatusLineNC ctermfg=Red
  set laststatus=2
endfunction
call ConfigHighlights()


" Restoring cursor position and more

function! RestoreCursorPosition()
  if line("'\"") <= line('$')
    normal! g`"
    return 1
  endif
endfunction

function! ConfigRestoreCursorPosition()
  " Tell vim to remember certain things when we exit
  "  '10  :  marks will be remembered for up to 10 previously edited files
  "  "100 :  will save up to 100 lines for each register
  "  :20  :  up to 20 lines of command-line history will be remembered
  "  %    :  saves and restores the buffer list
  "  n... :  where to save the viminfo files
  set viminfo='10,\"100,:20,%,n~/.viminfo

  autocmd BufWinEnter * call RestoreCursorPosition()
endfunction
call ConfigRestoreCursorPosition()


function! ConfigLineNumber()
  set number
  set norelativenumber
  set numberwidth=1  " Makes the line number column 'flexible' width
  set printoptions+=number:y  " Prints with line numbers
  " To annotate a file with line numbers, try :%!nl.
endfunction
call ConfigLineNumber()


" Settings for go language.
" Borrowed from xinghe@ 2015-03-05.

function! FormatGoImports()
  let cursor_position = getpos('.')
  silent exe '%!' . g:gofmt_command . ' 2>/tmp/go.$USER.err'
  if v:shell_error
    undo
  endif
  call setpos('.', cursor_position)
  silent exe "!sed --in-place -n 's/<standard input>/%/p' /tmp/go.$USER.err"

  let w = winnr()  " Remember window number.
  cf /tmp/go.$USER.err  " Pick up any errors from this file.
  cwindow 3  " Open a 3-line window for errors, or close it if none.
  " Switch back to the original window.
  exe w . 'wincmd w'
  redraw!
  echo 'Formatted'
endfunction

function! ConfigGolang()
  " Go file tab indent setting
  autocmd BufRead,BufNewFile *.go setlocal
      \ tabstop=2
      \ softtabstop=2
      \ shiftwidth=2
      \ backspace=2
      \ textwidth=100

  set rtp+=$GOROOT/misc/vim
  let g:gofmt_command = 'goimports'
  autocmd BufWritePre *.go :silent call FormatGoImports()
endfunction
call ConfigGolang()


function! ConfigPersonal()
  " VAMActivate github:tpope/vim-sensible

  " Personal settings
  colorscheme evening
  set ruler  " Shows cursor coordinate, etc at bottom right side of window
  set incsearch  " Does incremental searching
  set mouse=a  " Enables mouse
  set autoread
  set equalalways  " Makes split windows equal height and width
  set splitbelow
  set splitright
endfunction
call ConfigPersonal()


" NOTE: Keep this at end of file.
filetype plugin indent on  " Used-by: google.vim.
