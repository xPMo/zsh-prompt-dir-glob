#!/usr/bin/env zsh
# {{{ Setup
cleanup(){
	rm $PROMPT_DIR_GLOB__CACHE_FILE
}
trap cleanup EXIT
PROMPT_DIR_GLOB__CACHE_FILE=$(mktemp)

source ${0:h}/p10k-dir-glob.zsh
zmodload zsh/zutil

# for demo purposes, replace p10k
p10k(){
	print -P '   '$3'\e[0m'
}
print
# }}}
# {{{ All demos
prompt_dir_glob::add_glob -g '.git(#q/)' --pre '%B%F{green}'
prompt_dir_glob::add_glob -g '.git(#q.)' --pre   '%F{green}'
prompt_dir_glob::add_glob -g '(#qW)'     --pre   '%F{yellow}'
prompt_dir_glob::add_glob -g '(#qUw)'    --pre   '%F{blue}'
prompt_dir_glob::add_glob -g '(#qIe;.prompt_dir_glob::is_dir_gw;)' --pre '%F{cyan}' -t unique
prompt_dir_glob::add_glob -g '(#qWt)'    --pre '%U%F{12}'
prompt_dir_glob__truncate[(#fallback)]=unique
POWERLEVEL9K_DIR_FOREGROUND='magenta'
# }}}
# {{{ Demo 1
# Include '/' in previous dir (default)
zstyle :dir_glob include-root false
zstyle :dir_glob truncate-pwd true

for dir; do
	( cd $dir && prompt_dir_glob )
done

print '\n=====\n'
# }}}
# {{{ Demo 2
# Color / specially
PROMPT_DIR_GLOB__SEPARATOR='%F{244}/'
prompt_dir_glob::clear_cache

for dir; do
	( cd $dir && prompt_dir_glob )
done

print '\n=====\n'
# }}}
# {{{ Demo 3
# Separate segments
# Also, icons, truncate
prompt_dir_glob::clear_cache

# truncate to 6 chars
prompt_dir_glob__truncate[(#fallback)]=c6
prompt_dir_glob__truncate[(Uw)]=c6

# add git icon to front of folders containing '.git'
prompt_dir_glob__prefix[.git(/)]+='\ue725 '
prompt_dir_glob__prefix[.git(.)]+='\ue725 '

# special glob: this folder is .git.
is_dot_git(){ [[ $REPLY == (|*/).git(|/) ]] }

# truncate to 0, show icon instead
# -G: Add it to the front of globs array
prompt_dir_glob::add_glob -G '(+is_dot_git)' --pre '%F{10}\ue5fb' -t c0

# Use nerd-fonts powerline chevron
PROMPT_DIR_GLOB__SEPARATOR=' %B%F{245}\ue0b1 '

zstyle :dir_glob include-root true
for dir; do
	( cd $dir && prompt_dir_glob )
done
# }}}
# vim: foldmethod=marker
