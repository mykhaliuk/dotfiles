# Transmission
# alias tss "~/scripts/transmission/stop_daemon.sh"
# alias tsd "~/scripts/transmission/start_daemon.sh"

# VLC Player
# alias vlc "/Applications/VLC.app/Contents/MacOS/VLC --intf=ncurses"

# DEV
# alias dev "yarn dev || yarn develop"
# alias start "yarn start"
# lalias startp "yarn start:preprod"

alias reload "source ~/.config/fish/config.fish"

## AWS
alias asl "aws sso login"
alias aslo "aws sso logout"

## Docker
alias ldk lazydocker
alias dk docker
alias dkc "docker container"
alias dki "docker image"
alias dkls "docker container ls"
alias dklsa "docker container ls -a"
alias dklsi "docker image ls"
alias dkup "docker compose up -d"
alias dkdwn "docker compose down"
alias dkrr "docker compose down && docker compose up -d"
alias dka "docker attach"


## FS ##
alias l 'ls -AhG'
alias quit exit
alias q exit
alias c clear

### TMUX ###
alias ta "tmux attach || tmux"

### Revdiff
alias rd "revdiff --compact --collapsed -o='./rdo.md'"
alias tre turboreview

### Claude-code
alias clc 'claude --continue --verbose'
alias clr 'claude --resume --verbose'
alias cla 'claude agents'
alias clp 'claude -p --model haiku'

### OPENCODE
# alias oc opencode
# alias occ "opencode --continue"
# alias ocr "opencode --session"

# Github cli
alias hs "hub sync"

# Git
# alias gbda 'git branch --no-color --merged | command grep -vE "^([+*]|\s*($(git_main_branch)|$(git_develop_branch))\s*$)" | command xargs git branch -d 2>/dev/null'

# Yarn
alias yversion "yarn version --no-git-tag-version --no-commit-hooks"

### OTHER ###

alias conf 'vim $HOME/.config/'
alias vim 'NVIM_APPNAME=LazyVim nvim'
alias dev 'bun run dev || npm run dev'
alias bst 'bun run start'
alias bstp 'bun run start:preprod'
alias yst 'yarn start'
alias ystp 'yarn start:preprod'

### GH Cli ###

alias ghp 'gh pr create -a @me'
alias ghpd 'gh pr create -B dev -a @me'

### GitLab CLI ###
alias gb glab
alias gbml 'glab mr list'

### GIT ###
alias 'gc!' 'git commit -v --amend'
alias ga 'git add'
alias gaa 'git add --all'
alias gba 'git branch -a'
alias gbd 'git branch -d'
alias gc 'git commit -v'
alias gcd 'git checkout dev'
alias ghr 'git reset --soft HEAD^'
alias gnb 'git nb'
alias grhc 'git reset --hard HEAD^'

### Git commits ###
alias gca 'git commit -v -a'
alias 'gca!' 'git commit -v -a --amend'
alias gcam 'git commit -v -a -m'
alias gcan 'git commit -v -a --amend --no-edit'
alias gcann 'git commit -v -a --amend --no-edit --no-verify'
alias gcf 'git commit -v --fixup'
alias gcfa 'git commit -v -a --fixup'
alias gcn 'git commit -v --amend --no-edit '
alias gcnn 'git commit -v --amend --no-edit --no-verify'

### Git Branches
alias gbD 'git branch -D'

alias gs 'git switch'
alias gsD 'git switch develop'
alias gsm 'git switch master'
alias gcb 'git checkout -b'
alias gsd 'git switch dev'
alias gsM 'git switch main'
alias gco 'git checkout'

### Git Stash
alias grba 'git rebase -i --autosquash'
alias gsta 'git stash push'
alias gstaa 'git stash apply'
alias gstall 'git stash --all'
alias gstam 'git stash push -m'
alias gstc 'git stash clear'
alias gstd 'git stash drop'
alias gstl 'git stash list'
alias gstp 'git stash pop'
alias gsts 'git stash show --text'

### Git other
alias gcfg 'git config --list'
alias gcp 'git cherry-pick'
alias gcpa 'git cherry-pick --abort'
alias gcpc 'git cherry-pick --continue'
alias gl 'git pull'
alias glo 'git log --oneline --decorate'
alias glog 'git log --oneline --decorate --graph'
alias gloga 'git log --oneline --decorate --graph --all'
alias glol 'git log --graph --pretty="%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ar) %C(bold blue)<%an>%Creset"'
alias glola 'git log --graph --pretty="%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ar) %C(bold blue)<%an>%Creset" --all'
alias glolam 'git log --author="mykhaliuk" --graph --pretty="%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ar) %C(bold blue)<%an>%Creset" --all'
alias gp 'git push'
alias gpf 'git push --force-with-lease'
alias gpu 'git push upstream'
alias gsb 'git status -sb'
alias gss 'git status -s'
alias gst 'git status'

# Yarn Upgrade
alias yu 'yarn upgrade'
