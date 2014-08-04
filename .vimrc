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
"    - Separating global and buffer/file local mapping is very important to use
"      mappings efficiency.
"
" }}}

" NeoBundle  {{{
"
" * Managing
"   - Options for "NeoBundleLazy" should be only "build", "depends", and other
"     options which are only related of installing, building, and updating.
"   - Other options such as "autoload" and plugin's own settings should be
"     set in their each "neobundle#tap()" sections.
"   - Separating plugins' list and their configuration sections is very
"     important.
"
" }}}

" }}}

" Basic  {{{

" Absolute {{{

" Use VIM features instead of vi
" It causes many side effects, so you need to write the top of the ".vimrc".
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

let $MYVIMRC = resolve(expand('~/.vimrc'))

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
        \ a:path : ( expand(a:path) . s:path_separator() . a:current )
endfunction " }}}

function! s:append_path(current, path) "  {{{
  return a:current == '' ?
        \ a:path : ( a:current . s:path_separator() . expand(a:path) )
endfunction " }}}

function! s:dirname(path) "  {{{
  return fnamemodify(a:path, ':h')
endfunction " }}}

function! s:get_list(scope, name) "  {{{
   return get(a:scope, a:name, [])
endfunction " }}}

function! s:add_to_uniq_list(list, element) "  {{{
  return index(a:list, a:element) == -1 ?
        \ add(a:list, a:element) :
        \ a:list
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
    let l:selected = SelectInteractive('Buffer is unsaved. Force quit?', ['n', 'w', 'y'])
    if l:selected == 'w'
      write
      bwipeout
    elseif l:selected == 'y'
      bwipeout!
    endif
  else
    bwipeout
  endif
endfunction " }}}

function! s:colorscheme_exists(name) " {{{
  return index(
        \   map(
        \     split(globpath(&rtp, "colors/*.vim"), "\n"),
        \     'matchstr(v:val, ''.*[\/]\zs.*\ze\.vim'')'
        \   ), a:name
        \ ) != -1
endfunction " }}}

function! s:apply_colorscheme(names) " {{{
  for name in a:names
    if s:colorscheme_exists(name)
      execute 'colorscheme ' . name
      break
    endif
  endfor
endfunction " }}}

function! s:queue_funccall(funcname, ...) " {{{
  let s:queued_funccalls = get(s:, 'queued_funccalls', [])
  call add(s:queued_funccalls, { 'func': function(a:funcname), 'args': a:000 })
endfunction " }}}

function! s:apply_queued_funccalls() " {{{
  if exists('s:queued_funccalls')
    for dict in s:queued_funccalls
      call call(dict.func, dict.args, dict)
    endfor
  endif
  let s:queued_funccalls = []
endfunction " }}}

" }}}

" Environment Variables {{{

let $PATH = s:append_path($PATH, '~/bin')
let $PATH = s:prepend_path($PATH, '/usr/local/bin')
let $PATH = s:append_path($PATH, '/usr/local/wine/bin')
let $PATH = s:append_path($PATH, '/Applications/MacVim.app/Contents/MacOS')
let $PATH = s:append_path($PATH, '/Applications/Octave.app/Contents/Resources/bin')

" Automatic detect current ruby's bin directory.
" Including "gem", "rails", and others.
" let $PATH = s:append_path($PATH, s:dirname(resolve('/usr/local/bin/ruby')))
let $PATH = s:prepend_path($PATH, s:dirname('~/.rbenv/shims/ruby'))
let $PATH = s:append_path($PATH, s:dirname('~/.rbenv/shims/ruby'))
let $RBENV_ROOT = expand('~/.rbenv')

" Gnuterm
let $GNUTERM = 'x11'

" WINE
let $WINE_CDRIVE = expand('~/.wine/drive_c/')

" MetaTrader
let $METALANG = '/usr/local/bin/metalang.exe'

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
let $JAVA_HOME = '/Library/Java/JavaVirtualMachines/jdk1.7.0_45.jdk/Contents/Home'
let $CLASSPATH = s:append_path($CLASSPATH, '.')

" The directory which contains `jfxrt.jar`.
" Note that in JDK8, `jfxrt.jar` is in ext folder
if match($JAVA_HOME, 'jdk1.8') != -1
  let $JFX_DIR = $JAVA_HOME . '/jre/lib/ext/'
else
  let $JFX_DIR = $JAVA_HOME . '/jre/lib/'
endif

if isdirectory('/Users/momonga/.gvm/gradle/current/bin/')
  let $PATH = s:append_path($PATH, '/Users/momonga/.gvm/gradle/current/bin/')
endif

" }}}

" }}}

" Appearance UI  {{{

" Don't load MacVim Kaoriya's gvimrc
let g:macvim_skip_colorscheme = 1

" Don't ring a bell and flash
set vb t_vb=

" Show line number
set number

" Always show tab
set showtabline=2

" Show invisible chars
set list

" When input close bracket, show start bracket
set showmatch

" Fix zenkaku chars' width
set ambiwidth=double

" }}}

" Appearance Font  {{{

" Sample text:
"   あのイーハトーヴォの
"   すきとおった風、
"   夏でも底に冷たさをもつ青いそら、
"   うつくしい森で飾られたモーリオ市、
"   郊外のぎらぎらひかる草の波。
"   祇辻飴葛蛸鯖鰯噌庖箸
"   ABCDEFGHIJKLM
"   abcdefghijklm
"   1234567890
set gfn=SourceCodePro-Light:h15
set gfw=セプテンバーＭ-等幅:h15

" }}}

" Appearance Color theme  {{{

" delay funccall for colorschemes managed by NeoBundle
call s:queue_funccall('s:apply_colorscheme', [ 'railscasts', 'desert'])

" }}}

" Syntax  {{{

syntax enable

" }}}

" Backup  {{{

call s:set('directory', $VIM_SWAP_DIR)
call s:set('backupdir', $VIM_BACKUP_DIR)
call s:set('undodir', $VIM_UNDO_DIR)

