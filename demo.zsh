#!/usr/bin/env zsh

source ./p10k-dir-glob.zsh

prompt_dir-glob::clear-cache

POWERLEVEL9K_DIR_FOREGROUND='%F{magenta}'
POWERLEVEL9K_DIR_SEPARATOR='%F{244}/'

prompt_dir_glob__truncate[fallback]=unique

prompt_dir-glob::add-glob -g '.git(/)' --pre '%B%F{green}'
prompt_dir-glob::add-glob -g '.git(.)' --pre   '%F{green}'
prompt_dir-glob::add-glob -g '(Uw)'    --pre   '%F{blue}'
prompt_dir-glob::add-glob -g '(Ie,.prompt_dir-glob::dir-gw,)' --pre '%F{cyan}' -t unique
prompt_dir-glob::add-glob -g '(Wt)'    --pre '%U%F{12}'
zmodload zsh/zutil
zstyle -b :dir-glob seperate-sections true
zstyle -b :dir-glob truncate-pwd true

(
	[[ -d $1 ]] && cd $1

	# for demo purposes, replace p10k
	p10k(){
		print -P $3
	}
	prompt_dir-glob
)
