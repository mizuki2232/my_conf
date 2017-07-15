bindkey -d  # いったんキーバインドをリセット
bindkey -e  # emacsモードで使う

# cadファイルバックアップ用のコマンド
alias ford_upload='aws s3 cp ~/Desktop/cad s3://freecad --exclude "*" --include "*.FCStd" --recursive'
# cadファイルダウンロード用のコマンド
alias ford_download='aws s3 cp s3://freecad ~/Desktop/cad --exclude "*" --include "*.FCStd" --recursive'

# ssh agent invoke command (for github)
eval "$(ssh-agent -s)"
ssh-add -K ~/.ssh/internal_automation

# python alias
alias py='python'

# zshrc load
alias load='source ~/.zshrc'

# cadバップアップとダウンロード用のコマンド。 こんな感じで使ってね  ford upload filename
function ford(){
    if ["$0" -eq "upload" ]
    then
    command aws s3 cp  ~/Desktop/cad/$1 s3://freecad
    elif ["$0" -eq "download" ]
    then
    command aws s3 cp s3://freecad/$1 .
    else
    echo #something wrong!#
    fi
}

# raspberrypi3接続用のコマンド
alias raspi='sshpass -p iyan-michadame ssh pi@raspberrypi.local'

# 自動補完を有効にする
# コマンドの引数やパス名を途中まで入力して <Tab> を押すといい感じに補完してくれる
# 例： `cd path/to/<Tab>`, `ls -<Tab>`
autoload -U compinit; compinit
# 入力したコマンドが存在せず、かつディレクトリ名と一致するなら、ディレクトリに cd する
# 例： /usr/bin と入力すると /usr/bin ディレクトリに移動
setopt auto_cd

alias ..='cd ..'
# ↑を設定すると、 .. とだけ入力したら1つ上のディレクトリに移動できるので……
# 2つ上、3つ上にも移動できるようにする
alias ...='cd ../..'
alias ....='cd ../../..'
# cd した先のディレクトリをディレクトリスタックに追加する
# ディレクトリスタックとは今までに行ったディレクトリの履歴のこと
# `cd +<Tab>` でディレクトリの履歴が表示され、そこに移動できる
setopt auto_pushd
# pushd したとき、ディレクトリがすでにスタックに含まれていればスタックに追加しない
setopt pushd_ignore_dups

# 入力したコマンドがすでにコマンド履歴に含まれる場合、履歴から古いほうのコマンドを削除する
# コマンド履歴とは今まで入力したコマンドの一覧のことで、上下キーでたどれる
setopt hist_ignore_all_dups

# <Tab> でパス名の補完候補を表示したあと、
# 続けて <Tab> を押すと候補からパス名を選択できるようになる
# 候補を選ぶには <Tab> か Ctrl-N,B,F,P
zstyle ':completion:*:default' menu select=1

# lsに色付け
alias ls='ls -G'
# 日本語の設定
export LANG=ja_JP.UTF-8
export LC_ALL=ja_JP.UTF-8
export EDITOR=vim
export TERM=xterm-256color
# djangoの設定ファイルの位置を教える環境変数
export DJANGO_SETTINGS_MODULE=settings
# lsコマンドに色付け
export TERM=xterm-color
alias ls='ls -G'
alias ll='ls -hl'
# プロンプトの設定＋Gitで管理しているディレクトリに移動するとブランチ名を表示
setopt PROMPT_SUBST
source ~/.git-prompt.sh
VCS_PROMPT="%1(v|%F{green} %"
PROMPT='[%n]\$ '
RPROMPT='[%c%F{green}$(__git_ps1 "(%s)")%f]'

# Set path for pyenv
export PYENV_ROOT="${HOME}/.pyenv"
if [ -d "${PYENV_ROOT}" ]; then
    export PATH=${PYENV_ROOT}/bin:$PATH
    eval "$(pyenv init -)"
    eval "$(pyenv virtualenv-init -)"
fi

# vim <=> tmux 間でクリップボード利用を可能にする
# set-option -g default-command "reattach-to-user-namespace -l $SHELL"


# tmuxの自動起動
function is_exists() { type "$1" >/dev/null 2>&1; return $?; }
function is_osx() { [[ $OSTYPE == darwin* ]]; }
function is_screen_running() { [ ! -z "$STY" ]; }
function is_tmux_runnning() { [ ! -z "$TMUX" ]; }
function is_screen_or_tmux_running() { is_screen_running || is_tmux_runnning; }
function shell_has_started_interactively() { [ ! -z "$PS1" ]; }
function is_ssh_running() { [ ! -z "$SSH_CONECTION" ]; }

function tmux_automatically_attach_session()
{
    if is_screen_or_tmux_running; then
        ! is_exists 'tmux' && return 1

        if is_tmux_runnning; then
            echo "${fg_bold[red]} _____ __  __ _   ___  __ ${reset_color}"
            echo "${fg_bold[red]}|_   _|  \/  | | | \ \/ / ${reset_color}"
            echo "${fg_bold[red]}  | | | |\/| | | | |\  /  ${reset_color}"
            echo "${fg_bold[red]}  | | | |  | | |_| |/  \  ${reset_color}"
            echo "${fg_bold[red]}  |_| |_|  |_|\___//_/\_\ ${reset_color}"
        elif is_screen_running; then
            echo "This is on screen."
        fi
    else
        if shell_has_started_interactively && ! is_ssh_running; then
            if ! is_exists 'tmux'; then
                echo 'Error: tmux command not found' 2>&1
                return 1
            fi

            if tmux has-session >/dev/null 2>&1 && tmux list-sessions | grep -qE '.*]$'; then
                # detached session exists
                tmux list-sessions
                echo -n "Tmux: attach? (y/N/num) "
                read
                if [[ "$REPLY" =~ ^[Yy]$ ]] || [[ "$REPLY" == '' ]]; then
                    tmux attach-session
                    if [ $? -eq 0 ]; then
                        echo "$(tmux -V) attached session"
                        return 0
                    fi
                elif [[ "$REPLY" =~ ^[0-9]+$ ]]; then
                    tmux attach -t "$REPLY"
                    if [ $? -eq 0 ]; then
                        echo "$(tmux -V) attached session"
                        return 0
                    fi
                fi
            fi

            if is_osx && is_exists 'reattach-to-user-namespace'; then
                # on OS X force tmux's default command
                # to spawn a shell in the user's namespace
                tmux_config=$(cat $HOME/.tmux.conf <(echo 'set-option -g default-command "reattach-to-user-namespace -l $SHELL"'))
                tmux -f <(echo "$tmux_config") new-session && echo "$(tmux -V) created new session supported OS X"
            else
                tmux new-session && echo "tmux created new session"
            fi
        fi
    fi
}
tmux_automatically_attach_session

powerline-daemon -q
zsh /usr/local/lib/python2.7/site-packages/powerline/bindings/zsh/powerline.zsh
export PATH="/usr/local/sbin:$PATH"
eval "$(pyenv virtualenv-init -)"
