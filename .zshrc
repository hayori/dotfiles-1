#パスを通す
export PATH="/usr/bin:$PATH"
export PATH="/usr/local/bin:$PATH"
export DOTSDIR=${HOME}/dotfiles
# NUTFes/group_managerに必要な環境変数を設定
source "$HOME/dotfiles/group_manager.sh"
# rbenvのパス
export PATH="$HOME/.rbenv/bin:$HOME/.rbenv/shims:$PATH"
#rbenvの初期化設定
if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi

# bindkey
bindkey -r '^H'
bindkey -r '^J'
bindkey -r '^K'
bindkey -r '^L'
bindkey -r '^_'
bindkey -r '^\'
#Railsコマンドの補完
fpath=($(brew --prefix)/share/zsh-completions $fpath)
# gitコマンドの補完
fpath=($(brew --prefix)/share/zsh/site-functions $fpath)
# 補完機能を有効にする
autoload -Uz compinit
compinit -u
#補完候補を一覧で表示する
setopt auto_list
#補完キー連打で補完候補を順に表示する
setopt auto_menu
# =以降も補完する
setopt magic_equal_subst
#Shift-Yabで補完候補を逆順する
bindkey "^[[Z" reverse-menu-complete"]]"
#補完時に大文字小文字を区別しない
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
#キーバインドをvimライクにする
bindkey -v
#色を出力できるようにする
autoload colors
colors
##プロンプトの表示毎にプロンプト文字列を再評価
setopt prompt_subst 
# PROMPTを表示
function zle-line-init zle-keymap-select {
  set_prompt
  zle && zle reset-prompt #プロンプト再描画
  echo #reset-promptすると1行上にずれるのでechoで調整
}
zle -N zle-line-init
zle -N zle-keymap-select

#zshのviモードをPROMPTに表示
function vi_mode_prompt(){
local color mode #ローカル変数宣言
case $KEYMAP in
  vicmd)
    color=${fg[green]}
    mode='nor'
    ;;
  main|viins)
    color=${fg[cyan]}
    mode='ins'
    ;;
esac
echo "$color$mode$reset_color"
}
#promptを書く
function set_prompt(){
PROMPT="
[%n:$(vi_mode_prompt)] %{$fg_bold[yellow]%} %~%{$reset_color%}
$ "
PROMPT2=$PROMPT
RPROMPT="%1(v|%F{green}%1v%f|)"
}
#RPROMPTにgit branchを表示させる
autoload -Uz vcs_info
zstyle ':vcs_info:*' formats '[%b]'
zstyle ':vcs_info:*' actionformats '[%b]'
precmd(){
  psvar=()
  LANG=en_US.UTF-8 vcs_info 
  [[ -n "$vcs_info_msg_0_" ]] && psvar[1]="$vcs_info_msg_0_"
}
#コマンド実行時に右プロンプトを消す# cd - で１つ前にいたディレクトリに移動
setopt transient_rprompt 
#補完の時プロンプトの位置を変えない
setopt always_last_prompt 
#cd tabキーで過去に移動したディレクトリを表示
setopt auto_pushd

# cd - で１つ前にいたディレクトリに移動
setopt auto_pushd
# 重複したディレクトリを追加しない
setopt pushd_ignore_dups
# ディレクトリ名だけでcd
setopt AUTO_CD
#j+ディレクトリ名(一部)でディレクトリにジャンプ
if [ -f `brew --prefix`/etc/autojump ]; then
  .`brew --prefix`/etc/autojump
fi
#コマンドのスペルを訂正する
setopt correct
# lsコマンドの色設定
export LSCOLORS=gxfxcxdxbxegedabagacad
#その他とりあえずいるもの
export LANG=ja_JP.UTF-8
# 日本語ファイル名を表示可能にする
setopt print_eight_bit
# フローコントロールを無効にする
setopt no_flow_control
# '#' 以降をコメントとして扱う
setopt interactive_comments
#------------------------------------
# グローバルエイリアス
alias -g L='| less'
alias -g G='| grep'
alias ls='ls -GF'
alias -g curl='curl -tlsv1'
alias -g pyg='pygmentize'
alias j="autojump"
alias -g afp='afplay -q 1'


#--------- ヒストリの設定 ---------
source ~/zaw/zaw.zsh #zawと呼ばれるプラグイン
#ヒストリの保存場所
HISTFILE=~/.zsh_history
HISTSIZE=1000000
SAVEHIST=1000000
function mkcd(){mkdir -p $1 && cd $1}
# ヒストリに追加されるコマンド行が古いものと同じなら古いものを削除
setopt hist_ignore_all_dups
# spaceで始まるコマンド行はヒストリから削除
setopt hist_ignore_space
# 余分な空白は詰めて記録
setopt hist_reduce_blanks
# 同じコマンドは無視
setopt hist_save_no_dups
# historyコマンドは履歴に登録しない
setopt hist_no_store
# 補完時にヒストリを自動的に展開
setopt hist_expand
# 履歴をインクリメンタルに追加
setopt inc_append_history
# ヒストリを呼び出してから実行する間に一旦編集可能
setopt hist_verify
# 高機能なワイルドカード展開を使用する
setopt extended_glob

#history一覧の表示
zle -N zaw-history
zle -N history-beginning-search-backward
zle -N history-beginning-search-forward
bindkey '^G' zaw-history
bindkey '^P' history-beginning-search-backward
bindkey '^N' history-beginning-search-forward

#------------------------------------
# tmuxのsession一覧を追加
zle -N zaw-tmux
bindkey '^t' zaw-tmux

#--------------------------------------
# ネットワークプロキシの設定
source "$DOTSDIR/set_proxy_by_dns.sh"
# export http_proxy=http://proxy.nagaokaut.ac.jp:8080
# export http_proxy=""
# export https_proxy=$http_proxy
# export all_proxy=$http_proxy
# export use_proxy=yes
# git config --global http.proxy proxy.nagaokaut.ac.jp:8080
# git config --global https.proxy proxy.nagaokaut.ac.jp:8080

#####################  git 機能 ########################
#何も入力せずenterで ls, git status, git branch
function do_enter() {
if [ -n "$BUFFER" ]; then
  zle accept-line
  return 0
fi
echo
ls -a
echo -e "\e[0;33m--- git branch ---\e[0m"
git branch
echo -e "\e[0;33m--- git status ---\e[0m"
git status -sb
if [ "$(git rev-parse --is-inside-work-tree 2> /dev/null)" = 'true' ]; then
  git status -sb
fi
zle reset-prompt
return 0
}
zle -N do_enter
bindkey '^m' do_enter

#hubコマンドをgitコマンドとしてエイリアス(hubはgitの拡張ライブラリ)
eval "$(hub alias -s)"

#postgresqlのパス設定
export PGDATA=/usr/local/var/postgres

# twitterと接続するために暗号キーを環境変数に書くscript
# source $HOME/dotfiles/bin/twitter_authentication.sh

# pryをirbと置き換える
alias irb='pry'
