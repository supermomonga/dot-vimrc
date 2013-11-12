" Kanari Sugoi .vimrc

" Rules  {{{

" Mapping  {{{
"
" * Emacs-like mapping
"    - If the command is not countable or motion,
"      it should be mapped with "<Space>" or "<C-c>" prefixed binding
"    - The command for global scene should be mapped with "<Space>" prefix,
"      but the command which depends on buftype or filetype should be mapped with
"      "<C-c>" prefix.
"    - Separating global and buffer/file local is very important to use
"      mappings efficiency.
"
" }}}

" NeoBundle  {{{
"
" * Managing
"   - Options for "NeoBundleLazy" should be only "build", "depends", and other
"     options which are only related of installing, building, and updating.
"   - Other options such as "autoload" and plugin's own settings should be
"     set in their each "s:bundle_tap()" sections.
"   - Separating plugins' list and their configuration sections is very
"     important.
"
" }}}

" }}}

" Basic  {{{

" Absolute {{{

" Use VIM features instead of vi
" It canses many side effects, so you need to write the top of the ".vimrc".
set nocompatible

" Reset Autocmd group
augroup MyAutoCmd
  autocmd!
augroup END

" To use camel_case.
let g:My = {}
let s:my = g:My

" Echo startup time on start
if has('vim_starting') && has('reltime')
  let g:startuptime = reltime()
  augroup MyAutoCmd
    autocmd! VimEnter * let g:startuptime = reltime(g:startuptime) | redraw
    \ | echomsg 'startuptime: ' . reltimestr(g:startuptime)
  augroup END
endif

" .vim folder
" Maybe I will never use other os than OS X...
if has('unix')
  let $VIM_DOTVIM_DIR=expand('~/.vim')
else
  let $VIM_DOTVIM_DIR=expand('~/.vim')
endif

let $VIM_REMOTE_BUNDLE_DIR = $VIM_DOTVIM_DIR . '/bundle'
let $VIM_LOCAL_BUNDLE_DIR = $VIM_DOTVIM_DIR . '/local_bundle'
let $VIM_NEOBUNDLE_DIR = $VIM_REMOTE_BUNDLE_DIR . '/neobundle.vim'

let $VIM_SWAP_DIR = $VIM_DOTVIM_DIR . '/tmp/swap'
let $VIM_BACKUP_DIR = $VIM_DOTVIM_DIR . '/tmp/backup'
let $VIM_UNDO_DIR = $VIM_DOTVIM_DIR . '/tmp/undo'


" }}}

" Encoding  {{{
"
let &termencoding = &encoding
set encoding=utf-8
set fileencoding=utf-8
set fileencodings=ucs-bom,utf-8,iso-2022-jp-3,iso-2022-jp,eucjp-ms,euc-jisx0213,euc-jp,sjis,cp932
set fileformats=unix,dos,mac

" }}}

" Functions  {{{

function! s:set(variable, value) "  {{{
  execute printf("let &%s = a:value", a:variable)
endfunction " }}}

function! s:path_separator() " {{{
  if has('win32') || has('win64')
    return ';'
  else
    return ':'
  endif
endfunction " }}}

function! s:prepend_path(current, path) "  {{{
  return a:current == '' ?
        \ a:path : a:path . s:path_separator() . a:current
endfunction " }}}

function! s:append_path(current, path) "  {{{
  return a:current == '' ?
        \ a:path : ( a:current . s:path_separator() . a:path )
endfunction " }}}

function! s:dirname(path) "  {{{
  return fnamemodify(a:path, ':h')
endfunction " }}}

function! s:bundle_tap(bundle) " {{{
  let s:tapped_bundle = neobundle#get(a:bundle)
  return neobundle#is_installed(a:bundle)
endfunction " }}}

function! s:bundle_config(config) " {{{
  if exists("s:tapped_bundle") && s:tapped_bundle != {}
    " let a:config.lazy = 1
    call neobundle#config(s:tapped_bundle.name, a:config)
  endif
endfunction " }}}

function! s:bundle_untap() " {{{
  let s:tapped_bundle = {}
endfunction " }}}

function! SelectInteractive(question, candidates) " {{{
  try
    let a:candidates[0] = toupper(a:candidates[0])
    let l:select = 0
    while index(a:candidates, l:select, 0, 1) == -1
      let l:select = input(a:question . ' [' . join(a:candidates, '/') . '] ')
      if l:select == ''
        let l:select = a:candidates[0]
      endif
    endwhile
    return tolower(l:select)
  finally
    redraw!
  endtry
endfunction " }}}

function! BufferWipeoutInteractive() " {{{
  if &modified == 1
    let l:selected = SelectInteractive('Buffer is unsaved. Force quit?', ['n', 'w', 'q'])
    if l:selected == 'w'
      write
      bwipeout
    elseif l:selected == 'q'
      bwipeout!
    endif
  else
    bwipeout
  endif
endfunction " }}}

" }}}

" Environment Variables {{{

let $PATH = s:append_path($PATH, '~/bin')
let $PATH = s:prepend_path($PATH, '/usr/local/bin')
let $PATH = s:append_path($PATH, '/Applications/MacVim.app/Contents/MacOS')
let $PATH = s:append_path($PATH, '/Applications/Octave.app/Contents/Resources/bin')

" Automatic detect current ruby's bin directory.
" Including "gem", "rails", and others.
let $PATH = s:append_path($PATH, s:dirname(resolve('/usr/local/bin/ruby')))

" Gnuterm
let $GNUTERM = 'x11'

" Drip the JVM process manager
if executable('drip')
  let $JAVACMD = '/usr/local/bin/drip'
  let $DRIP_INIT_CLASS = 'org.jruby.main.DripMain'
  let $JRUBY_OPTS = '-J-XX:+TieredCompilation -J-XX:TieredStopAtLevel=1 -J-noverify -Xverify:nine'
  " let $JAVA_OPTS = '-d32 -client'
endif

" Java {{{

" It's necessary to show Japanese messages from JDK
let $LANG = 'ja_JP.UTF-8'

" Set JAVA_HOME to select your favorite JDK version.
let $JAVA_HOME = '/Library/Java/JavaVirtualMachines/jdk1.7.0_25.jdk/Contents/Home'
let $CLASSPATH = s:append_path($CLASSPATH, '.')

" The directory which contains `jfxrt.jar`.
" Note that in JDK8, `jfxrt.jar` is in ext folder
if match($JAVA_HOME, 'jdk1.8') != -1
  let $JFX_DIR = $JAVA_HOME . '/jre/lib/ext/'
else
  let $JFX_DIR = $JAVA_HOME . '/jre/lib/'
endif

" }}}

" }}}

" Appearance UI  {{{

" Don't ring a bell and flash
set vb t_vb=

" Show line number
set number

" Always show tab
set showtabline=2

" Show invisible chars
set list

" Alternative chars for eol, tab, and others
set listchars=eol:$,tab:>-,extends:<

" When input close bracket, show start bracket
set showmatch

" Fix zenkaku chars' width
set ambiwidth=double

" }}}

" Appearance Font  {{{

set gfn=セプテンバーＭ-等幅:h14
set gfw=セプテンバーＭ-等幅:h14

" }}}

" Appearance Color theme  {{{

colorscheme desert

" }}}

" Syntax  {{{

" }}}

" Backup  {{{

call s:set('directory', $VIM_SWAP_DIR)
call s:set('backupdir', $VIM_BACKUP_DIR)
call s:set('undodir', $VIM_UNDO_DIR)

