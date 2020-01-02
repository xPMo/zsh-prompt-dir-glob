#!/usr/bin/env zsh

declare -ga prompt_dir_glob__globs
declare -gA prompt_dir_glob__{prefix,suffix,truncate}

function .prompt_dir-glob::dir-gw(){
	zmodload zsh/parameter
	for g ($usergroups); do
		local f=("${REPLY}"(Eg$g))
		[[ -n $f ]] && return 0
	done
	return 1
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
	for dir ("$actual_init" ${(s:/:)remainder}); do
		# handle root case
		if [[ -z $dir_parts && $actual_init = / ]] &&
				! zstyle -t :dir-glob seperate-sections
		then
			dir_parts+=($POWERLEVEL9K_DIR_SEPARATOR)
			continue
		fi

		# match glob
		glob=
		for glob ("${(@)prompt_dir_glob__globs}"); do
			local f=("$head$dir/"$~glob)
			[[ -n $f ]] && break
			glob=fallback
		done

		# get prefix style
		dir_parts+=(${prompt_dir_glob__prefix[(e)$glob]:-$POWERLEVEL9K_DIR_FOREGROUND})

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
		dir_parts+=(${show_init:-${dir_truncated:-$dir}})
		unset show_init

		# get suffix style
		dir_parts+=(${prompt_dir_glob__suffix[(e)$glob]}$'%{\e[0m%}')
		dir_parts+=(${POWERLEVEL9K_DIR_SEPARATOR})
		head+=${dir}/
	done

	# don't append final separator
	p10k segment -t ${(j::)dir_parts[1,-2]}
}
