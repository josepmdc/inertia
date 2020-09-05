INERTIA_DOT_FILE=".inertiarc"
INERTIA_EXEC_DOT_FILE=false
INERTIA_SHOW_GIT_STASH=true
INERTIA_PROMPT_SYMBOL="λ"

INERTIA_GIT_PROMPT_PREFIX="$fg[yellow]"
INERTIA_GIT_PROMPT_SUFFIX=""
INERTIA_GIT_PROMPT_DIRTY=" $fg[red]"
INERTIA_GIT_PROMPT_CLEAN=" $fg[cyan]"
INERTIA_GIT_PROMPT_AHEAD="$fg[green]⇡"
INERTIA_GIT_PROMPT_BEHIND="$fg[magenta]⇣"
INERTIA_GIT_PROMPT_DIVERGED="$INERTIA_GIT_PROMPT_AHEAD$INERTIA_GIT_PROMPT_BEHIND"

ZSH_THEME_GIT_PROMPT_PREFIX="$INERTIA_GIT_PROMPT_PREFIX"
ZSH_THEME_GIT_PROMPT_SUFFIX="$INERTIA_GIT_PROMPT_SUFFIX"
ZSH_THEME_GIT_PROMPT_DIRTY="$INERTIA_GIT_PROMPT_DIRTY"
ZSH_THEME_GIT_PROMPT_CLEAN="$INERTIA_GIT_PROMPT_CLEAN"
ZSH_THEME_GIT_PROMPT_AHEAD="$INERTIA_GIT_PROMPT_AHEAD"
ZSH_THEME_GIT_PROMPT_BEHIND="$INERTIA_GIT_PROMPT_BEHIND"
ZSH_THEME_GIT_PROMPT_DIVERGED="$INERTIA_GIT_PROMPT_DIVERGED"

VIRTUAL_ENV_DISABLE_PROMPT="yes"

inertia-pwd() {
    if [[ "$PWD" == "$HOME" ]]; then
        echo "~"
    else
        echo "$(dirs -c; dirs)"
    fi
}

inertia-ssh-prompt() {
    if [[ -n "$SSH_CONNECTION" ]]; then
        echo "$fg[magenta]%n@%m » "
    elif [[ "$USER" == "root" ]]; then
        echo "$fg[red]%n » "
    fi
}

inertia-level-prompt() {
    printf "$fg_bold[magenta]»"
    printf "$reset_color $(inertia-ssh-prompt)$fg[white]$(inertia-pwd)"
}

inertia-git-prompt() {
    ref=$(git symbolic-ref HEAD 2> /dev/null) || return 0
    command git -c gc.auto=0 fetch &>/dev/null 2>&1 &|
    local index=$(command git status --porcelain -b 2> /dev/null)

    local git_status
    if $(echo "$index" | grep '^## .*ahead* .*behind' &> /dev/null); then
        git_status=" $ZSH_THEME_GIT_PROMPT_DIVERGED"
    elif $(echo "$index" | grep '^## .*ahead' &> /dev/null); then
        git_status=" $ZSH_THEME_GIT_PROMPT_AHEAD"
    elif $(echo "$index" | grep '^## .*behind' &> /dev/null); then
        git_status=" $ZSH_THEME_GIT_PROMPT_BEHIND"
    fi

    local git_stash
    if [[ "$INERTIA_SHOW_GIT_STASH" == true ]]; then
        git_stash="$(command git stash list | wc -l)"
        if [[ "$git_stash" > 0 ]]; then
            git_stash="$reset_color$fg[magenta]+$git_stash $fg_bold[white]"
        else
            git_stash=" "
        fi
    else
        git_stash=" "
    fi

    printf "$(parse_git_dirty)$git_stash"
    printf "$ZSH_THEME_GIT_PROMPT_PREFIX$(current_branch)"
    printf "$ZSH_THEME_GIT_PROMPT_SUFFIX$git_status$reset_color"
}

inertia-run-dotfile() {
    if [[ "$INERTIA_EXEC_DOT_FILE" == true ]] && [[ -f "$INERTIA_DOT_FILE" ]]; then
        source "$INERTIA_DOT_FILE"
    fi
}

inertia-ret-status() {
    echo "%(?:%{$fg[green]%}$INERTIA_PROMPT_SYMBOL:%{$fg[red]%}$INERTIA_PROMPT_SYMBOL) "
}

autoload -Uz add-zsh-hook

add-zsh-hook chpwd inertia-run-dotfile

PROMPT='
$(inertia-level-prompt)$(inertia-git-prompt)
%1v$(inertia-ret-status)%{$fg_no_bold[white]%}'
