#!/usr/bin/env zsh
# Set $0 correctly in any context
0="${${ZERO:-${0:#$ZSH_ARGZERO}}:-${(%):-%N}}"
0="${${(M)0:#/*}:-$PWD/$0}"

fpath+=(${0:h})
autoload -Uz .prompt_dir_glob::format_dir prompt_dir_glob::add_glob

declare -ga prompt_dir_glob__globs
declare -gA prompt_dir_glob__{prefix,suffix,truncate}
declare -gA __prompt_dir_glob__cache
: ${PROMPT_DIR_GLOB__CACHE_FILE:="${XDG_CACHE_HOME:-$HOME/.cache}/p10k_dir_glob.cache"}
: ${PROMPT_DIR_GLOB__SEPARATOR:=${POWERLEVEL9K_DIR_SEPARATOR:-'/'}}

[[ -r $PROMPT_DIR_GLOB__CACHE_FILE ]] && . $PROMPT_DIR_GLOB__CACHE_FILE

function .prompt_dir_glob::is_dir_gw() {
	zmodload zsh/parameter
	for g ($usergroups); do
		local f=("${REPLY}"(Eg$g))
		[[ -n $f ]] && return 0
	done
	return 1
}

function prompt_dir_glob::flush_cache() {
	typeset -p __prompt_dir_glob__cache > $PROMPT_DIR_GLOB__CACHE_FILE
	zcompile $PROMPT_DIR_GLOB__CACHE_FILE
}

# Clear cache, or clear cache under given directory
# relative paths are not supported
function prompt_dir_glob::clear_cache() {
	if [[ -n $1 ]]; then
		for dir in $__prompt_dir_glob__cache[(I)(${1%/}|${1%/}/*)]; do
			unset "__prompt_dir_glob__cache[$dir]"
		done
		prompt_dir_glob::flush_cache
	else
		__prompt_dir_glob__cache=( )
		: > $PROMPT_DIR_GLOB__CACHE_FILE
	fi
}

function prompt_dir_glob() {
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
			if zstyle -t :dir_glob include-root; then
				dir=/
			else
				head=/
			fi
		fi
		.prompt_dir_glob::format_dir

		unset show_init
		# reset foreground style
		dir_parts+=("$PROMPT_DIR_GLOB__SEPARATOR%b%f%u")
		head+=${dir}/
	done

	# don't append final separator
	p10k segment -t ${(j::)dir_parts[1,-2]}
}
