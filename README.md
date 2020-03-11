*This project is under development as part of my 100 days of code challenge, beginning 2020-01-01.*

<!-- TODO:
- Explain zstyle options
-->

# Directory Coloring by Globs

*An alternate directory segment for \$your_prompt*

Would you like to see your prompt path look like one of these?

![Fancy demo](https://raw.githubusercontent.com/xPMo/zsh-prompt-dir-glob/img/demo.png)

Well, this plugin is for you!
This plugin uses user-defined globs to format each directory in the tree separately.


## Usage

### Prompt Support

<details>
<summary><b> Powerlevel10k </b></summary>

<br/>

For [powerlevel10k](https://github.com/romkatv/powerlevel10k), add the following to your `.p10k.zsh`:

```zsh
typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(
	... # segments you want before this segment
	dir_glob
	... # segments you want after this segment
)
function prompt_dir_glob () {
	local REPLY
	prompt_dir_glob::build
	p10k segment -t $REPLY
}
```
</details>

<details>
<summary><b> Apollo </b></summary>

<br/>

For [Apollo](https://github.com/mjrafferty/apollo-zsh-theme), add the following to your `.zshrc`:

```zsh
zstyle ":apollo:${theme_name}:core:modules:left" modules \
	[modules you want before this module] dir_glob [modules you want after this module]
function __apollo_dir_glob_run() {
	local REPLY
	prompt_dir_glob::build
	__APOLLO_RETURN_MESSAGE=$REPLY
}
```
</details>

<details>
<summary><b> Geometry </b></summary>

<br/>

For [Geometry](https://github.com/geometry-zsh/geometry), add the following to your `.zshrc`:

```zsh
GEOMETRY_PROMPT=(
	... # segments you want before this segment
	prompt_dir_glob
	... # segments you want after this segment
)
function prompt_dir_glob () {
	local REPLY
	prompt_dir_glob::build
	print -P -n $REPLY
}
```
</details>

<details>
<summary><b> Bullet Train </b></summary>

<br/>

For [Bullet Train](https://github.com/caiogondim/bullet-train.zsh), add the following to your `.zshrc`:

```zsh
BULLETTRAIN_PROMPT_ORDER=(
	... # segments you want before this segment
	dir_glob
	... # segments you want after this segment
)
function prompt_dir_glob () {
	local REPLY
	prompt_dir_glob::build
	print -P -n $REPLY
}
```
</details>

### Adding globs

Want to color directories you own and can write to blue?
The glob qualifier `(U)` matches user-owned files, and `(w)` matches owner-writable files.

```zsh
prompt_dir_glob::add_glob --glob '(#qUw)' --prefix '%F{blue}'
```

Do you want to do use cyan for directories that groups you are a member of can write to?
This plugin provides a function which you can use:

```zsh
prompt_dir_glob::add_glob -g '(e[prompt_dir_glob::is_dir_gw])' --prefix '%F{cyan}'
```

Want to append directories containing a `.git` directory with a [cool git icon](https://www.nerdfonts.com)?

```zsh
prompt_dir_glob::add_glob -g '.git(#q/)' --suffix ' \ue725'
```

Want to truncate all directories not matched by one of your globs to 4 characters?
Use the special value `(#fallback)`.

```zsh
prompt_dir_glob::add_glob -g '(#fallback)' --truncate c4
```

See `prompt_dir_glob::add_glob --help` for more information.

### Changing the path separator

Prefer a different path separator than the boring `/`?

```zsh
PROMPT_DIR_GLOB__SEPARATOR=' %B%F{245}\ue0b1 '
```

### Cache

This plugin caches the matched glob and truncation values
for all previously seen directories,
so you may need to tell it to ignore the cache in certain cases.

Did you add or change globs in your config recently?
We cache previous entries to save expensive `stat` calls,
so you probably need to clear the cache:

```zsh
prompt_dir_glob::clear_cache -g   # or '-t' to clear the truncate cache
```

Did you change the properties of some specific directory?
Maybe called `git init` inside an empty directory?
Clear out the cache for all directories underneath a given directory:

```
prompt_dir_glob::clear_cache $PWD
```

If you use unique-path truncation,
you may wish to reset the stored truncation
when creating a new directory or file.
Use a function like this to wrap `mkdir`:

```zsh
function mkdir() {
	# support both builtin mkdir (from zsh/files module) and external command mkdir
	emulate -L zsh
	setopt posixbuiltins

	local arg
	for arg; do
		unset "__prompt_dir_glob__truncate_cache[${${arg:a}:h}]"
	done
	command mkdir "$@"
}
```

This will interpret flags as directories,
so if you provide flags to `mkdir`,
it will unset the cached truncation of the current working directory as well.
`mkdir` will still interpret flags correctly, though.


## Source order

We recommend loading/sourcing this plugin
_before_ loading/sourcing your desired prompt.

Since `prompt_dir_glob::add_glob` is provided by this plugin,
make sure not to call it until after loading the plugin.

## Installation

**Antigen**:
```zsh
antigen bundle xPMo/zsh-prompt-dir-globs
antigen apply
```

**Zgen**:
```zsh
zgen load xPMo/zsh-prompt-dir-glob
zgen save
```


**Zplug**:
```zsh
zplug xPMo/zsh-prompt-dir-glob
```

**Zplugin**:
```zsh
zplugin ice wait "0"
zplugin light xPMo/zsh-prompt-dir-glob

# Optionally, track the latest development version:
zplugin ice wait "0" ver"dev"
zplugin light xPMo/zsh-prompt-dir-glob
```

**Manually**: Clone the project, and then source it:
```zsh
source /path/to/zsh-prompt-dir-glob/zsh-prompt-dir-glob.plugin.zsh
```


## Problems? Questions? Contributions?

As with all my projects, I am happy to have feedback and help.
Taking a step back, and looking at this,
I find this project borders on overdesigned.
With that in mind, feel free to make an issue saying "I don't know how to use this"
if you want to help me make this README better.