if has('persistent_undo')
  set undodir=./.vimundo,$VIM_UNDO_DIR
  au MyAutoCmd BufReadPre ~/* setlocal undofile
endif

" }}}

" History  {{{

" Command history
set history=10000

" }}}

" Restore{{{

" Restore last cursor position when open a file
au MyAutoCmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g`\"" | endif

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
" NOTE: kakkoii unicode moji
" - http://unicode-table.com/en/sections/dingbats/
" - http://unicode-table.com/en/sections/spacing-modifier-letters/
" 		test   
set listchars=tab:❯\ ,trail:˼,extends:»,precedes:«,nbsp:%

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

" Open folding when move in to one
" set foldopen=all

" Close folding when move out of one
" set foldclose=all

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
" set spell spelllang=en_us

" }}}

" TODO: Input Method  {{{

" TODO: Disable Japanese input mode when exit from the insert mode

" }}}

" Basic Key Mapping  {{{

let maplocalleader = ','

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
au MyAutoCmd CmdwinEnter [:>] iunmap <buffer> <Tab>
au MyAutoCmd CmdwinEnter [:>] nunmap <buffer> <Tab>

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

au MyAutoCmd BufRead,BufNewFile *.md  setfiletype markdown

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

" Use git protocol instead of https
let g:neobundle#types#git#default_protocol = 'ssh'

" }}}

" List  {{{
NeoBundle 'Shougo/vimproc.vim', { 'build' : {
      \   'windows' : 'mingw32-make -f make_mingw32.mak',
      \   'cygwin'  : 'make -f make_cygwin.mak',
      \   'mac'     : 'make -f make_mac.mak',
      \   'unix'    : 'make -f make_unix.mak',
      \ }}
" Library used in vimrc
NeoBundle 'vim-jp/vital.vim'

" Text object
NeoBundle 'kana/vim-textobj-user'
NeoBundle 'kana/vim-textobj-entire', { 'depends' : 'kana/vim-textobj-user' }
NeoBundle 'kana/vim-textobj-function', { 'depends' : 'kana/vim-textobj-user' }
NeoBundle 'kana/vim-textobj-indent', { 'depends' : 'kana/vim-textobj-user' }
NeoBundle 'rhysd/vim-textobj-ruby', { 'depends' : 'kana/vim-textobj-user' }
NeoBundle 'osyo-manga/vim-textobj-multiblock', { 'depends' : 'kana/vim-textobj-user' }
NeoBundle 'osyo-manga/vim-textobj-multitextobj', { 'depends' : 'kana/vim-textobj-user' }
NeoBundle 'osyo-manga/vim-textobj-blockwise', { 'depends' : 'kana/vim-textobj-user' }

" Operator
NeoBundle 'kana/vim-operator-user'
NeoBundle 'tyru/operator-html-escape.vim', { 'depends' : 'kana/vim-operator-user' }
NeoBundle 'osyo-manga/vim-operator-blockwise', { 'depends' : 'osyo-manga/vim-textobj-blockwise' }
NeoBundle 'osyo-manga/vim-operator-block', { 'depends' : 'kana/vim-textobj-user' }

NeoBundle 'bling/vim-airline'
NeoBundle 'surround.vim'
NeoBundle 'kana/vim-repeat'
NeoBundle 'kana/vim-submode'
NeoBundle 'osyo-manga/vim-automatic', { 'depends' : [ 'osyo-manga/vim-gift', 'osyo-manga/vim-reunions' ] }
NeoBundle 'osyo-manga/vim-reti', { 'depends' : [ 'osyo-manga/vim-chained' ] }
NeoBundle 'osyo-manga/vim-anzu'
NeoBundle 'jceb/vim-hier'
NeoBundle 'LeafCage/foldCC'
NeoBundle 'vim-jp/vimdoc-ja'
NeoBundle 'tpope/vim-fugitive'
NeoBundle 'gregsexton/gitv', { 'depends' : [ 'tpope/vim-fugitive' ] }
NeoBundle 'tomtom/tcomment_vim'
NeoBundle 'tpope/vim-rbenv'
NeoBundle 'thinca/vim-scall'
NeoBundle 'thinca/vim-singleton'
NeoBundleLazy 'mattn/sonictemplate-vim'
NeoBundleLazy 'Shougo/unite.vim', { 'depends' : [ 'Shougo/vimproc.vim' ] }
NeoBundle 'Shougo/neomru.vim', { 'depends' : [ 'Shougo/unite.vim' ] }
NeoBundleLazy 'Shougo/vimshell.vim', { 'depends' : [ 'Shougo/vimproc.vim' ] }
NeoBundleLazy 'ujihisa/vimshell-ssh', { 'depends' : [ 'Shougo/vimshell.vim' ] }
NeoBundleLazy 'Shougo/vimfiler.vim', { 'depends' : [ 'Shougo/unite.vim' ] }
NeoBundleLazy 'Shougo/unite-ssh', { 'depends' : [ 'Shougo/unite.vim' ] }
NeoBundleLazy 'Shougo/neosnippet.vim'
NeoBundle 'Shougo/neosnippet-snippets', { 'depends' : [ 'Shougo/neosnippet.vim' ] }
NeoBundle 'honza/vim-snippets'
NeoBundle 'carlosgaldino/elixir-snippets'
NeoBundle 'matthewsimo/angular-vim-snippets'
NeoBundleLazy 'Shougo/neocomplete.vim'
NeoBundleLazy 'rhysd/unite-ruby-require.vim', { 'depends' : [ 'Shougo/unite.vim' ] }
NeoBundleLazy 'Shougo/unite-help', { 'depends' : [ 'Shougo/unite.vim' ] }
NeoBundleLazy 'Shougo/unite-outline', { 'depends' : [ 'Shougo/unite.vim' ] }
NeoBundleLazy 'supermomonga/unite-goimport.vim', { 'depends' : [ 'Shougo/unite.vim', 'fatih/vim-go' ] }
NeoBundleLazy 'ujihisa/unite-colorscheme', { 'depends' : [ 'Shougo/unite.vim' ] }
NeoBundleLazy 'ujihisa/unite-locate', { 'depends' : [ 'Shougo/unite.vim' ] }
NeoBundleLazy 'osyo-manga/unite-quickfix', { 'depends' : [ 'Shougo/unite.vim' ] }
NeoBundleLazy 'osyo-manga/vim-pronamachang', { 'depends' : [ 'osyo-manga/vim-sound', 'Shougo/vimproc.vim' ] }
NeoBundleLazy 'osyo-manga/vim-sugarpot', { 'depends' : [ 'Shougo/vimproc.vim' ] }
NeoBundleLazy 'osyo-manga/vim-watchdogs', { 'depends' : [
      \   'thinca/vim-quickrun',
      \   'Shougo/vimproc.vim',
      \   'osyo-manga/shabadou.vim',
      \   'jceb/vim-hier',
      \   'dannyob/quickfixstatus'
      \ ] }
NeoBundleLazy 'h1mesuke/vim-alignta'
NeoBundleLazy 'kana/vim-smartinput'
NeoBundleLazy 'cohama/vim-smartinput-endwise', { 'depends' : [ 'kana/vim-smartinput' ] }
NeoBundleLazy 'mattn/gist-vim', { 'depends' : [ 'mattn/webapi-vim' ] }
NeoBundleLazy 'mattn/emmet-vim'
NeoBundleLazy 'thinca/vim-prettyprint'
NeoBundleLazy 'thinca/vim-quickrun'
" NeoBundleLazy 'osyo-manga/quickrun-hook-u-nya-', { 'depends' : [ 'thinca/vim-quickrun' ] }
NeoBundleLazy 'thinca/vim-ref'
NeoBundleLazy 'thinca/vim-qfreplace'
NeoBundleLazy 'thinca/vim-editvar'
NeoBundleLazy 'tyru/open-browser.vim'
NeoBundleLazy 'yuratomo/w3m.vim'
NeoBundleLazy 'rbtnn/vimconsole.vim'
NeoBundleLazy 'groenewege/vim-less'
NeoBundleLazy 'slim-template/vim-slim'
NeoBundleLazy 'kchmck/vim-coffee-script'
NeoBundleLazy 'luke-gru/riml'
NeoBundleLazy 'luke-gru/vim-riml'
NeoBundleLazy 'LeafCage/vimhelpgenerator'
NeoBundleLazy 'deris/vim-rengbang'
NeoBundleLazy 'mattn/emoji-vim'

NeoBundleLazy 'LeafCage/nebula.vim'

" Colorscheme
NeoBundle 'tomasr/molokai'
NeoBundle 'w0ng/vim-hybrid'
NeoBundle 'altercation/vim-colors-solarized'
NeoBundle 'nanotech/jellybeans.vim'
NeoBundle 'chriskempson/tomorrow-theme'
NeoBundle 'twilight'
NeoBundle 'zazen'
NeoBundle 'jonathanfilip/vim-lucius'
NeoBundle 'jpo/vim-railscasts-theme'
" NeoBundle 'thinca/vim-splash'

" momonga's Kanari Sugoi Plugins (Kanari)
NeoBundleLazy 'supermomonga/shaberu.vim', { 'depends' : [ 'Shougo/vimproc.vim' ] }
NeoBundleLazy 'supermomonga/vimshell-pure.vim', { 'depends' : [ 'Shougo/vimshell.vim' ] }
NeoBundleLazy 'supermomonga/vimshell-inline-history.vim', { 'depends' : [ 'Shougo/vimshell.vim' ] }
NeoBundleLazy 'supermomonga/vimshell-wakeup.vim', { 'depends' : [ 'Shougo/vimshell.vim' ] }
NeoBundle 'supermomonga/projectlocal.vim'
NeoBundle 'supermomonga/thingspast.vim'

" Communication
NeoBundleLazy 'tsukkee/lingr-vim'
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

" Programming
NeoBundleLazy 'kien/rainbow_parentheses.vim'

" Vim script
NeoBundleLazy 'mopp/layoutplugin.vim'

" Ruby
NeoBundleLazy 'vim-ruby/vim-ruby'
NeoBundleLazy 'taka84u9/vim-ref-ri', { 'depends' : [ 'Shougo/unite.vim', 'thinca/vim-ref' ] }
NeoBundle 'tpope/vim-rails'
NeoBundleLazy 'basyura/unite-rails', { 'depends' : [ 'Shougo/unite.vim' ] }
NeoBundleLazy 't9md/vim-ruby-xmpfilter'
NeoBundleLazy 'osyo-manga/vim-monster'

" Elixir
NeoBundleLazy 'elixir-lang/vim-elixir'

" golang
NeoBundle 'vim-jp/go-vim'
" NeoBundle 'fatih/vim-go', { 'depends' : [ 'Shougo/neosnippet.vim' ] }
" NeoBundleLazy 'jnwhiteh/vim-golang'
" NeoBundleLazy 'Blackrush/vim-gocode'

" Clang
NeoBundleLazy 'osyo-manga/vim-snowdrop'

" Clojure
NeoBundleLazy 'emanon001/fclojure.vim'
NeoBundleLazy 'thinca/vim-ft-clojure'
NeoBundleLazy 'ujihisa/neoclojure.vim'

" Java
NeoBundleLazy 'Shougo/javacomplete', {
      \   'build': {
      \     'cygwin': 'javac autoload/Reflection.java',
      \     'mac': 'javac autoload/Reflection.java',
      \     'unix': 'javac autoload/Reflection.java'
      \   },
      \ }
NeoBundleLazy 'KamunagiChiduru/unite-javaimport', { 'depends' : [
      \   'Shougo/unite.vim',
      \   'yuratomo/w3m.vim',
      \   'KamunagiChiduru/vim-javaclasspath',
      \   'KamunagiChiduru/vim-javalang',
      \ ] }

" MetaQuartsLanguage
NeoBundle 'vobornik/vim-mql4'

" TODO: Windows build command to get .ctags
NeoBundleLazy 'alpaca-tc/alpaca_tags', {
      \   'depends' : [ 'Shougo/vimproc.vim' ],
      \   'build' : {
      \     'mac' : 'wget https://raw.github.com/alpaca-tc/alpaca_tags/master/.ctags -O ~/.ctags',
      \     'unix' : 'wget https://raw.github.com/alpaca-tc/alpaca_tags/master/.ctags -O ~/.ctags',
      \   }
      \ }

" Library and Frameworks to create Vim Plugins
NeoBundleLazy 'rbtnn/rabbit-ui.vim'

" Games
NeoBundleLazy 'rbtnn/puyo.vim'
NeoBundleLazy 'rbtnn/mario.vim'
NeoBundleLazy 'thinca/vim-threes'
NeoBundleLazy 'mattn/flappyvird-vim'

" Musics
NeoBundleLazy 'supermomonga/jazzradio.vim', { 'depends' : [ 'Shougo/unite.vim' ] }


" Temporary
NeoBundle 'osyo-manga/vital-reunions'


" TODO: atode settei simasu...
" NeoBundleLazy 'tpope/vim-markdown'


" Disable some local bundles
NeoBundleDisable vimshell-kawaii.vim
NeoBundleDisable vimshell-scopedalias.vim
NeoBundleDisable unite-vacount2012.vim
NeoBundleDisable vimshell-suggest.vim


" Required to use
filetype plugin indent on

" }}}

" Plugin Configurations  {{{

if neobundle#tap('vital.vim') " {{{

  function! neobundle#tapped.hooks.on_source(bundle)
    let g:V = vital#of('vital')
    let g:S = g:V.import("Web.HTTP")
    let g:L = g:V.import("Data.List")

    function! DecodeURI(uri)
      return g:S.decodeURI(a:uri)
    endfunction

    function! EncodeURI(uri)
      return g:S.encodeURI(a:uri)
    endfunction

    command -nargs=1 DecodeURI echo DecodeURI(<args>)
    command -nargs=1 EncodeURI echo EncodeURI(<args>)

  endfunction

endif " }}}

if neobundle#tap('riml.vim') " {{{

  call neobundle#config({
        \   'autoload' : {
        \     'filetypes' : [ 'riml' ],
        \   }
        \ })

endif " }}}

if neobundle#tap('vim-riml.vim') " {{{

  call neobundle#config({
        \   'autoload' : {
        \     'filetypes' : [ 'riml' ],
        \   }
        \ })

endif " }}}

if neobundle#tap('unite.vim') " {{{

  call neobundle#config({
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

  " Use The Silver Searcher for grep
  if executable('the_platinum_searcher')
    let g:unite_source_grep_command = 'the_platinum_searcher'
    let g:unite_source_grep_default_opts = '--nogroup --nocolor'
    let g:unite_source_grep_recursive_opt = ''
    let g:unite_source_grep_encoding = 'utf-8'
  elseif executable('ag')
    let g:unite_source_grep_command = 'ag'
    let g:unite_source_grep_default_opts = '--nogroup --nocolor --column'
    let g:unite_source_grep_recursive_opt = ''
  endif

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

  function! neobundle#tapped.hooks.on_source(bundle)

    " General
    let g:unite_force_overwrite_statusline = 0
    let g:unite_kind_jump_list_after_jump_scroll=0
    let g:unite_enable_start_insert = 0
    let g:unite_source_rec_min_cache_files = 1000
    let g:unite_source_rec_max_cache_files = 5000
    let g:unite_source_file_mru_long_limit = 100000
    let g:unite_source_file_mru_limit = 100000
    let g:unite_source_directory_mru_long_limit = 100000
    let g:unite_prompt = '❯ '

    " Use buffer name instead of file path for buffer / buffer_tab source
    let s:filter = { 'name' : 'converter_buffer_word' }

    function! s:filter.filter(candidates, context)
      for candidate in a:candidates
        " if !filereadable(candidate.word)
        "   let candidate.word = bufname(candidate.action__buffer_nr)
        " endif
        let candidate.word = bufname(candidate.action__buffer_nr)
        if candidate.word == ''
          let candidate.word = 'No Name'
        end
      endfor
      return a:candidates
    endfunction

    call unite#define_filter(s:filter)
    unlet s:filter
    call unite#custom_source('buffer', 'converters', 'converter_buffer_word')
    call unite#custom_source('buffer_tab', 'converters', 'converter_buffer_word')

    " Unite-menu
    let g:unite_source_menu_menus = get(g:, 'unite_source_menu_menus', {})
    let g:unite_source_menu_menus.global = { 'description' : 'global shortcut' }
    let g:unite_source_menu_menus.unite = { 'description' : 'unite shortcut' }
    let g:unite_source_menu_menus.global.map = function('s:unite_menu_map_func')
    let g:unite_source_menu_menus.unite.map = function('s:unite_menu_map_func')
    let g:unite_source_menu_menus.global.candidates = [
          \   [ '[edit] vimrc' , $MYVIMRC ],
          \   [ '[edit] secret_vimrc' , expand('~/.secret_vimrc') ],
          \   [ '[terminal] VimShell' , ':VimShell' ],
          \   [ '[twitter] TweetVim' , ':Unite tweetvim' ],
          \   [ '[lingr] J6uil' , ':J6uil' ],
          \   [ '[music] Play JAZZRADIO.com' , ':Unite jazzradio -update-time=75 -buffer-name=unite_jazzradio' ],
          \   [ '[music] Stop JAZZRADIO.com' , ':JazzradioStop' ],
          \   [ '[shaberu] toggle' , ':ShaberuMuteToggle' ],
          \   [ '[shaberu] mute on' , ':ShaberuMuteOn' ],
          \   [ '[shaberu] mute off' , ':ShaberuMuteOff' ],
          \ ]
          " \   [ '[music] Play JAZZRADIO.com' , ':Unite jazzradio -update-time=75 -no-quit -keep-focus -buffer-name=unite_jazzradio' ],
    " let g:unite_source_menu_menus.shaberu.candidates = [
    "       \   [ '' , ':VimShell' ],
    "       \ ]
          " \   [ '[music] Play JAZZRADIO.com' , ':Unite jazzradio -update-time=75 -buffer-name=unite_jazzradio' ],
    let g:unite_source_menu_menus.unite.candidates = []
    let g:unite_source_menu_filetype_candidates = {}
    let g:unite_source_menu_filetype_candidates._ = [
          \   [ 'neobundle/update' , ':Unite neobundle/update -log' ],
          \   [ 'neobundle/install' , ':Unite neobundle/install -log' ],
          \   [ 'J6uil/rooms' , ':Unite J6uil/rooms' ],
          \   [ 'J6uil/members' , ':Unite J6uil/members' ],
          \   [ 'Blog/posts' , ':Unite file:~/Sites/blog.supermomonga.com/source/posts/' ],
          \   [ 'TweetVim' , ':Unite tweetvim' ],
          \   [ 'files', ':Unite -start-insert -buffer-name=files buffer_tab file file_mru'],
          \   [ 'function', ':Unite -start-insert -default-action=edit function'],
          \   [ 'variable', ':Unite -start-insert -default-action=edit variable'],
          \   [ 'outline', ':Unite -start-insert outline'],
          \   [ 'help', ':Unite -start-insert help'],
          \   [ 'buffer', ':Unite -start-insert buffer'],
          \   [ 'line', ':Unite -start-insert -auto-preview -buffer-name=search line'],
          \   [ 'quickfix', ':Unite -no-split -no-quit -auto-preview quickfix -buffer-name=unite_qf'],
          \   [ 'grep', ':Unite grep -max-multi-lines=1 -truncate -default-action=tabopen -buffer-name=unite_grep'],
          \   [ 'source', ':Unite -start-insert source'],
          \   [ 'locate', ':Unite -start-insert locate'],
          \   [ 'theme', ':Unite -auto-preview colorscheme'],
          \   [ 'resume grep', ':UniteResume unite_grep'],
          \   [ 'resume quickfix', ':UniteResume unite_qf'],
          \ ]
    let g:unite_source_menu_filetype_candidates.go = [
          \   [ 'golang/import', ':Unite goimport -start-insert' ],
          \ ]


  endfunction

  nnoremap <silent> <Space>u  :<C-u>call Unite_filetype_menu('-start-insert')<CR>
  function! Unite_filetype_menu(options)
    let filetypes = split(&ft, '\.')
    let candidate_sets = map(
          \   add(filter(filetypes, 'has_key(g:unite_source_menu_filetype_candidates, v:val)'), '_'),
          \   'g:unite_source_menu_filetype_candidates[v:val]'
          \ )
    let candidates = g:L.flatten(candidate_sets, 1)
    let g:unite_source_menu_menus.unite.candidates = candidates
    execute ':Unite menu:unite ' . a:options
  endfunction
  nnoremap <silent> <Space>m  :<C-u>Unite -start-insert menu:global<CR>
  nnoremap <silent> <Space>f  :<C-u>Unite -start-insert -buffer-name=files buffer_tab file_mru<CR>
  nnoremap <silent> <Space>b  :<C-u>Unite -start-insert buffer<CR>
  nnoremap <silent> <Space>s  :<C-u>Unite -start-insert -auto-preview -no-split -buffer-name=search line<CR>
  nnoremap <silent> <Space>l  :<C-u>Unite -start-insert locate<CR>
  nnoremap <silent> <Space>g  :<C-u>Unite grep -max-multi-lines=1 -truncate -default-action=tabopen -buffer-name=unite_grep<CR>
  " This <Space>j mapping is to define default behavior. Should be changed by
  " buffer local setting.
  nnoremap <silent> <Space>j  :<C-u>Unite -start-insert -buffer-name=files buffer_tab file_mru<CR>

  nnoremap <silent> <Space>p  :<C-u>call Unite_project_files('-start-insert')<CR>
  function! Unite_project_files(options)
    if exists('b:projectlocal_root_dir')
      execute ':Unite file_rec/async:' . b:projectlocal_root_dir . ' ' . a:options
    else
      echo "You are not in any project."
    endif
  endfunction

  " TODO: Should those mappings be moved to their own setting section?
  " That seems correct but it provides better look of the Unite-source
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

endif " }}}

if neobundle#tap('sonictemplate-vim') " {{{

  call neobundle#config({
        \ 'autoload' : {
        \   'commands' : [
        \     { 'name' : 'Template', 'complete' : 'customlist,sonictemplate#complete' },
        \   ],
        \   'function_prefix' : 'sonictemplate'
        \ }
        \ })

  let g:sonictemplate_vim_template_dir = $VIM_DOTVIM_DIR . '/templates/'

endif " }}}

if neobundle#tap('vimfiler.vim') " {{{

  call neobundle#config({
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

  let g:vimfiler_safe_mode_by_default = 0
  let g:unite_kind_file_use_trashbox = 1
  let g:vimfiler_as_default_explorer = 1
  let g:vimfiler_as_default_explorer = 1

  nnoremap <Space>e  :<C-u>VimFilerExplorer -winwidth=65<CR>

endif " }}}

if neobundle#tap('unite-javaimport') " {{{

  call neobundle#config({
        \   'autoload' : {
        \     'unite_sources' : [
        \       'javaimport',
        \     ],
        \     'commands' : [
        \       'JavaImportClearCache',
        \       'JavaImportSortStatements',
        \       'JavaImportRemoveUnnecessaries',
        \     ]
        \   }
        \ })

endif " }}}

if neobundle#tap('unite-quickfix') " {{{

  call neobundle#config({
        \   'autoload' : {
        \     'unite_sources' : [
        \       'quickfix',
        \     ],
        \   }
        \ })

endif " }}}

if neobundle#tap('unite-goimport.vim') " {{{

  call neobundle#config({
        \   'autoload' : {
        \     'unite_sources' : [
        \       'goimport',
        \     ],
        \   }
        \ })

endif " }}}

if neobundle#tap('unite-outline') " {{{

  call neobundle#config({
        \   'autoload' : {
        \     'unite_sources' : [
        \       'outline',
        \     ],
        \   }
        \ })

endif " }}}

if neobundle#tap('unite-help') " {{{

  call neobundle#config({
        \   'autoload' : {
        \     'unite_sources' : [
        \       'help',
        \     ],
        \   }
        \ })

endif " }}}

if neobundle#tap('unite-ssh') " {{{

  call neobundle#config({
        \   'autoload' : {
        \     'unite_sources' : [
        \       'ssh',
        \     ],
        \   }
        \ })

endif " }}}

if neobundle#tap('unite-colorscheme') " {{{

  call neobundle#config({
        \   'autoload' : {
        \     'unite_sources' : [
        \       'colorscheme',
        \     ],
        \   }
        \ })

endif " }}}

if neobundle#tap('unite-locate') " {{{

  call neobundle#config({
        \   'autoload' : {
        \     'unite_sources' : [
        \       'locate',
        \     ],
        \   }
        \ })

endif " }}}

if neobundle#tap('shaberu.vim') " {{{

  call neobundle#config({
        \   'autoload' : {
        \     'commands' : [ 'ShaberuSay', 'ShaberuMuteOn', 'ShaberuMuteOff', 'ShaberuMuteToggle' ]
        \   }
        \ })

  let g:shaberu_user_define_say_command = 'say-openjtalk "%%TEXT%%"'
  " let g:shaberu_user_define_say_command = 'say -v Kyoko "%%TEXT%%"'

  " Vim core
  au MyAutoCmd VimEnter * ShaberuSay '進捗どうですか'
  au MyAutoCmd VimLeave * ShaberuSay '再起動フラグ'

  " VimShell
  au MyAutoCmd FileType vimshell
        \ call vimshell#hook#add('chpwd' , 'my_vimshell_chpwd' , reti#lambda(":ShaberuSay 'よっこいしょ'"))
        \| call vimshell#hook#add('emptycmd', 'my_vimshell_emptycmd', reti#lambda(":call shaberu#say('コマンドを入力してください') | return a:1"))
        \| call vimshell#hook#add('notfound', 'my_vimshell_notfound', reti#lambda(":call shaberu#say('コマンドが見つかりません') | return a:1"))

  " .vimrc保存時に自動的にsource
  au MyAutoCmd BufWritePost .vimrc nested source $MYVIMRC | ShaberuSay 'ビムアールシーを読み込みました'
  " 開発用ディレクトリ内.vimファイルに関して、ファイル保存時に自動でsourceする
  execute 'au MyAutoCmd BufWritePost,FileWritePost' $VIM_LOCAL_BUNDLE_DIR . '*.vim' 'source <afile> | echo "sourced : " . bufname("%") | ShaberuSay "ソースしました"'

endif " }}}

if neobundle#tap('vimshell.vim') " {{{

  call neobundle#config({
        \   'autoload' : {
        \     'commands' : [ 'VimShell', 'VimShellPop' ]
        \   }
        \ })

  function! neobundle#tapped.hooks.on_source(bundle)
    " let g:unite_source_vimshell_external_history_path = expand('~/.zsh_history')
  endfunction

  nnoremap <C-x><C-v>  :<C-u>VimShellPop -toggle<CR>
  inoremap <C-x><C-v>  :<C-u>VimShellPop -toggle<CR>
  nnoremap <Space>vp  :<C-u>VimShellPop -toggle<CR>
  nnoremap <Space>vb  :<C-u>VimShellBufferDir<CR>
  nnoremap <Space>vd  :<C-u>VimShellCurrentDir<CR>
  nnoremap <Space>vv  :<C-u>VimShell<CR>

  " buffer local mapping
  function! s:my_vimshell_mappings()
    imap <buffer> <C-e>  <ESC>$a
    imap <buffer> <C-d>  <ESC><Right>xi
    imap <buffer> <C-/>  <ESC>dT/xa
    imap <buffer> <C-.>  <ESC>dT.xa
    imap <buffer> <C-_>  <ESC>dT_xa
  endfunction
  au MyAutoCmd FileType vimshell call s:my_vimshell_mappings()

  function! s:my_vimshell_aliases()
    call vimshell#set_alias('edit', 'vim --split=tabedit $$args')
    call vimshell#set_alias('e', 'edit')
    call vimshell#set_alias('reload', 'vimsh ~/.vimshrc')
    call vimshell#set_alias('rl', 'reload')
    call vimshell#set_alias('quicklook', 'qlmanage -p $$args')
    call vimshell#set_alias('l', 'quicklook')
    call vimshell#set_alias('ls', 'ls -a ')
    call vimshell#set_alias('lsl', 'ls -la ')
    call vimshell#set_alias('cl', 'clear')
    call vimshell#set_alias('op', 'open .')
    call vimshell#set_alias('be', 'bundle exec')
    call vimshell#set_alias('j', ':Unite -buffer-name=files
          \ -default-action=lcd -no-split -input=$$args directory_mru')
    " Shaberu
    call vimshell#set_alias('hello', ':call shaberu#say("こんにちは")')
    call vimshell#set_alias('kawaii', ':call shaberu#say("ありがとうございます")')
    call vimshell#set_alias('nemui', ':call shaberu#say("そろそろ寝ましょう")')
    call vimshell#set_alias('work', ':call shaberu#say("進捗どうですか")')
    call vimshell#set_alias('time?', ':call shaberu#say(strftime("はいっ。今は%H時%M分です"))')
    call vimshell#set_alias('kora', ':call shaberu#say("ごめんなさい")')
    call vimshell#set_alias('sl', ':call shaberu#say("きしゃぽっぽ。きしゃぽっぽ。ぽぽ")')
  endfunction
  au MyAutoCmd FileType vimshell call s:my_vimshell_aliases()

  " Run VimShell when launch Vim
  " au MyAutoCmd VimEnter * VimShell

endif " }}}

if neobundle#tap('vimshell-pure.vim') " {{{

  call neobundle#config({
        \   'autoload' : {
        \     'on_source' : [ 'vimshell.vim' ]
        \   }
        \ })

endif " }}}

if neobundle#tap('vimshell-inline-history.vim') " {{{

  call neobundle#config({
        \   'autoload' : {
        \     'on_source' : [ 'vimshell.vim' ]
        \   }
        \ })

endif " }}}

if neobundle#tap('vimshell-wakeup.vim') " {{{

  call neobundle#config({
        \   'autoload' : {
        \     'on_source' : [ 'vimshell.vim' ]
        \   }
        \ })

  function! neobundle#tapped.hooks.on_source(bundle)
    let g:vimshell_wakeup_shaberu_text = 'おわだよ'
  endfunction

endif " }}}

if neobundle#tap('projectlocal.vim') " {{{

  " See unite.vim's setting section.

endif " }}}

if neobundle#tap('vim-textobj-multiblock') " {{{

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
  let g:textobj_multiblock_search_limit = 20

        " Couldn't use multiple chars
        " \   ['if', 'elsif'],
        " \   ['if', 'else'],
        " \   ['if', 'end'],
        " \   ['elsif', 'end'],
        " \   ['elsif', 'elsif'],
        " \   ['elsif', 'else'],
        " \   ['else', 'end'],
        " \   ['do', 'end'],

endif " }}}

if neobundle#tap('vim-textobj-blockwise') " {{{

  vmap <expr> iw mode() == "\<C-v>" ? textobj#blockwise#mapexpr('iw') : 'iw'

endif " }}}

if neobundle#tap('vim-operator-blockwise') " {{{

  nmap YY <Plug>(operator-blockwise-yank)
  nmap DD <Plug>(operator-blockwise-delete)
  nmap CC <Plug>(operator-blockwise-change)
  nmap <expr> SS operator#blockwise#mapexpr("\<Plug>(operator-replace)")

endif " }}}

if neobundle#tap('vim-operator-block') " {{{

  nmap sy <Plug>(operator-block-yank)
  nmap sp <Plug>(operator-block-paste)
  nmap sd <Plug>(operator-block-delete)

endif " }}}

if neobundle#tap('neocomplete.vim') " {{{

  call neobundle#config({
        \   'autoload' : {
        \     'insert' : 1,
        \   }
        \ })

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
  let g:neocomplete_auto_completion_start_length = 3

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
  " let g:neocomplete#force_omni_input_patterns.ruby = '[^. *\t]\.\w*\|\h\w*::'
  " let g:neocomplete#force_omni_input_patterns.go = '\h\w*\.\?'

  let g:neocomplete#sources#omni#input_patterns = get(g:, 'neocomplete#sources#omni#input_patterns', {})
  let g:neocomplete#sources#omni#input_patterns.go = '\h\w\.\w*'
  let g:neocomplete#force_omni_input_patterns.ruby = '[^. *\t]\.\w*\|\h\w*::'
  " let g:neocomplete#sources#omni#input_patterns.go = ''

  " Omni completion functions
  let g:neocomplete#sources#omni#functions = get(g:, 'neocomplete#sources#omni#functions', {})
  let g:neocomplete#sources#omni#functions.ruby = 'rubycomplete#Complete'
  " let g:neocomplete#sources#omni#functions.go = 'go#complete#Complete'

endif " }}}

if neobundle#tap('neosnippet.vim') " {{{

  call neobundle#config({
        \   'autoload' : {
        \     'insert' : 1,
        \     'filetype' : 'snippet',
        \     'commands' : [ 'NeoSnippetEdit', 'NeoSnippetSource' ],
        \     'filetypes' : [ 'nsnippet' ],
        \     'unite_sources' :
        \       ['snippet', 'neosnippet/user', 'neosnippet/runtime']
        \   }
        \ })

  let g:neosnippet#enable_snipmate_compatibility = 1
  " My original snippets
  let g:neosnippet_snippets_directories = s:add_to_uniq_list(
        \   s:get_list(g:, 'neosnippet_snippets_directories'),
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

endif " }}}

if neobundle#tap('neosnippet-snippets') " {{{

  call neobundle#config({
        \   'autoload' : {
        \   }
        \ })

endif " }}}

if neobundle#tap('vim-snippets') " {{{

  let g:neosnippet_snippets_directories = s:add_to_uniq_list(
        \   s:get_list(g:, 'neosnippet_snippets_directories'),
        \   $VIM_REMOTE_BUNDLE_DIR . '/vim-snippets/snippets'
        \ )
  let g:neosnippet#snippets_directory = join(g:neosnippet_snippets_directories, ',')

endif " }}}

if neobundle#tap('elixir-snippets') " {{{

  let g:neosnippet_snippets_directories = s:add_to_uniq_list(
        \   s:get_list(g:, 'neosnippet_snippets_directories'),
        \   $VIM_REMOTE_BUNDLE_DIR . '/elixir-snippets/snippets'
        \ )
  let g:neosnippet#snippets_directory = join(g:neosnippet_snippets_directories, ',')

endif " }}}

if neobundle#tap('angular-vim-snippets') " {{{

  let g:neosnippet_snippets_directories = s:add_to_uniq_list(
        \   s:get_list(g:, 'neosnippet_snippets_directories'),
        \   $VIM_REMOTE_BUNDLE_DIR . '/angular-vim-snippets/snippets'
        \ )
  let g:neosnippet#snippets_directory = join(g:neosnippet_snippets_directories, ',')

endif " }}}

if neobundle#tap('vim-alignta') " {{{

  call neobundle#config({
        \   'autoload' : {
        \     'commands' : ['Alignta'],
        \   }
        \ })

endif " }}}

if neobundle#tap('foldCC') " {{{

  set foldmethod=marker
  set foldtext=FoldCCtext()
  set foldcolumn=0
  set fillchars=vert:\|

endif " }}}

if neobundle#tap('tcomment_vim') " {{{
endif " }}}

if neobundle#tap('vim-smartinput') " {{{

  call neobundle#config({
        \   'autoload' : {
        \     'insert' : 1
        \   }
        \ })

  function! neobundle#tapped.hooks.on_source(bundle)
    call smartinput#clear_rules()
    call smartinput#define_default_rules()
  endfunction

  function! neobundle#tapped.hooks.on_post_source(bundle)
    call smartinput_endwise#define_default_rules()
  endfunction

endif " }}}

if neobundle#tap('vim-smartinput-endwise') " {{{

  function! neobundle#tapped.hooks.on_post_source(bundle)
    " neosnippet and neocomplete compatible
    call smartinput#map_to_trigger('i', '<Plug>(my_cr)', '<Enter>', '<Enter>')
    imap <expr><CR> !pumvisible() ? "\<Plug>(my_cr)" :
          \ neosnippet#expandable() ? "\<Plug>(neosnippet_expand)" :
          \ neocomplete#close_popup()
  endfunction

endif " }}}

if neobundle#tap('vim-submode') " {{{

  function! neobundle#tapped.hooks.on_source(bundle)
    let g:submode_keep_leaving_key = 1
    " tab moving
    call submode#enter_with('changetab', 'n', '', 'gt', 'gt')
    call submode#enter_with('changetab', 'n', '', 'gT', 'gT')
    call submode#map('changetab', 'n', '', 't', 'gt')
    call submode#map('changetab', 'n', '', 'T', 'gT')
    " undo/redo
    call submode#enter_with('undo/redo', 'n', '', '<C-r>', '<C-r>')
    call submode#enter_with('undo/redo', 'n', '', 'u', 'u')
    call submode#map('undo/redo', 'n', '', '<C-r>', '<C-r>')
    call submode#map('undo/redo', 'n', '', 'u', 'u')
    " move between fold
    call submode#enter_with('movefold', 'n', '', 'zj', 'zjzMzvzz')
    call submode#enter_with('movefold', 'n', '', 'zk', 'zkzMzv[zzz')
    call submode#map('movefold', 'n', '', 'j', 'zjzMzvzz')
    call submode#map('movefold', 'n', '', 'k', 'zkzMzv[zzz')
    " resize window
    call submode#enter_with('winsize', 'n', '', '<C-w>>', '<C-w>>')
    call submode#enter_with('winsize', 'n', '', '<C-w><', '<C-w><')
    call submode#enter_with('winsize', 'n', '', '<C-w>+', '<C-w>+')
    call submode#enter_with('winsize', 'n', '', '<C-w>-', '<C-w>-')
    call submode#map('winsize', 'n', '', '>', '<C-w>>')
    call submode#map('winsize', 'n', '', '<', '<C-w><')
    call submode#map('winsize', 'n', '', '+', '<C-w>+')
    call submode#map('winsize', 'n', '', '-', '<C-w>-')
    " TODO: Repeat last executed macro. umaku dekinai...
    " call submode#enter_with('macro/a', 'n', '', '@a', '@a')
    " call submode#map('macro/a', 'n', '', 'a', '@a')
  endfunction

endif " }}}

if neobundle#tap('open-browser.vim') " {{{

  call neobundle#config({
        \   'autoload' : {
        \     'commands' : [ 'OpenBrowser', 'OpenBrowserSearch', 'OpenBrowserSmartSearch' ],
        \   }
        \ })

endif " }}}

if neobundle#tap('operator-html-escape.vim') " {{{

  call neobundle#config({
        \   'autoload' : {
        \     'on_source' : [ '' ]
        \   }
        \ })

endif " }}}

if neobundle#tap('vim-anzu') " {{{

  call neobundle#config({})

  " Treat folding well
  nnoremap <expr> n anzu#mode#mapexpr('n', '', 'zzzv')
  nnoremap <expr> N anzu#mode#mapexpr('N', '', 'zzzv')

  " Start search with anzu
  nmap * <Plug>(anzu-star-with-echo)
  nmap # <Plug>(anzu-sharp-with-echo)

  " clear status
  " nmap <Esc><Esc> <Plug>(anzu-clear-search-status)

endif " }}}

if neobundle#tap('vim-automatic') " {{{

  call neobundle#config({})

  nnoremap <silent> <Plug>(quit) :<C-u>q<CR>
  function! s:my_temporary_window_init(config, context)
    " nmap <buffer> <C-[>  <Plug>(quit)
    nnoremap <buffer> <C-[>  :<C-u>q<CR>
    " echo a:config
    " echo a:context
  endfunction

  function! s:my_unite_window_init(config, context)
    nmap <silent> <buffer> <C-c> <Plug>(unite_print_candidate)
    call s:my_temporary_window_init(a:config, a:context)
  endfunction

  let g:automatic_enable_autocmd_Futures = {}
  let g:automatic_default_match_config = {
        \   'is_open_other_window' : 1,
        \ }
  let g:automatic_default_set_config = {
        \   'height' : '60%',
        \   'move' : 'bottom',
        \   'apply' : function('s:my_temporary_window_init')
        \ }
  let g:automatic_config = [
        \   { 'match' : { 'buftype' : 'help' } },
        \   { 'match' : {
        \       'filetype' : 'vimshell',
        \       'autocmds' : ['FileType', 'BufWinEnter']
        \     },
        \     'set' : {
        \       'commands' : [ 'setl nonumber' ]
        \     }
        \   },
        \   { 'match' : { 
        \       'filetype' : 'vimshell',
        \       'is_open_other_window' : 0,
        \       'autocmds' : ['FileType', 'BufWinEnter']
        \     },
        \     'set' : {
        \       'unsettings' : [ 'resize', 'move', 'apply' ],
        \       'commands' : [ 'setl nonumber' ],
        \     }
        \   },
        \   { 'match' : {
        \      'autocmd_history_pattern' : 'BufWinEnterFileType$',
        \      'filetype' : 'unite'
        \     },
        \     'set' : {
        \       'apply' : function('s:my_unite_window_init')
        \     }
        \   },
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
        \       'filetype' : 'J6uil_say',
        \       'autocmds' : [ 'FileType' ]
        \     },
        \     'set' : {
        \       'height' : '8'
        \     }
        \   },
        \   {
        \     'match' : {
        \       'filetype' : 'godoc',
        \       'autocmds' : [ 'FileType' ]
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

endif " }}}

if neobundle#tap('gist-vim') " {{{

  call neobundle#config({
        \   'autoload' : {
        \     'commands' : ['Gist'],
        \   }
        \ })

  function! neobundle#tapped.hooks.on_source(bundle)
    " TODO: w3m
    " let g:gist_browser_command = 'w3m %URL%'
  endfunction

  let g:gist_open_browser_after_post = 1
  let g:gist_clip_command = 'pbcopy'
  let g:gist_detect_filetype = 1
  let g:gist_show_privates = 1
  let g:gist_post_private = 1

endif " }}}

if neobundle#tap('vim-prettyprint') " {{{

  call neobundle#config({
        \   'autoload' : { 'commands' : ['PP'] }
        \ })

endif " }}}

if neobundle#tap('vim-quickrun') " {{{

  call neobundle#config({
        \   'autoload' : {
        \     'mappings' : [ '<Plug>(quickrun)' ],
        \     'commands' : [ 'QuickRun' ],
        \   }
        \ })

  function! neobundle#tapped.hooks.on_source(bundle)
    call quickrun#module#register(shabadou#make_quickrun_hook_anim(
          \  'santi_pinch',
          \  ['＼(・ω・＼)　SAN値！', '　(／・ω・)／ピンチ！'],
          \  12
          \), 1)
    let g:quickrun_config = get(g:, 'quickrun_config', {})
    let g:quickrun_config._ = {
          \   'runner': 'vimproc',
          \   'runner/vimproc/updatetime': 40,
          \   'hook/santi_pinch/enable': 1,
          \   'hook/echo/enable' : 1,
          \   'hook/echo/enable_output_exit' : 1,
          \   'hook/echo/priority_exit' : 10000,
          \   'hook/echo/output_success': 'benri',
          \   'hook/echo/output_failure': 'huben'
          \ }
    let g:quickrun_config.markdown = {
          \   'outputter' : 'null',
          \   'command'   : 'open',
          \   'cmdopt'    : '-a',
          \   'args'      : 'Marked',
          \   'exec'      : '%c %o %a %s',
          \ }
    let g:quickrun_config.matlab = {
          \   'command'   : 'octave',
          \   'cmdopt'    : '--silent --persist',
          \   'exec'      : '%c %o %s'
          \ }
    let g:quickrun_config.lein_clojure = {
          \   'command': 'lein',
          \   'cmdopt': 'repl',
          \   'runner': 'process_manager',
          \   'runner/process_manager/load': '(load-file "%S")',
          \   'runner/process_manager/prompt': 'user=> '
          \ }
    let g:quickrun_config.clojure = {
          \   'type': 'lein_clojure'
          \ }
    let g:quickrun_config.clojure = {
          \   'runner': 'neoclojure',
          \   'command': 'dummy',
          \   'tempfile' : '%{tempname()}.clj'
          \ }
    " let g:quickrun_config.clojure = {
    "       \   'command': 'lein repl',
    "       \   'runner': 'process_manager',
    "       \   'runner/process_manager/load': '(load-file "%S")',
    "       \   'runner/process_manager/prompt': 'user=> '
    "       \ }
    " let g:quickrun_config.clojure = {
    "       \   'command'   : 'java -jar /usr/local/Cellar/clojure/1.5.1/clojure-1.5.1.jar',
    "       \   'runner': 'process_manager',
    "       \   'runner/process_manager/load': '(load-file "%S")',
    "       \   'runner/process_manager/prompt': 'user=> '
    "       \ }
    if exists('$METALANG')
      let g:quickrun_config.mql4 = {
            \   'command'   : 'wine',
            \   'cmdopt'    : '/usr/local/bin/metalang.exe',
            \   'exec'      : '%c %o %s'
            \ }
    endif
    " let g:quickrun_config.ruby = {
    "   \ 'command': 'irb',
    "   \ 'cmdopt': '--simple-prompt',
    "   \ 'hook/cd': 1,
    "   \ 'runner': 'process_manager',
    "   \ 'runner/process_manager/load': "load %s",
    "   \ 'runner/process_manager/prompt': '>>\s',
    "   \ }
  endfunction


  nnoremap <Space>r  :<C-u>QuickRun<CR>

endif " }}}

if neobundle#tap('vim-scall') " {{{
endif " }}}

if neobundle#tap('vim-singleton') " {{{

  function! neobundle#tapped.hooks.on_source(bundle)
  endfunction
  call singleton#enable()

endif " }}}

if neobundle#tap('vim-textobj-multiblock') " {{{

  function! neobundle#tapped.hooks.on_source(bundle)
  endfunction

  omap ab <Plug>(textobj-multiblock-a)
  omap ib <Plug>(textobj-multiblock-i)
  vmap ab <Plug>(textobj-multiblock-a)
  vmap ib <Plug>(textobj-multiblock-i)

endif " }}}

if neobundle#tap('vim-ref') " {{{

  call neobundle#config({
        \   'autoload' : {
        \     'commands' : [{
        \       'name' : 'Ref',
        \       'complete' : 'customlist,ref#complete'
        \     }],
        \     'unite_sources' : [ 'ref' ]
        \   }
        \ })

  let g:ref_open = 'split'
  let g:ref_refe_cmd = '~/.vim/ref/ruby-refm-1.9.3-dynamic-20120829/refe-1_9_3'

  aug MyAutoCmd
    au FileType ruby,eruby,ruby.rspec,haml nnoremap <silent><buffer><Space>d  :<C-u>Unite -no-start-insert ref/refe ref/ri -auto-preview -default-action=below -input=<C-R><C-W><CR>
    " au FileType php nnoremap <silent><buffer><Space>d  :<C-u>Unite -no-start-insert ref/refe ref/ri -auto-preview -default-action=below -input=<C-R><C-W><CR>
  aug END

endif " }}}

if neobundle#tap('vim-ref-ri') " {{{

  call neobundle#config({
        \   'autoload' : {
        \     'filetypes' : [ 'ruby', 'haml', 'eruby' ],
        \     'unite_sources' : [ 'ref/ri' ]
        \   },
        \ })

endif " }}}

if neobundle#tap('vim-qfreplace') " {{{

  call neobundle#config({
        \   'autoload' : {
        \     'filetypes' : [ 'unite', 'quickfix' ],
        \     'commands' : [ 'Qfreplace' ]
        \   }
        \ })

endif " }}}

if neobundle#tap('vim-editvar') " {{{

  call neobundle#config({
        \   'autoload' : {
        \     'commands' : [ 'Editvar' ],
        \     'unite_sources' : [ 'variable' ]
        \   }
        \ })

endif " }}}

if neobundle#tap('vim-endwise') " {{{

  call neobundle#config({
        \   'autoload' : {
        \     'filetypes' : [ 'ruby' ]
        \   }
        \ })

  function! neobundle#tapped.hooks.on_source(bundle)
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

endif " }}}

if neobundle#tap('vim-ruby') " {{{

  call neobundle#config({
        \   'autoload' : {
        \     'mappings' : [ '<Plug>(ref-keyword)' ],
        \     'filetypes' : [ 'ruby', 'haml', 'eruby' ],
        \   }
        \ })

endif " }}}

if neobundle#tap('vim-rails') " {{{

  call neobundle#config({
        \   'autoload' : {
        \     'filetypes' : [ 'ruby', 'haml', 'eruby' ]
        \   }
        \ })

  function! neobundle#tapped.hooks.on_source(bundle)
    nnoremap <Space>cm  :<C-u>Rmodel<CR>
    nnoremap <Space>cv  :<C-u>Rview<CR>
    nnoremap <Space>cc  :<C-u>Rcontroller<CR>
    nnoremap <Space>cl  :<C-u>Rlayout<CR>
    nnoremap <Space>ch  :<C-u>Rhelper<CR>
    nnoremap <Space>cj  :<C-u>Rjavascript<CR>
    nnoremap <Space>cs  :<C-u>Rstylesheet<CR>
  endfunction

  let g:rails_projections = {
        \ "app/uploaders/*_uploader.rb": {
        \   "command": "uploader",
        \   "template":
        \     "class %SUploader < CarrierWave::Uploader::Base\nend",
        \   "test": [
        \     "test/unit/%s_uploader_test.rb",
        \     "spec/models/%s_uploader_spec.rb"
        \   ],
        \   "keywords": "process version"
        \ },
        \ }

endif " }}}

if neobundle#tap('alpaca_tags') " {{{

  call neobundle#config({
        \   'autoload' : {
        \     'commands' : [ 'AlpacaTagsUpdate', 'AlpacaTagsSet', 'AlpacaTagsBundle' ]
        \   }
        \ })
  function! neobundle#tapped.hooks.on_source(bundle)
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

endif " }}}

if neobundle#tap('unite-rails') " {{{

  call neobundle#config({
        \   'autoload' : {
        \     'unite_sources' : [
        \       'rails/bundle', 'rails/bundled_gem', 'rails/config',
        \       'rails/controller', 'rails/db', 'rails/destroy', 'rails/features',
        \       'rails/gem', 'rails/gemfile', 'rails/generate', 'rails/git', 'rails/helper',
        \       'rails/heroku', 'rails/initializer', 'rails/javascript', 'rails/lib', 'rails/log',
        \       'rails/mailer', 'rails/model', 'rails/rake', 'rails/route', 'rails/schema', 'rails/spec',
        \       'rails/stylesheet', 'rails/view'
        \     ],
        \     'filetypes' : [ 'ruby', 'haml', 'eruby', 'rails' ],
        \   }
        \ })

  function! s:my.unite_rails_init()
    let g:UniteRailsAll = reti#lambda(':Unite -start-insert rails/model rails/controller rails/view rails/db rails/config rails/javascript rails/stylesheet rails/helper rails/mailer')
    " nnoremap <buffer> <C-x>r  :<C-u>call g:UniteRailsAll()<CR>
    nnoremap <buffer> <C-c>m  :<C-u>Unite -start-insert rails/model<CR>
    nnoremap <buffer> <C-c>c  :<C-u>Unite -start-insert rails/controller<CR>
    nnoremap <buffer> <C-c>v  :<C-u>Unite -start-insert rails/view<CR>
    nnoremap <buffer> <C-c>f  :<C-u>Unite -start-insert rails/config<CR>
    nnoremap <buffer> <C-c>j  :<C-u>Unite -start-insert rails/javascript<CR>
    nnoremap <buffer> <C-c>s  :<C-u>Unite -start-insert rails/stylesheet<CR>
    nnoremap <buffer> <C-c>d  :<C-u>Unite -start-insert rails/db<CR>
    nnoremap <buffer> <C-c>l  :<C-u>Unite -start-insert rails/lib<CR>
    nnoremap <buffer> <C-c>h  :<C-u>Unite -start-insert rails/helper<CR>
    nnoremap <buffer> <Space>j  :<C-u>call g:UniteRailsAll()<CR>
  endfunction

  aug MyAutoCmd
    " au User Rails call g:My.unite_rails_init()
    au FileType *rails* call g:My.unite_rails_init()
  aug END

endif " }}}

if neobundle#tap('vim-elixir') " {{{

  call neobundle#config({
        \   'autoload' : {
        \     'filetypes' : [ 'elixir' ],
        \   }
        \ })

endif " }}}

if neobundle#tap('vim-airline') " {{{

  " Sugoku Kakkoii but chotto jyama with MacBookAir's small DPI display.
  " let g:airline_left_sep  = '◤ '
  " let g:airline_right_sep = ' ◥'

  let g:airline_left_sep  = ''
  let g:airline_right_sep = ''

  let g:airline_detect_iminsert = 1
  let g:airline_theme = 'dark'

  " Enable fugitive
  let g:airline_enable_branch = 1
  let g:airline_branch_empty_message = ''

  " To show airline status on single window.
  set laststatus=2

endif " }}}

if neobundle#tap('vim-pronamachang') " {{{

  call neobundle#config({
        \   'autoload' : {
        \     'unite_sources' : [ 'pronamachang' ],
        \     'commands' : [ 'PronamachangSay' ],
        \   }
        \ })

  function! neobundle#tapped.hooks.on_source(bundle)
    let g:pronamachang_voice_root = '~/.pronamachang'
  endfunction

endif " }}}

if neobundle#tap('vim-sugarpot') " {{{

  call neobundle#config({
        \   'autoload' : {
        \     'commands' : [ 'SugarpotPreview' ],
        \   }
        \ })

  function! neobundle#tapped.hooks.on_source(bundle)
    let g:sugarpot_font = 'セプテンバーＭ-等幅:h1'
    let g:sugarpot_xpm_cache_directory = '~/.sugarpot'
    let g:sugarpot_convert = 'convert'
  endfunction

endif " }}}

if neobundle#tap('vim-watchdogs') " {{{

  call neobundle#config({
        \   'autoload' : {
        \     'commands' : [ 'WatchdogsRun' ],
        \   }
        \ })

  function! neobundle#tapped.hooks.on_source(bundle)
    let g:watchdogs_check_BufWritePost_enables = {
          \   'ruby' : 1,
          \   'mql4' : 1,
          \ }
    let g:quickrun_config = s:get(g:, 'quickrun_config', {})
    " let g:quickrun_config['mql4/watchdogs_checker'] = {
    "       \   'type' : 'watchdogs_checker/mql4'
    "       \ }
  endfunction

endif " }}}

if neobundle#tap('w3m.vim') " {{{

  call neobundle#config({
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

  function! neobundle#tapped.hooks.on_source(bundle)
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

endif " }}}

if neobundle#tap('TweetVim') " {{{

  call neobundle#config({
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

  function! s:my_tweetvim_mappings()
    nmap <buffer> j  <Plug>(tweetvim_action_cursor_down)
    nmap <buffer> k  <Plug>(tweetvim_action_cursor_up)
    nmap <buffer> f  <Plug>(tweetvim_action_favorite)
    nmap <buffer> m  <Plug>(tweetvim_action_reply)
    nmap <buffer> i  <Plug>(tweetvim_action_in_reply_to)
    nmap <buffer> r  <Plug>(tweetvim_action_retweet)
    nmap <buffer> q  <Plug>(tweetvim_action_qt)
    nmap <buffer> l  <Plug>(tweetvim_action_reload)
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
  au MyAutoCmd FileType tweetvim call s:my_tweetvim_mappings()
  au MyAutoCmd FileType tweetvim_say call s:my_tweetvim_say_mappings()

  " TODO: Make macvim shows graphical sign.
  let g:tweetvim_display_separator = 0
  let g:tweetvim_display_icon = 1
  let g:tweetvim_display_source = 0
  let g:tweetvim_display_username = 1
  let g:tweetvim_no_default_key_mappings = 1

endif " }}}

if neobundle#tap('lingr-vim') " {{{

  call neobundle#config({
        \   'autoload' : {
        \     'commands' : [ 'LingrLaunch' ],
        \   }
        \ })
  let g:J6uil_display_icon = 1
  let g:lingr_vim_user     = g:vimrc_secrets['J6uil_user']
  let g:lingr_vim_password = g:vimrc_secrets['J6uil_password']

endif " }}}

if neobundle#tap('J6uil.vim') " {{{

  call neobundle#config({
        \   'autoload' : {
        \     'commands' : [ 'J6uil' ],
        \     'unite_sources' : [ 'J6uil/members', 'J6uil/rooms' ],
        \   }
        \ })

  augroup MyAutoCmd
    autocmd FileType J6uil call s:J6uil_settings()
  augroup END

  function! s:J6uil_settings()
    nmap <silent> <buffer> <C-c><C-r>  <Plug>(J6uil_unite_rooms)
    nmap <silent> <buffer> <C-c><C-m>  <Plug>(J6uil_unite_members)
    nmap <silent> <buffer> <Space>cr  <Plug>(J6uil_unite_rooms)
    nmap <silent> <buffer> <Space>cm  <Plug>(J6uil_unite_members)
    nmap <silent> <buffer> <C-l>  <Plug>(J6uil_next_room)
    nmap <silent> <buffer> <C-h>  <Plug>(J6uil_prev_room)
  endfunction

  let g:J6uil_user     = g:vimrc_secrets['J6uil_user']
  let g:J6uil_password = g:vimrc_secrets['J6uil_password']
  let g:J6uil_multi_window = 1
  let g:J6uil_user_define_rooms = [
        \   'clojure',
        \   'computer_science',
        \   'momonga',
        \   'vim',
        \   'mtroom',
        \   'mcujm',
        \   'imascg',
        \   'monetize',
        \   'emacs',
        \   'meat',
        \   'clojure_ja',
        \   'lingr'
        \ ]

endif " }}}

if neobundle#tap('vimconsole.vim') " {{{

  call neobundle#config({
        \   'autoload' : {
        \     'commands' : [
        \       'VimConsole', 'VimConsoleLog', 'VimConsoleWarn', 'VimConsoleError',
        \       'VimConsoleOpen', 'VimConsoleClose', 'VimConsoleToggle', 'VimConsoleClear',
        \       'VimConsoleRedraw', 'VimConsoleDump'
        \     ]
        \   }
        \ })

  let g:vimconsole#auto_redraw = 1

  nnoremap <Space>d  :<C-u>VimConsoleToggle<CR>

endif " }}}

if neobundle#tap('emmet-vim') " {{{

  call neobundle#config({
        \   'autoload' : {
        \     'filetypes' : [ 'html', 'php', 'erb' ],
        \   }
        \ })

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

endif " }}}

if neobundle#tap('vim-less') " {{{

  call neobundle#config({
        \   'autoload' : {
        \     'filetypes' : [ 'less', 'html', 'haml' ],
        \   }
        \ })

endif " }}}

if neobundle#tap('vim-slim') " {{{

  call neobundle#config({
        \   'autoload' : {
        \     'filetypes' : [ 'slim' ],
        \   }
        \ })

endif " }}}

if neobundle#tap('vim-coffee-script') " {{{

  call neobundle#config({
        \   'autoload' : {
        \     'filetypes' : [ 'coffee', 'html', 'haml' ],
        \     'commands' : [ 'CoffeeCompile', 'CoffeeWatch', 'CoffeeRun', 'CoffeeLint' ]
        \   }
        \ })

  function! neobundle#tapped.hooks.on_source(bundle)
    augroup CoffeeBufNew
      autocmd!
      autocmd User * set wrap
    augroup END

    augroup CoffeeBufUpdate
      " TODO: Is this nani?
      " autocmd!
      " autocmd User CoffeeCompile,CoffeeWatch
    augroup END
  endfunction

endif " }}}

if neobundle#tap('layoutplugin.vim') " {{{

  call neobundle#config({
        \   'autoload' : {
        \     'commands' : [ 'LayoutPlugin' ]
        \   }
        \ })

endif " }}}

if neobundle#tap('vimhelpgenerator') " {{{

  call neobundle#config({
        \   'autoload' : {
        \     'commands' : [ 'LayoutPlugin', 'VimHelpGenerator', 'VimHelpGeneratorVirtual', 'HelpIntoMarkdown' ]
        \   }
        \ })

  function! neobundle#tapped.hooks.on_source(bundle)
      let g:vimhelpgenerator_version = 'Version : 1.0.0'
      let g:vimhelpgenerator_author = 'supermomonga (@supermomonga)'
      let g:vimhelpgenerator_uri = 'https://github.com/supermomonga/'
      let g:vimhelpgenerator_defaultlanguage = 'en'
  endfunction

endif " }}}

if neobundle#tap('vim-rengbang') " {{{

  call neobundle#config({
        \   'autoload' : {
        \     'commands' : [ 'RengBang', 'RengBangUsePrev', 'RengBangConfirm' ]
        \   }
        \ })

endif " }}}

if neobundle#tap('vim-snowdrop') " {{{

  call neobundle#config({
        \   'autoload' : {
        \     'commands' : [ 'SnowdropGotoDefinition', 'SnowdropEchoTypeof', 'SnowdropEchoResultTypeof', 'SnowdropEchoIncludes', 'SnowdropVerify' ],
        \   }
        \ })

  function! neobundle#tapped.hooks.on_source(bundle)
    let g:snowdrop#libclang_path='/Library/Developer/CommandLineTools/usr/lib'
  endfunction

endif " }}}

if neobundle#tap('vim-mql4') " {{{

  call neobundle#config({
        \   'autoload' : {
        \     'filetypes' : [ 'mql4' ],
        \   }
        \ })

endif " }}}

if neobundle#tap('go-vim') " {{{

  " au MyAutoCmd FileType go nmap <buffer> <C-c><C-i> <Plug>(go-import)

  call neobundle#config({
        \   'autoload': {
        \     'filetypes' : [ 'go', 'godoc' ],
        \     'mappings': [['n', '<Plug>(godoc-keyword)']],
        \     'commands': [{
        \       'complete': 'customlist,go#complete#Package',
        \       'name': 'Godoc'
        \     }]
        \   }
        \ })

  let $GOPATH = expand('~/.go')
  let $PATH = s:append_path($PATH, $GOPATH . '/bin')
  let $PATH = s:append_path($PATH, fnamemodify(resolve(exepath('go')), ":h"))

  au MyAutoCmd FileType go compiler go

endif " }}}

if neobundle#tap('vim-go') " {{{

  let g:go_import_commands = 1
  let g:go_snippet_engine = 'neosnippet'
  let g:go_fmt_fail_silently = 0
  let g:go_fmt_autosave = 1

  au MyAutoCmd FileType go nmap <buffer> <C-c><C-i> <Plug>(go-import)
  au MyAutoCmd FileType go nmap <buffer> <C-c><C-g><C-d> <Plug>(go-doc)
  au MyAutoCmd FileType go nmap <buffer> <C-c><C-g><C-v> <Plug>(go-doc-vertical)
  au MyAutoCmd FileType go nmap <buffer> <C-c><C-r> <Plug>(go-run)
  au MyAutoCmd FileType go nmap <buffer> <C-c><C-b> <Plug>(go-build)
  au MyAutoCmd FileType go nmap <buffer> <C-c><C-t> <Plug>(go-test)
  au MyAutoCmd FileType go nmap <buffer> <C-c><C-d><C-s> <Plug>(go-def-split)
  au MyAutoCmd FileType go nmap <buffer> <C-c><C-d><C-v> <Plug>(go-def-vertical)
  au MyAutoCmd FileType go nmap <buffer> <C-c><C-d><C-t> <Plug>(go-def-tab)
  au MyAutoCmd FileType go nmap <buffer> gd <Plug>(go-def)

  call neobundle#config({
        \   'autoload' : {
        \     'filetypes' : [ 'go', 'godoc' ],
        \     'commands' : [
        \       'GoImport',
        \       'GoImportAs',
        \       'GoDrop',
        \       'GoDisableGoimports',
        \       'GoEnableGoimports',
        \       'GoLint',
        \       'GoDoc',
        \       'GoFmt',
        \       'GoDef',
        \       'GoRun',
        \       'GoBuild',
        \       'GoTest',
        \       'GoErrCheck',
        \       'GoFiles',
        \       'GoDeps',
        \       'GoUpdateBinaries',
        \       'GoOracleDescribe',
        \       'GoOracleCallees',
        \       'GoOracleCallers',
        \       'GoOracleCallgraph',
        \       'GoOracleImplements',
        \       'GoOracleChannelPeers',
        \     ],
        \     'function_prefix' : 'go'
        \   }
        \ })

  let $GOPATH = expand('~/.go')
  let $PATH = s:append_path($PATH, $GOPATH . '/bin')
  let $PATH = s:append_path($PATH, '/usr/local/Cellar/go/1.2.1/libexec/bin')

  au MyAutoCmd FileType go setl noexpandtab

endif " }}}

if neobundle#tap('vim-golang') " {{{

  call neobundle#config({
        \   'autoload' : {
        \     'filetypes' : [ 'go', 'godoc' ],
        \     'commands' : [
        \       'Import',
        \       'ImportAs',
        \       'Drop',
        \       'Fmt',
        \       'GoDoc',
        \     ],
        \     'function_prefix' : 'go'
        \   }
        \ })

  let $GOPATH = expand('~/.go')
  let $PATH = s:append_path($PATH, $GOPATH . '/bin')
  let $PATH = s:append_path($PATH, '/usr/local/Cellar/go/1.2.1/libexec/bin')

  au MyAutoCmd FileType go setl noexpandtab

endif " }}}

if neobundle#tap('vim-gocode') " {{{

  call neobundle#config({
        \   'autoload' : {
        \     'filetypes' : [ 'go', 'godoc' ],
        \     'commands' : [
        \       'RelPkg',
        \       'GoInstall',
        \       'GoTest',
        \       'GoImport',
        \       'GoImportAs',
        \       'GoDrop',
        \       'make',
        \     ],
        \     'function_prefix' : 'go'
        \   }
        \ })

  let $GOPATH = expand('~/.go')
  let $PATH = s:append_path($PATH, $GOPATH . '/bin')
  let $PATH = s:append_path($PATH, '/usr/local/Cellar/go/1.2.1/libexec/bin')

  au MyAutoCmd FileType go setl noexpandtab

endif " }}}

if neobundle#tap('puyo.vim') " {{{

  call neobundle#config({
        \   'autoload' : {
        \     'commands' : [ 'Puyo' ],
        \   }
        \ })

endif " }}}

if neobundle#tap('mario.vim') " {{{

  call neobundle#config({
        \   'autoload' : {
        \     'commands' : [ 'Mario' ],
        \   }
        \ })

endif " }}}

if neobundle#tap('flappyvird-vim') " {{{

  call neobundle#config({
        \   'autoload' : {
        \     'commands' : [ 'FlappyVird' ],
        \   }
        \ })

endif " }}}

if neobundle#tap('vim-threes') " {{{

  call neobundle#config({
        \   'autoload' : {
        \     'commands' : [ 'ThreesStart' ],
        \   }
        \ })

endif " }}}

if neobundle#tap('emoji-vim') " {{{

  call neobundle#config({
        \   'autoload' : {
        \     'commands' : [ 'Emoji' ],
        \   }
        \ })

endif " }}}

if neobundle#tap('jazzradio.vim') " {{{
  call neobundle#config({
        \   'autoload' : {
        \     'unite_sources' : [
        \       'jazzradio'
        \     ],
        \     'commands' : [
        \       'JazzradioUpdateChannels',
        \       'JazzradioStop',
        \       {
        \         'name' : 'JazzradioPlay',
        \         'complete' : 'customlist,jazzradio#channel_key_complete'
        \       }
        \     ],
        \     'function_prefix' : 'jazzradio'
        \   }
        \ })
endif " }}}

if neobundle#tap('vim-ruby-xmpfilter') " {{{
  call neobundle#config({
        \   'autoload' : {
        \     'filetypes' : 'ruby'
        \   }
        \ })

  function! neobundle#tapped.hooks.on_source(bundle)
    let g:xmpfilter_cmd = 'seeing_is_believing'
    autocmd FileType ruby nmap <buffer> <C-s>m <Plug>(seeing_is_believing-mark)
    autocmd FileType ruby xmap <buffer> <C-s>m <Plug>(seeing_is_believing-mark)
    autocmd FileType ruby imap <buffer> <C-s>m <Plug>(seeing_is_believing-mark)
    autocmd FileType ruby nmap <buffer> <C-s>c <Plug>(seeing_is_believing-clean)
    autocmd FileType ruby xmap <buffer> <C-s>c <Plug>(seeing_is_believing-clean)
    autocmd FileType ruby imap <buffer> <C-s>c <Plug>(seeing_is_believing-clean)
    autocmd FileType ruby nmap <buffer> <C-s>r <Plug>(seeing_is_believing-run_-x)
    autocmd FileType ruby xmap <buffer> <C-s>r <Plug>(seeing_is_believing-run_-x)
    autocmd FileType ruby imap <buffer> <C-s>r <Plug>(seeing_is_believing-run_-x)
  endfunction

endif " }}}

if neobundle#tap('vim-monster') " {{{
  call neobundle#config({
        \   'autoload' : {
        \     'filetypes' : 'ruby'
        \   }
        \ })

  function! neobundle#tapped.hooks.on_source(bundle)
  endfunction

endif " }}}

if neobundle#tap('thingspast.vim') " {{{

  function! neobundle#tapped.hooks.on_source(bundle)
  endfunction

endif " }}}

if neobundle#tap('vim-splash') " {{{

  function! neobundle#tapped.hooks.on_source(bundle)
  endfunction
  " let g:splash#path = expand('~/.vim/splash.txt')
  let g:splash#path = expand('~/.vim/splasht.txt')

endif " }}}

if neobundle#tap('fclojure.vim') " {{{

  function! neobundle#tapped.hooks.on_source(bundle)
  endfunction

  call neobundle#config({
        \   'autoload' : {
        \     'commands' : [ 'FClojureOpenProblemList', 'FClojureOpenProblem', 'FClojureOpenAnswerColumn', 'FClojureOpenTopURL', 'FClojureOpenLogInURL', 'FClojureOpenSettingsURL', 'FClojureOpenProblemListURL', 'FClojureOpenProblemURL' ]
        \   }
        \ })

endif " }}}

if neobundle#tap('vim-ft-clojure') " {{{

endif " }}}

if neobundle#tap('neoclojure.vim') " {{{

  function! neobundle#tapped.hooks.on_source(bundle)
  endfunction

  let g:neoclojure_autowarmup = 1

  call neobundle#config({
        \ 'autoload' : {
        \   'function_prefix' : 'neoclojure'
        \ }
        \ })

  augroup vimrc-neoclojure
    autocmd!
    autocmd FileType clojure setlocal omnifunc=neoclojure#complete#omni
    " autocmd FileType clojure setlocal omnifunc=neoclojure#complete_timed
  augroup END

endif " }}}

if neobundle#tap('rainbow_parentheses.vim') " {{{

  function! neobundle#tapped.hooks.on_source(bundle)
  endfunction

  call neobundle#config({
        \   'autoload' : {
        \     'commands' : [ 'RainbowParenthesesToggle', 'RainbowParenthesesLoadRound', 'RainbowParenthesesLoadSquare', 'RainbowParenthesesLoadBraces', 'RainbowParenthesesLoadChevrons' ]
        \   }
        \ })

  au MyAutoCmd VimEnter * RainbowParenthesesToggle
  " au MyAutoCmd Syntax * RainbowParenthesesLoadRound
  " au MyAutoCmd Syntax * RainbowParenthesesLoadSquare
  " au MyAutoCmd Syntax * RainbowParenthesesLoadBraces

endif " }}}

if neobundle#tap('nebula.vim') " {{{

  function! neobundle#tapped.hooks.on_source(bundle)
  endfunction

  call neobundle#config('nebula.vim',
        \ {'autoload': {'commands': ['NebulaPutLazy', 'NebulaPutFromClipboard', 'NebulaYankOptions', 'NebulaYankConfig', 'NebulaPutConfig', 'NebulaYankTap']}})

endif " }}}

if neobundle#tap('rabbit-ui.vim') " {{{

  function! neobundle#tapped.hooks.on_source(bundle)
  endfunction

  call neobundle#config({
        \ 'autoload' : {
        \   'function_prefix' : 'rabbit_ui'
        \ }
        \ })

endif " }}}


" }}}

" }}}

" Misc {{{

" Apply delayed tasks{{{

call s:apply_queued_funccalls()

" }}}

" }}}

" Pre-plugin {{{
" }}}

