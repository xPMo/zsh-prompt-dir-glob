#!/usr/bin/env zsh

declare -ga prompt_dir_glob__globs
declare -gA prompt_dir_glob__{prefix,suffix,truncate}
declare -gA __prompt_dir_glob__cache

[[ -r ${XDG_CACHE_HOME:-$HOME/.cache}/p10k_dir_glob.cache ]] &&
	. ${XDG_CACHE_HOME:-$HOME/.cache}/p10k_dir_glob.cache

function .prompt_dir-glob::dir-gw(){
	zmodload zsh/parameter
	for g ($usergroups); do
		local f=("${REPLY}"(Eg$g))
		[[ -n $f ]] && return 0
	done
	return 1
}

function .prompt_dir-glob::cache(){
	typeset -p __prompt_dir_glob__cache > ${XDG_CACHE_HOME:-$HOME/.cache}/p10k_dir_glob.cache
	zcompile ${XDG_CACHE_HOME:-$HOME/.cache}/p10k_dir_glob.cache
}

function prompt_dir-glob::clear-cache(){
	: > ${XDG_CACHE_HOME:-$HOME/.cache}/p10k_dir_glob.cache
	__prompt_dir_glob__cache=( )
}

function prompt_dir-glob::add-glob() {
	zmodload zsh/zutil
	local -a glob prefix suffix truncate 
	local f g
	zparseopts - g:=glob -pre:=prefix -suf:=suffix t:=truncate
	for f g in "${(@)glob}"; do
		prompt_dir_glob__globs+=("$g")
		[[ -v prefix ]] && prompt_dir_glob__prefix[$g]=$prefix[2]
		[[ -v suffix ]] && prompt_dir_glob__suffix[$g]=$suffix[2]
		[[ -v truncate ]] && prompt_dir_glob__truncate[$g]=$truncate[2]
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
			local -a parts=()
			# match glob
			glob=
			for glob ("${(@)prompt_dir_glob__globs}"); do
				local f=("$head$dir/"$~glob)
				[[ -n $f ]] && break
				glob=fallback
			done

			# get prefix style
			parts+=(${prompt_dir_glob__prefix[(e)$glob]:-$POWERLEVEL9K_DIR_FOREGROUND})

			# {{{ truncate dir
			# don't truncate show_init
			local dir_truncated=''
			if
				[[ -z $show_init && $prompt_dir_glob__truncate[(e)$glob] ]] &&
				{ [[ ${head:a}/$dir != $actual ]] || zstyle -t :dir-glob truncate-pwd false }
			then
				case $prompt_dir_glob__truncate[(e)$glob] in
				u*) # unique
					for c (${(s::)dir}); do
						set +f
						dir_truncated+=$c
						local f=("$head$dir_truncated"*(Y2))
						(( $#f < 2 )) && break
					done
				;;
				c*) # char:NUM
					w=${${(M)dir%%[[:digit:]]*}:-1}
					dir_truncated=${dir[1,w]}
				esac
			fi
			# }}}
			parts+=(${show_init:-${dir_truncated:-$dir}})
			unset show_init

			# get suffix style
			parts+=(${prompt_dir_glob__suffix[(e)$glob]}$'%{\e[0m%}')

			# add to parts and cache
			dir_parts+=(${__prompt_dir_glob__cache[$head$dir]::=${(j::)parts}})

			# schedule cache writeout
			if [[ ! ${(M)zsh_scheduled_events:#*.prompt_dir-glob::cache} ]]; then
				sched +15 .prompt_dir-glob::cache
			fi
		fi
		dir_parts+=(${POWERLEVEL9K_DIR_SEPARATOR})
		head+=${dir}/
	done

	# don't append final separator
	p10k segment -t ${(j::)dir_parts[1,-2]}
}
