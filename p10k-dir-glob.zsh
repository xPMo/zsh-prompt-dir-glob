#!/usr/bin/env zsh
# Set $0 correctly in any context
0="${${ZERO:-${0:#$ZSH_ARGZERO}}:-${(%):-%N}}"
0="${${(M)0:#/*}:-$PWD/$0}"

fpath+=(${0:h})
autoload -Uz .prompt_dir-glob::format-dir

declare -ga prompt_dir_glob__globs
declare -gA prompt_dir_glob__{prefix,suffix,truncate}
declare -gA __prompt_dir_glob__cache
: ${PROMPT_DIR_GLOB__CACHE_FILE:=${XDG_CACHE_HOME:-$HOME/.cache}/p10k_dir_glob.cache}

[[ -r $PROMPT_DIR_GLOB__CACHE_FILE ]] &&
	. $PROMPT_DIR_GLOB__CACHE_FILE

function .prompt_dir-glob::dir-gw(){
	zmodload zsh/parameter
	for g ($usergroups); do
		local f=("${REPLY}"(Eg$g))
		[[ -n $f ]] && return 0
	done
	return 1
}

function prompt_dir-glob::flush-cache(){
	typeset -p __prompt_dir_glob__cache > $PROMPT_DIR_GLOB__CACHE_FILE
	zcompile $PROMPT_DIR_GLOB__CACHE_FILE
}

# Clear cache, or clear cache under given directory
# relative paths are not supported
function prompt_dir-glob::clear-cache(){
	if [[ -n $1 ]]; then
		for dir in $__prompt_dir_glob__cache[(I)(${1%/}|${1%/}/*)]; do
			unset "__prompt_dir_glob__cache[$dir]"
		done
		prompt_dir-glob::flush-cache
	else
		__prompt_dir_glob__cache=( )
		: > $PROMPT_DIR_GLOB__CACHE_FILE
	fi
}

# A front-end to prompt_dir_glob* arrays
function prompt_dir-glob::add-glob() {
	zmodload zsh/zutil
	local -a glob prefix suffix truncate 
	local f g
	zparseopts - g:=glob -pre:=prefix -suf:=suffix t:=truncate
	for f g in "${(@)glob}"; do
		prompt_dir_glob__globs+=("$g")
		[[ -v prefix ]] && prompt_dir_glob__prefix[$g]=$prefix[-1]
		[[ -v suffix ]] && prompt_dir_glob__suffix[$g]=$suffix[-1]
		[[ -v truncate ]] && prompt_dir_glob__truncate[$g]=$truncate[-1]
	done
}

function prompt_dir-glob(){
	setopt -L nullglob

	local head dir show actual actual_init show_init remainder
	show=${(%):-'%~'}
	actual=${(%):-'%/'}
	actual_init=${actual%${show#*/}}
	show_init=${show%%/*}
	remainder=${actual#$actual_init}

	local glob
	local -a dir_parts
	for dir ("${actual_init%/}" ${(s:/:)remainder}); do
		# handle root case
		if [[ -z $dir ]]; then
			if ! zstyle -t :dir-glob seperate-sections; then
				dir_parts+=($POWERLEVEL9K_DIR_SEPARATOR)
				head=/
				continue
			fi
			dir=/
		fi

		if [[ -v __prompt_dir_glob__cache[$head$dir] ]]; then
			# use cache
			dir_parts+=($__prompt_dir_glob__cache[$head$dir])
		else
			.prompt_dir-glob::format-dir
		fi
		dir_parts+=(${POWERLEVEL9K_DIR_SEPARATOR})
		head+=${dir}/
	done

	# don't append final separator
	p10k segment -t ${(j::)dir_parts[1,-2]}
}