if has('persistent_undo')
  set undodir=./.vimundo,$VIM_UNDO_DIR
  autocmd MyAutoCmd BufReadPre ~/* setlocal undofile
endif

" }}}

" History  {{{

" Command history
set history=10000

" }}}

" }}}

" Edit  {{{

" Indent  {{{

" Use Space instead of Tab to make indent
set expandtab

" TODO: Width of tab?
" TODO: Ato de yoku shiraberu.
set tabstop=2

" Hoe many spaces to each indent level
set shiftwidth=2

" Automatically adjust indent
set autoindent

" Automatically indent when insert a new line
set smartindent

" Insert an indent when keydown <Tab> in indent spaces
set smarttab

" Symbols to use indent or other
set listchars=tab:▸\ ,trail:-,extends:»,precedes:«,nbsp:%

" }}}

" Movement  {{{
" BS can delete newline or indent
set backspace=indent,eol,start
" Can move at eol, bol
set whichwrap=b,s,h,l,<,>,[,]
" }}}

" Folding  {{{

" Use marker to fold
" e.g. {{{kanari_sugoi_code}}}
" TODO: [Problem] When I input close marker which is "}" three times,
"       the all foldings after that will be opened... Kanari fuben.
set foldmethod=marker

" }}}

" Search  {{{

" incremental search
set incsearch

" Match words with ignore upper-lower case
set ignorecase

" Don't think upper-lower case until upper-case input
set smartcase

" Highlight searched words
set hlsearch

" }}}

" Buffer Handling  {{{

" Can change buffer in window no matter buffer is unsaved
set hidden

" }}}

" Spelling  {{{

" Enable spell checker for English words
set spell spelllang=en_us

" }}}

" TODO: Input Method  {{{

" TODO: Disable Japanese input mode when exit from the insert mode

" }}}

" Basic Key Mapping  {{{

" [Emacs] Increment, Decrement by -, +
" Because I want to use <C-x> for Emacs-like mapping
" For test: [1, 6]
nnoremap +  <C-a>
nnoremap -  <C-x>

" [Emacs] <C-x>k to close buffer completely
" nnoremap <C-x>k  :bw<CR>
nnoremap <C-x>k  :call BufferWipeoutInteractive()<CR>

" [Emacs] <C-e> to end of line
nnoremap <C-e>  $

" [Emacs] <C-k> to delete a line
nnoremap <C-k>  dd

" Toggle 0 and ^
nnoremap <expr>0  col('.') == 1 ? '^' : '0'
nnoremap <expr>^  col('.') == 1 ? '^' : '0'

" : without <Shift>
nnoremap ;  :
vnoremap ;  :

" _ : Quick horizontal splits
nnoremap _  :sp<CR>

" | : Quick vertical splits
nnoremap <bar>  :vsp<CR>

" N: Find next occurrence backward
nnoremap N  Nzzzv
nnoremap n  nzzzv

" Backspace: Act like normal backspace
" TODO: Mac OS X doesn't have <BS>. have delete key.
nnoremap <BS>  X

" cmdwin
nnoremap :  q:i

" TODO: Move those settings to right section
autocmd MyAutoCmd CmdwinEnter [:>] iunmap <buffer> <Tab>
autocmd MyAutoCmd CmdwinEnter [:>] nunmap <buffer> <Tab>

" JK peropero
" Use logical move instead of physical ones
nnoremap j gj
nnoremap k gk

" Easy to make selection to pars
" TODO: u-n, iranai kamo...
onoremap ) f)
onoremap ( t(

" Insert space in normal mode easily
nnoremap <C-l>  i<Space><Esc><Right>
nnoremap <C-h>  i<Space><Esc>

" }}}

" Filetype setting  {{{

autocmd MyAutoCmd BufRead,BufNewFile *.md  setfiletype markdown

" }}}

" }}}

" Plugins  {{{

" Secret  {{{

" This file contains only g:vimrc_secrets.
if filereadable(expand('~/.secret_vimrc'))
  let g:vimrc_secrets = {}
  execute 'source' expand('~/.secret_vimrc')
endif

" }}}

" Setup  {{{

" To use NeoBundle, manually add to runtimepath
if has('vim_starting')
  set runtimepath+=$VIM_NEOBUNDLE_DIR
  " To load my local development plugin
  call neobundle#local(expand($VIM_LOCAL_BUNDLE_DIR), { 'resettable' : 0 })
endif
" To load remote plugin
call neobundle#rc(expand($VIM_REMOTE_BUNDLE_DIR))

" Let NeoBundle manage NeoBundle
NeoBundleFetch 'Shougo/neobundle.vim'



" }}}

" List  {{{

NeoBundle 'Shougo/vimproc.vim', { 'build' : {
      \   'windows' : 'mingw32-make -f make_mingw32.mak',
      \   'cygwin'  : 'make -f make_cygwin.mak',
      \   'mac'     : 'make -f make_mac.mak',
      \   'unix'    : 'make -f make_unix.mak',
      \ }}
NeoBundle 'bling/vim-airline'
NeoBundle 'surround.vim'
NeoBundle 'kana/vim-repeat'
NeoBundle 'kana/vim-submode'
NeoBundle 'kana/vim-textobj-user'
NeoBundle 'kana/vim-textobj-entire', { 'depends' : 'kana/vim-textobj-user' }
NeoBundle 'kana/vim-textobj-function', { 'depends' : 'kana/vim-textobj-user' }
NeoBundle 'kana/vim-textobj-indent', { 'depends' : 'kana/vim-textobj-user' }
NeoBundle 'rhysd/vim-textobj-ruby', { 'depends' : 'kana/vim-textobj-user' }
NeoBundle 'osyo-manga/vim-textobj-multiblock', { 'depends' : 'kana/vim-textobj-user' }
NeoBundle 'osyo-manga/vim-textobj-multitextobj', { 'depends' : 'kana/vim-textobj-user' }
NeoBundle 'osyo-manga/vim-automatic', { 'depends' : [ 'osyo-manga/vim-gift', 'osyo-manga/vim-reunions' ] }
NeoBundle 'osyo-manga/vim-reti', { 'depends' : [ 'osyo-manga/vim-chained' ] }
NeoBundle 'osyo-manga/vim-anzu'
NeoBundle 'jceb/vim-hier'
NeoBundle 'LeafCage/foldCC'
NeoBundle 'vim-jp/vimdoc-ja'
NeoBundle 'tpope/vim-fugitive'
NeoBundle 'tomtom/tcomment_vim'
NeoBundle 'tpope/vim-rbenv'
NeoBundleLazy 'Shougo/unite.vim', { 'depends' : [ 'Shougo/vimproc.vim' ] }
NeoBundleLazy 'Shougo/vimshell.vim', { 'depends' : [ 'Shougo/vimproc.vim' ] }
NeoBundleLazy 'ujihisa/vimshell-ssh', { 'depends' : [ 'Shougo/vimshell.vim' ] }
NeoBundleLazy 'Shougo/vimfiler.vim', { 'depends' : [ 'Shougo/unite.vim' ] }
NeoBundleLazy 'Shougo/unite-ssh', { 'depends' : [ 'Shougo/unite.vim' ] }
NeoBundleLazy 'Shougo/neosnippet.vim'
NeoBundleLazy 'honza/vim-snippets'
NeoBundleLazy 'matthewsimo/angular-vim-snippets'
NeoBundleLazy 'Shougo/neocomplete.vim'
NeoBundleLazy 'tsukkee/unite-help', { 'depends' : [ 'Shougo/unite.vim' ] }
NeoBundleLazy 'Shougo/unite-outline', { 'depends' : [ 'Shougo/unite.vim' ] }
NeoBundleLazy 'ujihisa/unite-colorscheme', { 'depends' : [ 'Shougo/unite.vim' ] }
NeoBundleLazy 'ujihisa/unite-locate', { 'depends' : [ 'Shougo/unite.vim' ] }
NeoBundleLazy 'osyo-manga/unite-quickfix', { 'depends' : [ 'Shougo/unite.vim' ] }
NeoBundleLazy 'osyo-manga/vim-pronamachang', { 'depends' : [ 'osyo-manga/vim-sound', 'Shougo/vimproc.vim' ] }
NeoBundleLazy 'osyo-manga/vim-sugarpot', { 'depends' : [ 'Shougo/vimproc.vim' ] }
NeoBundleLazy 'h1mesuke/vim-alignta'
NeoBundleLazy 'kana/vim-smartinput'
NeoBundleLazy 'cohama/vim-smartinput-endwise', { 'depends' : [ 'kana/vim-smartinput' ] }
NeoBundleLazy 'mattn/gist-vim', { 'depends' : [ 'mattn/webapi-vim' ] }
NeoBundleLazy 'mattn/emmet-vim'
NeoBundleLazy 'thinca/vim-prettyprint'
NeoBundleLazy 'thinca/vim-quickrun'
NeoBundleLazy 'thinca/vim-ref'
NeoBundleLazy 'thinca/vim-qfreplace'
NeoBundleLazy 'tyru/open-browser.vim'
NeoBundleLazy 'yuratomo/w3m.vim'
NeoBundleLazy 'rbtnn/vimconsole.vim'
NeoBundleLazy 'vim-jp/vital.vim'
NeoBundleLazy 'groenewege/vim-less'
NeoBundleLazy 'slim-template/vim-slim'
NeoBundleLazy 'kchmck/vim-coffee-script'
NeoBundleLazy 'dsawardekar/riml.vim'

" momonga's Kanari Sugoi Plugins
NeoBundleLazy 'supermomonga/shaberu.vim', { 'depends' : [ 'Shougo/vimproc.vim' ] }

" Communication
NeoBundleLazy 'basyura/J6uil.vim', { 'depends' : [ 'Shougo/vimproc.vim', 'mattn/webapi-vim' ] }
NeoBundleLazy 'basyura/TweetVim', 'dev', { 'depends' : [
      \   'tyru/open-browser.vim',
      \   'basyura/twibill.vim',
      \   'basyura/bitly.vim',
      \   'Shougo/unite.vim',
      \   'Shougo/unite-outline',
      \   'Shougo/vimproc.vim',
      \   'mattn/favstar-vim',
      \   'mattn/webapi-vim'
      \ ] }

" Ruby
NeoBundleLazy 'vim-ruby/vim-ruby'
NeoBundleLazy 'taka84u9/vim-ref-ri', { 'depends' : [ 'Shougo/unite.vim', 'thinca/vim-ref' ] }
NeoBundleLazy 'tpope/vim-rails'
NeoBundleLazy 'basyura/unite-rails', { 'depends' : [ 'Shougo/unite.vim' ] }

" Java
NeoBundleLazy 'vim-scripts/javacomplete', {
      \   'build': {
      \     'cygwin': 'javac autoload/Reflection.java',
      \     'mac': 'javac autoload/Reflection.java',
      \     'unix': 'javac autoload/Reflection.java'
      \   },
      \ }

" TODO: Windows build command to get .ctags
NeoBundleLazy 'alpaca-tc/alpaca_tags', {
      \   'depends' : [ 'Shougo/vimproc.vim' ],
      \   'build' : {
      \     'mac' : 'wget https://raw.github.com/alpaca-tc/alpaca_tags/master/.ctags -O ~/.ctags',
      \     'unix' : 'wget https://raw.github.com/alpaca-tc/alpaca_tags/master/.ctags -O ~/.ctags',
      \   }
      \ }



" TODO: atode settei simasu...
" NeoBundleLazy 'tpope/vim-markdown'
" NeoBundleLazy 'tsukkee/lingr-vim'


" Disable some local bundles
NeoBundleDisable vimshell-kawaii.vim
NeoBundleDisable vimshell-scopedalias.vim
NeoBundleDisable unite-vacount2012.vim
NeoBundleDisable vimshell-suggest.vim
NeoBundleDisable vimshell-wakeup.vim


" Required to use
filetype plugin indent on

" }}}

" Plugin Configurations  {{{

if s:bundle_tap('unite.vim') " {{{
  call s:bundle_config({
        \   'autoload' : {
        \     'commands' : [
        \       {
        \         'name' : 'Unite',
        \         'complete' : 'customlist,unite#complete_source'
        \       },
        \       'UniteWithCursorWord',
        \       'UniteWithInput'
        \     ]
        \   }
        \ })

  function! s:unite_menu_map_func(key, value)
    let [word, value] = a:value
    if isdirectory(value)
      return {
            \   'word' : '[directory] ' . word,
            \   'kind' : 'directory',
            \   'action__directory' : value
            \ }
    elseif !empty(glob(value))
      return {
            \   'word' : '[file] ' . word,
            \   'kind' : 'file',
            \   'default_action' : 'tabdrop',
            \   'action__path' : value,
            \ }
    else
      return {
            \   'word' : '[command] ' . word,
            \   'kind' : 'command',
            \   'action__command' : value
            \ }
    endif
  endfunction

  function! s:tapped_bundle.hooks.on_source(bundle)

    " General
    let g:unite_force_overwrite_statusline = 0
    let g:unite_kind_jump_list_after_jump_scroll=0
    let g:unite_enable_start_insert = 0
    let g:unite_source_rec_min_cache_files = 1000
    let g:unite_source_rec_max_cache_files = 5000
    let g:unite_source_file_mru_long_limit = 6000
    let g:unite_source_file_mru_limit = 300
    let g:unite_source_directory_mru_long_limit = 6000
    let g:unite_prompt = '❯ '

    " Unite-menu
    let g:unite_source_menu_menus = get(g:, 'unite_source_menu_menus', {})
    let g:unite_source_menu_menus.global = { 'description' : 'global shortcut' }
    let g:unite_source_menu_menus.unite = { 'description' : 'unite shortcut' }
    let g:unite_source_menu_menus.global.map = function('s:unite_menu_map_func')
    let g:unite_source_menu_menus.unite.map = function('s:unite_menu_map_func')
    let g:unite_source_menu_menus.global.candidates = [
          \   [ '[edit] vimrc' , expand('~/.vimrc') ],
          \   [ '[edit] secret_vimrc' , expand('~/.secret_vimrc') ],
          \   [ '[terminal] VimShell' , ':VimShell' ],
          \   [ '[twitter] TweetVim' , ':Unite tweetvim' ],
          \   [ '[lingr] J6uil' , ':J6uil' ],
          \ ]
    let g:unite_source_menu_menus.unite.candidates = [
          \   [ 'neobundle/update' , ':Unite neobundle/update -log' ],
          \   [ 'neobundle/install' , ':Unite neobundle/install -log' ],
          \   [ 'J6uil/rooms' , ':Unite J6uil/rooms' ],
          \   [ 'J6uil/members' , ':Unite J6uil/members' ],
          \   [ 'files', ':Unite -start-insert -buffer-name=files buffer_tab file file_mru'],
          \   [ 'outline', ':Unite -start-insert outline'],
          \   [ 'help', ':Unite -start-insert help'],
          \   [ 'buffer', ':Unite -start-insert buffer'],
          \   [ 'line', ':Unite -start-insert -auto-preview -buffer-name=search line'],
          \   [ 'quickfix', ':Unite -no-split -no-quit -auto-preview quickfix'],
          \   [ 'grep', ':Unite grep -no-quit'],
          \   [ 'source', ':Unite -start-insert source'],
          \   [ 'locate', ':Unite -start-insert locate'],
          \   [ 'theme', ':Unite -auto-preview colorscheme'],
          \ ]

  endfunction

  nnoremap <silent> <Space>u  :<C-u>Unite -start-insert menu:unite<CR>
  nnoremap <silent> <Space>m  :<C-u>Unite -start-insert menu:global<CR>
  nnoremap <silent> <Space>f  :<C-u>Unite -start-insert -buffer-name=files buffer_tab file_mru<CR>
  nnoremap <silent> <Space>b  :<C-u>Unite -start-insert buffer<CR>
  nnoremap <silent> <Space>s  :<C-u>Unite -start-insert -auto-preview -no-split -buffer-name=search line<CR>
  nnoremap <silent> <Space>l  :<C-u>Unite -start-insert locate<CR>
  nnoremap <silent> <Space>g  :<C-u>Unite grep -no-quit<CR>

  " TODO: Should those mappings be moved to their own setting section?
  " That seems collect but it provides better look of the Unite-source
  " mappings list.
  if neobundle#is_installed('unite-quickfix')
    nnoremap <silent> <Space>q  :<C-u>Unite -no-quit -auto-preview -no-split quickfix<CR>
  endif
  if neobundle#is_installed('unite-help')
    nnoremap <silent> <Space>o  :<C-u>Unite -start-insert -auto-preview
          \ -no-split outline<CR>
  endif
  if neobundle#is_installed('unite-outline')
    nnoremap <silent> <Space>h  :<C-u>Unite -start-insert help<CR>
  endif

  call s:bundle_untap()
endif " }}}

if s:bundle_tap('vimfiler.vim') " {{{
  call s:bundle_config({
        \ 'autoload' : {
        \   'commands' : [
        \     { 'name' : 'VimFiler', 'complete' : 'customlist,vimfiler#complete' },
        \     { 'name' : 'VimFilerExplorer', 'complete' : 'customlist,vimfiler#complete' },
        \     { 'name' : 'Edit', 'complete' : 'customlist,vimfiler#complete' },
        \     { 'name' : 'Write', 'complete' : 'customlist,vimfiler#complete' },
        \     'Read',
        \     'Source'
        \   ],
        \   'mappings' : '<Plug>(vimfiler_',
        \   'explorer' : 1,
        \ }
        \ })


  function! s:tapped_bundle.hooks.on_source(bundle)
  endfunction

  let g:vimfiler_safe_mode_by_default = 0
  let g:unite_kind_file_use_trashbox = 1
  let g:vimfiler_as_default_explorer = 1
  let g:vimfiler_as_default_explorer = 1

  nnoremap <Space>e  :<C-u>VimFilerExplorer -winwidth=65<CR>

  call s:bundle_untap()
endif " }}}

if s:bundle_tap('unite-quickfix') " {{{
  call s:bundle_config({
        \   'autoload' : {
        \     'unite_sources' : [
        \       'quickfix',
        \     ],
        \   }
        \ })

  function! s:tapped_bundle.hooks.on_source(bundle)
  endfunction

  call s:bundle_untap()
endif " }}}

if s:bundle_tap('unite-outline') " {{{
  call s:bundle_config({
        \   'autoload' : {
        \     'unite_sources' : [
        \       'outline',
        \     ],
        \   }
        \ })

  function! s:tapped_bundle.hooks.on_source(bundle)
  endfunction

  call s:bundle_untap()
endif " }}}

if s:bundle_tap('unite-help') " {{{
  call s:bundle_config({
        \   'autoload' : {
        \     'unite_sources' : [
        \       'help',
        \     ],
        \   }
        \ })

  function! s:tapped_bundle.hooks.on_source(bundle)
  endfunction

  call s:bundle_untap()
endif " }}}

if s:bundle_tap('unite-ssh') " {{{
  call s:bundle_config({
        \   'autoload' : {
        \     'unite_sources' : [
        \       'ssh',
        \     ],
        \   }
        \ })

  function! s:tapped_bundle.hooks.on_source(bundle)
  endfunction

  call s:bundle_untap()
endif " }}}

if s:bundle_tap('unite-colorscheme') " {{{
  call s:bundle_config({
        \   'autoload' : {
        \     'unite_sources' : [
        \       'colorscheme',
        \     ],
        \   }
        \ })

  function! s:tapped_bundle.hooks.on_source(bundle)
  endfunction

  call s:bundle_untap()
endif " }}}

if s:bundle_tap('unite-locate') " {{{
  call s:bundle_config({
        \   'autoload' : {
        \     'unite_sources' : [
        \       'locate',
        \     ],
        \   }
        \ })

  function! s:tapped_bundle.hooks.on_source(bundle)
  endfunction

  call s:bundle_untap()
endif " }}}

if s:bundle_tap('shaberu.vim') " {{{
  call s:bundle_config({
        \   'autoload' : {
        \     'commands' : [ 'ShaberuSay', 'ShaberuMuteOn', 'ShaberuMuteOff', 'ShaberuMuteToggle' ]
        \   }
        \ })

  function! s:tapped_bundle.hooks.on_source(bundle)
  endfunction

  let g:shaberu_user_define_say_command = 'say-openjtalk "%%TEXT%%"'

  " Vim core
  autocmd MyAutoCmd VimEnter * ShaberuSay 'ビムにようこそ'
  autocmd MyAutoCmd VimLeave * ShaberuSay 'さようなら'

  " VimShell
  autocmd FileType vimshell
        \ call vimshell#hook#add('chpwd' , 'my_vimshell_chpwd' , 'g:my_vimshell_chpwd')
        \| call vimshell#hook#add('emptycmd', 'my_vimshell_emptycmd', 'g:my_vimshell_emptycmd')
        \| call vimshell#hook#add('notfound', 'my_vimshell_notfound', 'g:my_vimshell_notfound')

  function! g:my_vimshell_chpwd(args, context)
    ShaberuSay 'よっこいしょ'
  endfunction
  function! g:my_vimshell_emptycmd(cmdline, context)
    :ShaberuSay 'コマンドを入力してください'
    return a:cmdline
  endfunction
  function! g:my_vimshell_notfound(cmdline, context)
    :ShaberuSay 'コマンドが見つかりません'
    return a:cmdline
  endfunction

  " .vimrc保存時に自動的にsource
  autocmd MyAutoCmd BufWritePost .vimrc nested source $MYVIMRC | ShaberuSay 'ビムアールシーを読み込みました'
  " 開発用ディレクトリ内.vimファイルに関して、ファイル保存時に自動でsourceする
  execute 'autocmd MyAutoCmd BufWritePost,FileWritePost' $VIM_LOCAL_BUNDLE_DIR . '*.vim' 'source <afile> | echo "sourced : " . bufname("%") | ShaberuSay "ソースしました"'

  call s:bundle_untap()
endif " }}}

if s:bundle_tap('vimshell.vim') " {{{
  call s:bundle_config({
        \   'autoload' : {
        \     'commands' : [ 'VimShell', 'VimShellPop' ]
        \   }
        \ })

  function! s:tapped_bundle.hooks.on_source(bundle)
  endfunction

  nnoremap <C-x><C-v>  :<C-u>VimShellPop -toggle<CR>
  inoremap <C-x><C-v>  :<C-u>VimShellPop -toggle<CR>
  nnoremap <Space>v  :<C-u>VimShellPop -toggle<CR>

  " buffer local mapping
  function! s:my_vimshell_mappings()
    imap <buffer> <C-e>  <ESC>$a
  endfunction
  autocmd MyAutoCmd FileType vimshell call s:my_vimshell_mappings()

  " Run VimShell when launch Vim
  autocmd MyAutoCmd VimEnter * VimShell

  call s:bundle_untap()
endif " }}}

if s:bundle_tap('vim-textobj-multiblock') " {{{

  call s:bundle_config({})

  function! s:tapped_bundle.hooks.on_source(bundle)
  endfunction

  let g:textobj_multiblock_blocks = [
        \   ['(', ')', 1],
        \   ['[', ']', 1],
        \   ['{', '}', 1],
        \   ['<', '>', 1],
        \   ['"', '"', 1],
        \   ["'", "'", 1],
        \   ['`', '`', 1],
        \   ['|', '|', 1],
        \ ]

        " Couldn't use multiple chars
        " \   ['if', 'elsif'],
        " \   ['if', 'else'],
        " \   ['if', 'end'],
        " \   ['elsif', 'end'],
        " \   ['elsif', 'elsif'],
        " \   ['elsif', 'else'],
        " \   ['else', 'end'],
        " \   ['do', 'end'],

  call s:bundle_untap()
endif " }}}

if s:bundle_tap('neocomplete.vim') " {{{

  call s:bundle_config({
        \   'autoload' : {
        \     'insert' : 1,
        \   }
        \ })

  function! s:tapped_bundle.hooks.on_source(bundle)
  endfunction

  " Enable at startup
  let g:neocomplete#enable_at_startup = 1

  " Smartcase
  let g:neocomplete#enable_smart_case = 1

  " Enable _ separated completion
  let g:neocomplete_enable_underbar_completion = 1

  " Minimum length to cache
  let g:neocomplete_min_syntax_length = 3

  " Max size of candidates to show
  let g:neocomplete#max_list = 1000

  " How many length to need to start completion
  let g:neocomplete_auto_completion_start_length = 2

  " Auto select the first candidate
  " let g:neocomplete_enable_auto_select = 1

  " Force to overwrite complete func
  let g:neocomplete_force_overwrite_completefunc = 1

  " let g:neocomplete_enable_camel_case_completion = 1
  let g:neocomplete#skip_auto_completion_time = '0.2'

  " Cancel and close popup
  " imap <expr><C-g> neocomplete#cancel_popup()

  " Omni completion patterns
  let g:neocomplete#force_omni_input_patterns = get(g:, 'neocomplete#force_omni_input_patterns', {})
  let g:neocomplete#force_omni_input_patterns.ruby = '[^. *\t]\.\w*\|\h\w*::'

  " Omni completion functions
  let g:neocomplete#sources#omni#functions = get(g:, 'neocomplete#sources#omni#functions', {})
  let g:neocomplete#sources#omni#functions.ruby = 'rubycomplete#Complete'

  call s:bundle_untap()
endif " }}}

if s:bundle_tap('neosnippet.vim') " {{{

  call s:bundle_config({
        \   'autoload' : {
        \     'insert' : 1,
        \     'filetype' : 'snippet',
        \     'commands' : [ 'NeoSnippetEdit', 'NeoSnippetSource' ],
        \     'filetypes' : [ 'nsnippet' ],
        \     'unite_sources' :
        \       ['snippet', 'neosnippet/user', 'neosnippet/runtime']
        \   }
        \ })

  function! s:tapped_bundle.hooks.on_source(bundle)
  endfunction

  let g:neosnippet#enable_snipmate_compatibility = 1
  " My original snippets
  let g:neosnippet_snippets_directories = add(
        \   get(g:, 'neosnippet_snippets_directories', []),
        \   '~/.vim/snippets'
        \ )
  let g:neosnippet#snippets_directory = join(g:neosnippet_snippets_directories, ',')
  " <CR> to expand snippet if can
  imap <expr><CR> !pumvisible() ? "\<CR>" :
        \ neosnippet#expandable() ? "\<Plug>(neosnippet_expand)" :
        \ neocomplete#close_popup()
  " supertab.
  imap <expr><TAB> pumvisible() ? "\<C-n>" :
        \ neosnippet#jumpable() ? "\<Plug>(neosnippet_jump)" :
        \ "\<TAB>"
  smap <expr><TAB> pumvisible() ? "\<C-n>" :
        \ neosnippet#jumpable() ? "\<Plug>(neosnippet_jump)" :
        \ "\<TAB>"

  call s:bundle_untap()
endif " }}}

if s:bundle_tap('vim-snippets') " {{{

  let g:neosnippet_snippets_directories = add(
        \   get(g:, 'neosnippet_snippets_directories', []),
        \   $VIM_REMOTE_BUNDLE_DIR . '/vim-snippets/snippets'
        \ )
  let g:neosnippet#snippets_directory = join(g:neosnippet_snippets_directories, ',')

  call s:bundle_untap()
endif " }}}

if s:bundle_tap('angular-vim-snippets') " {{{

  let g:neosnippet_snippets_directories = add(
        \   get(g:, 'neosnippet_snippets_directories', []),
        \   $VIM_REMOTE_BUNDLE_DIR . '/angular-vim-snippets/snippets'
        \ )
  let g:neosnippet#snippets_directory = join(g:neosnippet_snippets_directories, ',')

  call s:bundle_untap()
endif " }}}

if s:bundle_tap('vim-alignta') " {{{

  call s:bundle_config({
        \   'autoload' : {
        \     'commands' : ['Alignta'],
        \   }
        \ })

  function! s:tapped_bundle.hooks.on_source(bundle)
    
  endfunction

  call s:bundle_untap()
endif " }}}

if s:bundle_tap('foldCC') " {{{

  call s:bundle_config({})

  function! s:tapped_bundle.hooks.on_source(bundle)
  endfunction

  set foldmethod=marker
  set foldtext=FoldCCtext()
  set foldcolumn=0
  set fillchars=vert:\|

  call s:bundle_untap()
endif " }}}

if s:bundle_tap('tcomment_vim') " {{{

  call s:bundle_config({})

  function! s:tapped_bundle.hooks.on_source(bundle)
  endfunction

  call s:bundle_untap()
endif " }}}

if s:bundle_tap('vim-smartinput') " {{{

  call s:bundle_config({
        \   'autoload' : {
        \     'insert' : 1
        \   }
        \ })

  function! s:tapped_bundle.hooks.on_source(bundle)
    echomsg "smartinput define rules"
    call smartinput#clear_rules()
    call smartinput#define_default_rules()
    call smartinput_endwise#define_default_rules()
    echomsg "/smartinput define rules"
  endfunction

  call s:bundle_untap()
endif " }}}

" if s:bundle_tap('vim-smartinput-endwise') " {{{
" 
"   " call s:bundle_config({
"   "       \   'autoload' : {
"   "       \     'insert' : 0
"   "       \   }
"   "       \ })
"   function! s:tapped_bundle.hooks.on_source(bundle)
"     echomsg "there"
"   endfunction
" 
"   call s:bundle_untap()
" endif " }}}

if s:bundle_tap('vim-submode') " {{{

  call s:bundle_config({})

  function! s:tapped_bundle.hooks.on_source(bundle)
    let g:submode_keep_leaving_key = 1
    " tab moving
    call submode#enter_with('changetab', 'n', '', 'gt', 'gt')
    call submode#enter_with('changetab', 'n', '', 'gT', 'gT')
    call submode#map('changetab', 'n', '', 't', 'gt')
    call submode#map('changetab', 'n', '', 'T', 'gT')
    " undo/redo
    call submode#enter_with('undo/redo', 'n', '', 'g-', 'g-')
    call submode#enter_with('undo/redo', 'n', '', 'g+', 'g+')
    call submode#map('undo/redo', 'n', '', '-', 'g-')
    call submode#map('undo/redo', 'n', '', '+', 'g+')
    " resize window
    call submode#enter_with('winsize', 'n', '', '<C-w>>', '<C-w>>')
    call submode#enter_with('winsize', 'n', '', '<C-w><', '<C-w><')
    call submode#enter_with('winsize', 'n', '', '<C-w>+', '<C-w>-')
    call submode#enter_with('winsize', 'n', '', '<C-w>-', '<C-w>+')
    call submode#map('winsize', 'n', '', '>', '<C-w>>')
    call submode#map('winsize', 'n', '', '<', '<C-w><')
    call submode#map('winsize', 'n', '', '+', '<C-w>-')
    call submode#map('winsize', 'n', '', '-', '<C-w>+')
    " TODO: Macro
    " call submode#enter_with('macro/a', 'n', '', '@a', '@a')
    " call submode#map('macro/a', 'n', '', 'a', '@a')
  endfunction

  call s:bundle_untap()
endif " }}}

if s:bundle_tap('open-browser.vim') " {{{

  call s:bundle_config({
        \   'autoload' : {
        \     'commands' : [ 'OpenBrowser', 'OpenBrowserSearch', 'OpenBrowserSmartSearch' ],
        \   }
        \ })

  function! s:tapped_bundle.hooks.on_source(bundle)
  endfunction

  augroup MyAutoCmd
    autocmd FileType J6uil call s:J6uil_settings()
  augroup END

  function! s:J6uil_settings()
    nmap <silent> <buffer> <C-c><C-r>  <Plug>(J6uil_unite_rooms)
    nmap <silent> <buffer> <C-c><C-m>  <Plug>(J6uil_unite_members)
  endfunction

  let g:J6uil_multi_window = 1

  call s:bundle_untap()
endif " }}}

if s:bundle_tap('vim-anzu') " {{{

  call s:bundle_config({})

  function! s:tapped_bundle.hooks.on_source(bundle)
  endfunction

  " Treat folding well
  nnoremap <expr> n anzu#mode#mapexpr('n', '', 'zzzv')
  nnoremap <expr> N anzu#mode#mapexpr('N', '', 'zzzv')

  " Start search with anzu
  nmap * <Plug>(anzu-star-with-echo)
  nmap # <Plug>(anzu-sharp-with-echo)

  " clear status
  " nmap <Esc><Esc> <Plug>(anzu-clear-search-status)

  call s:bundle_untap()
endif " }}}

if s:bundle_tap('vim-automatic') " {{{

  call s:bundle_config({})

  function! s:tapped_bundle.hooks.on_source(bundle)
  endfunction

  nnoremap <silent> <Plug>(quit) :<C-u>q<CR>
  function! s:my_temporary_window_init(config, context)
    nmap <buffer> <C-[>  <Plug>(quit)
    " echo a:config
    " echo a:context
  endfunction

  " let g:automatic_enable_autocmd_Futures = {
  "       \   'BufWinEnterFuture' : 1
  "       \ }
  let g:automatic_default_match_config = {
        \   'is_open_other_window' : 1,
        \ }
  let g:automatic_default_set_config = {
        \   'height' : '60%',
        \   'move' : 'bottom',
        \   'apply' : function('s:my_temporary_window_init')
        \ }
        " \   { 'match' : { 'filetype' : 'unite', 'autocmds' : [ 'BufWinEnterFuture' ] } },
        " \   { 'match' : { 'bufname' : '^.unite' } },
  let g:automatic_config = [
        \   { 'match' : { 'buftype' : 'help' } },
        \   { 'match' : { 'bufname' : '^.vimshell' } },
        \   { 'match' : { 'bufname' : '^.unite' } },
        \   {
        \     'match' : { 'bufname' : '^vimfiler' },
        \     'set' : { 'unsettings' : [ 'resize' ], 'move' : 'left'}
        \   },
        \   {
        \     'match' : {
        \       'filetype' : 'tweetvim_say',
        \       'autocmds' : [ 'FileType' ]
        \     },
        \     'set' : {
        \       'height' : '8'
        \     }
        \   },
        \   {
        \     'match' : {
        \       'filetype' : 'vimconsole',
        \       'autocmds' : [ 'FileType' ]
        \     }
        \   },
        \   {
        \     'match' : {
        \       'filetype' : '\v^ref-.+',
        \       'autocmds' : [ 'FileType' ]
        \     }
        \   },
        \   {
        \     'match' : {
        \       'bufname' : '\[quickrun output\]',
        \     },
        \     'set' : {
        \       'height' : 8,
        \     }
        \   },
        \   {
        \     'match' : {
        \       'autocmds' : [ 'CmdwinEnter' ]
        \     },
        \     'set' : {
        \       'is_close_focus_out' : 1,
        \       'unsettings' : [ 'move', 'resize' ]
        \     },
        \   }
        \ ]
  " let g:automatic_config = [
  "       \   {
  "       \    'set' : {
  "       \    'commands' : ['PP! a:context']
  "       \    },
  "       \   },
  "       \ ]

  call s:bundle_untap()
endif " }}}

if s:bundle_tap('gist-vim') " {{{

  call s:bundle_config({
        \   'autoload' : {
        \     'commands' : ['Gist'],
        \   }
        \ })

  function! s:tapped_bundle.hooks.on_source(bundle)
    " let g:gist_browser_command = 'w3m %URL%'
  endfunction

  let g:gist_open_browser_after_post = 1
  let g:gist_clip_command = 'pbcopy'
  let g:gist_detect_filetype = 1
  let g:gist_show_privates = 1
  let g:gist_post_private = 1

  call s:bundle_untap()
endif " }}}

if s:bundle_tap('vim-prettyprint') " {{{
  call s:bundle_config({
        \   'autoload' : { 'commands' : ['PP'] }
        \ })

  function! s:tapped_bundle.hooks.on_source(bundle)
    
  endfunction

  call s:bundle_untap()
endif " }}}

if s:bundle_tap('vim-quickrun') " {{{
  call s:bundle_config({
        \   'autoload' : {
        \     'mappings' : [ '<Plug>(quickrun)' ],
        \     'commands' : [ 'QuickRun' ],
        \   }
        \ })

  function! s:tapped_bundle.hooks.on_source(bundle)
  endfunction

  let g:quickrun_config = get(g:, 'quickrun_config', {})
  let g:quickrun_config.markdown = {
        \ 'outputter' : 'null',
        \ 'command'   : 'open',
        \ 'cmdopt'    : '-a',
        \ 'args'      : 'Marked',
        \ 'exec'      : '%c %o %a %s',
        \ }
  let g:quickrun_config.matlab = {
        \ 'command'   : 'octave',
        \ 'cmdopt'    : '--silent --persist',
        \ 'hook/cd'   : 1,
        \ 'exec'      : '%c %o %s'
        \ }

  " Prompt sample:
  " octave-3.2.3:2> 
  let g:quickrun_config.matlab = {
        \ 'command'   : 'octave',
        \ 'cmdopt'    : "--silent --persist --eval \"PS1(\\\">> \\\")\"",
        \ 'hook/cd'   : 1,
        \ 'runner'    : 'process_manager',
        \ 'runner/process_manager/load' : '%S:t:r',
        \ 'runner/process_manager/prompt': '>>\s',
        \ }
        " \ 'runner/process_manager/prompt': 'octave-[0-9\.]\+:\d\+>\s',
        " \ 'runner/process_manager/prompt': '>>\s',
        " \ 'cmdopt'    : "--silent --persist --eval \"PS1(''>> '')\"",
        " \ 'runner/process_manager/prompt': 'octave-[0-9\.]\+:\d\+>\s',

  let g:quickrun_config.ruby = {
    \ 'command': 'irb',
    \ 'cmdopt': '--simple-prompt',
    \ 'hook/cd': 1,
    \ 'runner': 'process_manager',
    \ 'runner/process_manager/load': "load %s",
    \ 'runner/process_manager/prompt': '>>\s',
    \ }

  nnoremap <Space>r  :<C-u>QuickRun<CR>

  call s:bundle_untap()
endif " }}}

if s:bundle_tap('vim-textobj-multiblock') " {{{

  function! s:tapped_bundle.hooks.on_source(bundle)
    omap ab <Plug>(textobj-multiblock-a)
    omap ib <Plug>(textobj-multiblock-i)
    vmap ab <Plug>(textobj-multiblock-a)
    vmap ib <Plug>(textobj-multiblock-i)
  endfunction

  call s:bundle_untap()
endif " }}}

if s:bundle_tap('vim-ref') " {{{
  call s:bundle_config({
        \   'autoload' : {
        \     'commands' : [{
        \       'name' : 'Ref',
        \       'complete' : 'customlist,ref#complete'
        \     }],
        \     'unite_sources' : [ 'ref' ]
        \   }
        \ })

  function! s:tapped_bundle.hooks.on_source(bundle)
  endfunction

  let g:ref_open = 'split'
  let g:ref_refe_cmd = '~/.vim/ref/ruby-refm-1.9.3-dynamic-20120829/refe-1_9_3'

  aug MyAutoCmd
    au FileType ruby,eruby,ruby.rspec,haml nnoremap <silent><buffer><Space>d  :<C-u>Unite -no-start-insert ref/refe ref/ri -auto-preview -default-action=below -input=<C-R><C-W><CR>
  aug END

  call s:bundle_untap()
endif " }}}

if s:bundle_tap('vim-ref-ri') " {{{
  call s:bundle_config({
        \   'autoload' : {
        \     'filetypes' : [ 'ruby', 'haml', 'eruby' ],
        \     'unite_sources' : [ 'ref/ri' ]
        \   },
        \ })

  function! s:tapped_bundle.hooks.on_source(bundle)

  endfunction

  call s:bundle_untap()
endif " }}}

if s:bundle_tap('vim-qfreplace') " {{{
  call s:bundle_config({
        \   'autoload' : {
        \     'commands' : [ 'Qfreplace' ]
        \   }
        \ })

  function! s:tapped_bundle.hooks.on_source(bundle)
  endfunction

  call s:bundle_untap()
endif " }}}

if s:bundle_tap('vim-endwise') " {{{
  call s:bundle_config({
        \   'autoload' : {
        \     'filetypes' : [ 'ruby' ]
        \   }
        \ })

  function! s:tapped_bundle.hooks.on_source(bundle)
    " TODO: endwise is not working well. need to implement with smartinput

    " let g:endwise_no_mappings = 1
    " if maparg('<Space>','i') =~# '<C-R>=.*crend(.)<Space>\|<\%(Plug\|SNR\|SID\)>.*End'
    "   " Already mapped
    " elseif maparg('<Space>','i') =~ '<Space>'
    "   exe "imap <script> <C-X><Space> ".maparg('<Space>','i')."<SID>AlwaysEnd"
    "   exe "imap <script> <Space>      ".maparg('<Space>','i')."<SID>DiscretionaryEnd"
    " elseif maparg('<Space>','i') =~ '<Plug>delimitMateCR'
    "   exe "imap <C-X><Space> ".maparg('<Space>', 'i')."<Plug>AlwaysEnd"
    "   exe "imap <Space> ".maparg('<Space>', 'i')."<Plug>DiscretionaryEnd"
    " else
    "   imap <C-X><Space> <Space><Plug>AlwaysEnd
    "   imap <Space>      <Space><Plug>DiscretionaryEnd
    " endif
  endfunction

  call s:bundle_untap()
endif " }}}

if s:bundle_tap('vim-ruby') " {{{
  call s:bundle_config({
        \   'autoload' : {
        \     'mappings' : [ '<Plug>(ref-keyword)' ],
        \     'filetypes' : [ 'ruby', 'haml', 'eruby' ],
        \   }
        \ })

  function! s:tapped_bundle.hooks.on_source(bundle)

  endfunction

  call s:bundle_untap()
endif " }}}

if s:bundle_tap('vim-rails') " {{{
  call s:bundle_config({
        \   'autoload' : {
        \     'filetypes' : [ 'ruby', 'haml', 'eruby' ]
        \   }
        \ })

  function! s:tapped_bundle.hooks.on_source(bundle)
    nnoremap <Space>cm  :<C-u>Rmodel<CR>
    nnoremap <Space>cv  :<C-u>Rview<CR>
    nnoremap <Space>cc  :<C-u>Rcontroller<CR>
    nnoremap <Space>cl  :<C-u>Rlayout<CR>
    nnoremap <Space>ch  :<C-u>Rhelper<CR>
    nnoremap <Space>cj  :<C-u>Rjavascript<CR>
    nnoremap <Space>cs  :<C-u>Rstylesheet<CR>
  endfunction

  call s:bundle_untap()
endif " }}}

if s:bundle_tap('alpaca_tags') " {{{
  call s:bundle_config({
        \   'autoload' : {
        \     'commands' : [ 'AlpacaTagsUpdate', 'AlpacaTagsSet', 'AlpacaTagsBundle' ]
        \   }
        \ })
  function! s:tapped_bundle.hooks.on_source(bundle)
    let g:alpaca_update_tags_config = {
          \   '_' : '-R --sort=yes',
          \   'js' : '--languages=+js',
          \   '-js' : '--languages=-js,JavaScript',
          \   'vim' : '--languages=+Vim,vim',
          \   '-vim' : '--languages=-Vim,vim',
          \   '-style': '--languages=-css,sass,scss,js,JavaScript,html',
          \   'scss' : '--languages=+scss --languages=-css,sass',
          \   'sass' : '--languages=+sass --languages=-css,scss',
          \   'css' : '--languages=+css',
          \   'java' : '--languages=+java $JAVA_HOME/src',
          \   'ruby': '--languages=+Ruby',
          \   'coffee': '--languages=+coffee',
          \   '-coffee': '--languages=-coffee',
          \   'bundle': '--languages=+Ruby --languages=-css,sass,scss,js,JavaScript,coffee',
          \ }

    aug AlpacaUpdateTags
      au!
      au FileWritePost,BufWritePost * AlpacaTagsUpdate -style
      au FileWritePost,BufWritePost Gemfile AlpacaTagsUpdateBundle
      au FileReadPost,BufEnter * AlpacaTagsSet
    aug END
  endfunction
  call s:bundle_untap()
endif " }}}

if s:bundle_tap('unite-rails') " {{{
  call s:bundle_config({
        \   'autoload' : {
        \     'unite_sources' : [
        \       'rails/bundle', 'rails/bundled_gem', 'rails/config',
        \       'rails/controller', 'rails/db', 'rails/destroy', 'rails/features',
        \       'rails/gem', 'rails/gemfile', 'rails/generate', 'rails/git', 'rails/helper',
        \       'rails/heroku', 'rails/initializer', 'rails/javascript', 'rails/lib', 'rails/log',
        \       'rails/mailer', 'rails/model', 'rails/rake', 'rails/route', 'rails/schema', 'rails/spec',
        \       'rails/stylesheet', 'rails/view'
        \     ],
        \     'filetypes' : [ 'ruby', 'haml', 'eruby' ],
        \   }
        \ })

  function! s:my.unite_rails_init()
    let g:UniteRailsAll = reti#lambda(':Unite -start-insert rails/model rails/controller rails/view rails/db rails/config rails/javascript rails/stylesheet rails/helper rails/mailer')
    nnoremap <C-x>r  :<C-u>call g:UniteRailsAll()<CR>
    nnoremap <C-x>m  :<C-u>Unite -start-insert rails/model<CR>
    nnoremap <C-x>c  :<C-u>Unite -start-insert rails/controller<CR>
    nnoremap <C-x>v  :<C-u>Unite -start-insert rails/view<CR>
    nnoremap <C-x>f  :<C-u>Unite -start-insert rails/config<CR>
    nnoremap <C-x>j  :<C-u>Unite -start-insert rails/javascript<CR>
    nnoremap <C-x>s  :<C-u>Unite -start-insert rails/stylesheet<CR>
    nnoremap <C-x>d  :<C-u>Unite -start-insert rails/db<CR>
    nnoremap <C-x>l  :<C-u>Unite -start-insert rails/lib<CR>
    nnoremap <C-x>h  :<C-u>Unite -start-insert rails/helper<CR>
  endfunction

  aug MyAutoCmd
    au User Rails call g:My.unite_rails_init()
  aug END

  function! s:tapped_bundle.hooks.on_source(bundle)
  endfunction

  call s:bundle_untap()
endif " }}}

if s:bundle_tap('vim-airline') " {{{
  function! s:tapped_bundle.hooks.on_source(bundle)
  endfunction

  " let g:airline_left_sep  = '◤ '
  " let g:airline_right_sep = ' ◥'
  let g:airline_left_sep  = ''
  let g:airline_right_sep = ''
  " let g:airline_left_sep  = ''
  " let g:airline_right_sep = ''
  let g:airline_detect_iminsert = 1
  let g:airline_theme = 'dark'

  " Enable fugitive
  let g:airline_enable_branch = 1
  let g:airline_branch_empty_message = ''

  " To show airline status on single window.
  set laststatus=2

  call s:bundle_untap()
endif " }}}

if s:bundle_tap('vim-pronamachang') " {{{
  call s:bundle_config({
        \   'autoload' : {
        \     'unite_sources' : [ 'pronamachang' ],
        \     'commands' : [ 'PronamachangSay' ],
        \   }
        \ })

  function! s:tapped_bundle.hooks.on_source(bundle)
    let g:pronamachang_voice_root = '~/.pronamachang'
  endfunction

  " let g:pronamachang_say_startup_enable = 1
  " let g:pronamachang_say_goodbye_enable = 1

  call s:bundle_untap()
endif " }}}

if s:bundle_tap('vim-sugarpot') " {{{
  call s:bundle_config({
        \   'autoload' : {
        \     'commands' : [ 'SugarpotPreview' ],
        \   }
        \ })

  function! s:tapped_bundle.hooks.on_source(bundle)
    let g:sugarpot_font = 'セプテンバーＭ-等幅:h1'
    let g:sugarpot_xpm_cache_directory = '~/.sugarpot'
    let g:sugarpot_convert = 'convert'
  endfunction

  call s:bundle_untap()
endif " }}}

if s:bundle_tap('w3m.vim') " {{{
  call s:bundle_config({
        \   'autoload' : {
        \     'commands' : [
        \       'W3m',
        \       'W3mTab',
        \       'W3mSplit',
        \       'W3mVSplit',
        \       'W3mClose',
        \       'W3mCopyUrl',
        \       'W3mReload',
        \       'W3mAddressBar',
        \       'W3mShowExternal',
        \       'W3mSyntaxOff',
        \       'W3mSyntaxOn',
        \       'W3mSetUserAgent',
        \       'W3mHistory',
        \       'W3mHistoryClear'
        \     ],
        \   }
        \ })

  function! s:tapped_bundle.hooks.on_source(bundle)
    highlight! link w3mLink      Function
    highlight! link w3mLinkHover SpecialKey
    highlight! link w3mSubmit    Special
    highlight! link w3mInput     String
    highlight! link w3mBold      Comment
    highlight! link w3mUnderline Underlined
    highlight! link w3mHitAHint  Question
    highlight! link w3mAnchor    Label
  endfunction

  let g:w3m#hit_a_hint_key = 'f'
  let g:w3m#lang = 'ja_JP'

  call s:bundle_untap()
endif " }}}

if s:bundle_tap('TweetVim') " {{{
  call s:bundle_config({
        \   'autoload' : {
        \     'commands' : [
        \       'TweetVimVersion',
        \       'TweetVimAddAccount',
        \       'TweetVimSwitchAccount',
        \       'TweetVimHomeTimeline',
        \       'TweetVimMentions',
        \       'TweetVimListStatuses',
        \       'TweetVimUserTimeline',
        \       'TweetVimSay',
        \       'TweetVimUserStream',
        \       'TweetVimCommandSay',
        \       'TweetVimCurrentLineSay',
        \       'TweetVimSearch'
        \     ],
        \     'unite_sources' : [ 'tweetvim/account', 'tweetvim' ],
        \   }
        \ })

  function! s:tapped_bundle.hooks.on_source(bundle)

  endfunction

  function! s:my_tweetvim_mappings()
    nmap <buffer> j  <Plug>(tweetvim_action_cursor_down)
    nmap <buffer> k  <Plug>(tweetvim_action_cursor_up)
    nmap <buffer> f  <Plug>(tweetvim_action_favorite)
    nmap <buffer> m  <Plug>(tweetvim_action_reply)
    nmap <buffer> i  <Plug>(tweetvim_action_in_reply_to)
    nmap <buffer> r  <Plug>(tweetvim_action_retweet)
    nmap <buffer> q  <Plug>(tweetvim_action_qt)
    nmap <buffer> gg  <Plug>(tweetvim_action_reload)
    nmap <buffer> u  <Plug>(tweetvim_action_user_timeline)
    nnoremap <buffer> s  :<C-u>TweetVimSay<CR>
    nmap <buffer> <CR>  <Plug>(tweetvim_action_enter)
    nmap <buffer> <C-h>  <Plug>(tweetvim_action_page_previous)
    nmap <buffer> <C-l>  <Plug>(tweetvim_action_page_next)
    nnoremap <buffer> <Space>cu  :<C-u>Unite tweetvim<CR>
  endfunction
  function! s:my_tweetvim_say_mappings()
    nmap <buffer> <silent> <C-s>       <Plug>(tweetvim_say_show_history)
    imap <buffer> <silent> <C-s>  <ESC><Plug>(tweetvim_say_show_history)
    nmap <buffer> <silent> <CR>        <Plug>(tweetvim_say_post_buffer)
    imap <buffer> <silent> <C-CR> <ESC><Plug>(tweetvim_say_post_buffer)
  endfunction
  autocmd MyAutoCmd FileType tweetvim call s:my_tweetvim_mappings()
  autocmd MyAutoCmd FileType tweetvim_say call s:my_tweetvim_say_mappings()

  let g:tweetvim_display_icon = 1
  let g:tweetvim_display_source = 1
  let g:tweetvim_no_default_key_mappings = 1
  let g:tweetvim_display_username = 1

  call s:bundle_untap()
endif " }}}

if s:bundle_tap('J6uil.vim') " {{{
  call s:bundle_config({
        \   'autoload' : {
        \     'commands' : [ 'J6uil' ],
        \     'unite_sources' : [ 'J6uil/members', 'J6uil/rooms' ],
        \   }
        \ })

  function! s:tapped_bundle.hooks.on_source(bundle)
  endfunction

  let g:J6uil_user     = g:vimrc_secrets['J6uil_user']
  let g:J6uil_password = g:vimrc_secrets['J6uil_password']

  call s:bundle_untap()
endif " }}}

if s:bundle_tap('vimconsole.vim') " {{{
  call s:bundle_config({
        \   'autoload' : {
        \     'commands' : [ 
        \       'VimConsole', 'VimConsoleLog', 'VimConsoleWarn', 'VimConsoleError',
        \       'VimConsoleOpen', 'VimConsoleClose', 'VimConsoleToggle', 'VimConsoleClear',
        \       'VimConsoleRedraw', 'VimConsoleDump'
        \     ]
        \   }
        \ })

  function! s:tapped_bundle.hooks.on_source(bundle)
  endfunction

  let g:vimconsole#auto_redraw = 1

  nnoremap <Space>c  :<C-u>VimConsoleToggle<CR>

  call s:bundle_untap()
endif " }}}

if s:bundle_tap('vital.vim') " {{{
  call s:bundle_config({
        \   'autoload' : {
        \     'commands' : [
        \       'Vitalize'
        \     ]
        \   }
        \ })

  function! s:tapped_bundle.hooks.on_source(bundle)
  endfunction

  call s:bundle_untap()
endif " }}}

if s:bundle_tap('emmet-vim') " {{{
  call s:bundle_config({
        \   'autoload' : {
        \     'filetypes' : [ 'html', 'php', 'erb' ],
        \   }
        \ })

  function! s:tapped_bundle.hooks.on_source(bundle)
  endfunction

  let g:user_emmet_leader_key = '<C-c>'
  let g:user_emmet_settings = {
        \   'lang' : 'ja',
        \   'html' : {
        \     'filters' : 'html',
        \     'indentation' : '  '
        \   },
        \   'css' : {
        \     'filters' : 'fc',
        \   },
        \   'javascript' : {
        \     'snippets' : {
        \       'jq' : "$(function() {\n\t${cursor}${child}\n});",
        \       'jq:each' : "$.each(arr, function(index, item)\n\t${child}\n});",
        \       'fn' : "(function() {\n\t${cursor}\n})();",
        \       'tm' : "setTimeout(function() {\n\t${cursor}\n}, 100);",
        \     },
        \   }
        \ }

  call s:bundle_untap()
endif " }}}

if s:bundle_tap('vim-less') " {{{
  call s:bundle_config({
        \   'autoload' : {
        \     'filetypes' : [ 'less', 'html', 'haml' ],
        \   }
        \ })

  function! s:tapped_bundle.hooks.on_source(bundle)
  endfunction

  call s:bundle_untap()
endif " }}}

if s:bundle_tap('riml.vim') " {{{
  call s:bundle_config({
        \   'autoload' : {
        \     'filetypes' : [ 'riml' ],
        \   }
        \ })

  function! s:tapped_bundle.hooks.on_source(bundle)
  endfunction

  call s:bundle_untap()
endif " }}}

if s:bundle_tap('vim-slim') " {{{
  call s:bundle_config({
        \   'autoload' : {
        \     'filetypes' : [ 'slim' ],
        \   }
        \ })

  function! s:tapped_bundle.hooks.on_source(bundle)
  endfunction

  call s:bundle_untap()
endif " }}}

if s:bundle_tap('vim-coffee-script') " {{{
  call s:bundle_config({
        \   'autoload' : {
        \     'filetypes' : [ 'coffee', 'html', 'haml' ],
        \     'commands' : [ 'CoffeeCompile', 'CoffeeWatch', 'CoffeeRun', 'CoffeeLint' ]
        \   }
        \ })

  function! s:tapped_bundle.hooks.on_source(bundle)
  endfunction

  call s:bundle_untap()
endif " }}}

" }}}

" }}}

