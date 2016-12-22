
set encoding=utf-8
scriptencoding utf-8

set winaltkeys=yes guioptions=mM

if &compatible
    set nocompatible
endif


" For mintty, change cursor design
let &t_ti.="\e[1 q"
let &t_SI.="\e[5 q"
let &t_EI.="\e[1 q"
let &t_te.="\e[0 q"
