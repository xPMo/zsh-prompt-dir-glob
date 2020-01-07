#!/usr/bin/env zsh

cleanup(){
	rm $PROMPT_DIR_GLOB__CACHE_FILE
}
trap cleanup EXIT
PROMPT_DIR_GLOB__CACHE_FILE=$(mktemp)

source ${0:h}/p10k-dir-glob.zsh
zmodload zsh/zutil

# for demo purposes, replace p10k
p10k(){
	print -P $3'\e[0m'
}

prompt_dir_glob::add_glob -g '.git(/)' --pre '%B%F{green}'
prompt_dir_glob::add_glob -g '.git(.)' --pre   '%F{green}'
prompt_dir_glob::add_glob -g '(Uw)'    --pre   '%F{blue}'
prompt_dir_glob::add_glob -g '(Ie;.prompt_dir_glob::dir_gw;)' --pre '%F{cyan}' -t unique
prompt_dir_glob::add_glob -g '(Wt)'    --pre '%U%F{12}'
prompt_dir_glob__truncate[fallback]=unique
POWERLEVEL9K_DIR_FOREGROUND='magenta'

# Demo 1
# Include '/' in previous dir (default)
zstyle :dir_glob include-root false
zstyle :dir_glob truncate-pwd true

for dir; do
	( cd $dir && prompt_dir_glob )
done

print '\n=====\n'

# Demo 2
# Color / specially
PROMPT_DIR_GLOB__SEPARATOR='%F{244}/\e[0m'
prompt_dir_glob::clear_cache

for dir; do
	( cd $dir && prompt_dir_glob )
done

print '\n=====\n'

# Demo 3
# Separate segments
prompt_dir_glob::clear_cache
prompt_dir_glob__truncate[fallback]=c6
PROMPT_DIR_GLOB__SEPARATOR=' %B%F{245}\ue0b1 \e[0m'

zstyle :dir_glob include-root true
for dir; do
	(
	cd $dir && prompt_dir_glob )
done

