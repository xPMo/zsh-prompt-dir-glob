#!/usr/bin/env zsh
# Set $0 correctly in any context
0="${${ZERO:-${0:#$ZSH_ARGZERO}}:-${(%):-%N}}"
0="${${(M)0:#/*}:-$PWD/$0}"

# We need zparseopts
zmodload zsh/zutil

fpath+=(${0:h})
autoload -Uz prompt_dir_glob{,::add_glob}

declare -ga prompt_dir_glob__globs
declare -gA prompt_dir_glob__{prefix,suffix,truncate}
declare -gA __prompt_dir_glob__{truncate_,}cache
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
	typeset -p __prompt_dir_glob__{truncate_,}cache > $PROMPT_DIR_GLOB__CACHE_FILE
	zcompile $PROMPT_DIR_GLOB__CACHE_FILE
}

# Clear cache, or clear cache under given directory
# relative paths are not supported
function prompt_dir_glob::clear_cache() {
	local -a opts
	zparseopts -D -E -a opts - g t h -help
	if [[ $opts[(I)(-h|--help)] ]]; then
		print -P -l \
			"Usage: $0 [ -h | --help ] | [ -g ] [ -t ] [ DIRECTORY ... ]"
			''
			'If no flag is provided, both caches will be cleared'
			'If no directory is provided, the whole array will be cleared'
			''
			'	-h|--help   Show this help'
			'	-g          Clear the glob matching cache'
			'	-t          Clear the truncation cache'
			'	DIRECTORY   The directories to clear'
		return
	fi
	# if no opts, add both '-g' and '-t'
	opts=(${opts:--{g,t}})
	if (( $opts[(I)-g] )); then
		if [[ -n $1 ]]; then
			unset '__prompt_dir_glob__cache['${^__prompt_dir_glob__cache[(I)(${1%/}|${1%/}/*)]}']'
		else
			__prompt_dir_glob__cache=( )
		fi
	fi
	if (( $opts[(I)-t] )); then
		if [[ -n $1 ]]; then
			unset '__prompt_dir_glob__truncate_cache['${^__prompt_dir_glob__cache[(I)(${1%/}|${1%/}/*)]}']'
		else
			__prompt_dir_glob__truncate_cache=( )
		fi
	fi
	prompt_dir_glob::flush_cache
}
