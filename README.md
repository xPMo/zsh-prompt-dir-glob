*This project is under development as part of my 100 days of code challenge, beginning 2020-01-01.*

# Directory Coloring by Globs

*An alternate directory segment for [Powerlevel10k](https://github.com/romkatv/powerlevel10k)*

Would you like to see your prompt path look like one of these?

![Fancy demo](https://raw.githubusercontent.com/xPMo/p10k-dir-glob/img/demo.png)

Well, this plugin is for you!
This plugin uses user-defined globs to format each directory in the tree separately.


## Usage

Want to color directories you own and can write to blue?
The glob qualifier `(U)` matches user-owned files, and `(w)` matches owner-writable files.

```zsh
prompt_dir_glob::add_glob --glob '(#qUw)' --prefix '%F{blue}'
```

Do you want to do use cyan for the groups your in and can write to?
This plugin provides a function which you can use:

```zsh
prompt_dir_glob::add_glob -g '(e[.prompt_dir_glob::is_dir_gw])' --prefix '%F{cyan}'
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

_(See `prompt_dir_glob::add_glob --help` for more information.)_


Prefer a different path separator than the boring `/`?

```zsh
PROMPT_DIR_GLOB__SEPARATOR=' %B%F{245}\ue0b1 '
```

Did you add or change globs in your config recently?
We cache previous entries to save expensive `stat` calls,
so you probably need to clear the cache:

```zsh
prompt_dir_glob::clear_cache
```

Did you change the properties of some directory?
Maybe called `git init` inside an empty directory?
Clear out the cache for all directories underneath a given directory:

```
prompt_dir_glob::clear_cache $PWD
```



## Source order

We recommend loading/sourcing this plugin
_before_ loading/sourcing Powerlevel10k.

This means that you must configure your globs
with `prompt_dir_glob::add_glob` _after_ 


## Installation

**Antigen**:
```zsh
antigen bundle xPMo/p10k-dir-globs
antigen apply
```

**Zgen**:
```zsh
zgen load xPMo/p10k-dir-glob
zgen save
```


**Zplug**:
```zsh
zplug xPMo/p10k-dir-glob
```

**Zplugin**:
```zsh
zplugin ice wait "0"
zplugin light xPMo/p10k-dir-glob

# Optionally, track the latest development version:
zplugin ice wait "0" ver"dev"
zplugin light xPMo/p10k-dir-glob
```

**Manually**: Clone the project, and then source it:
```zsh
source /path/to/p10k-dir-glob/p10k-dir-glob.plugin.zsh
```


## Problems? Questions? Contributions?

As with all my projects, I am happy to have feedback and help.
Taking a step back, and looking at this,
I find this project borders on overdesigned.
With that in mind, feel free to make an issue saying "I don't know how to use this"
if you want to help me make this README better.
