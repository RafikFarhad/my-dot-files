function homestead() {
    ( cd ~/Homestead && vagrant $* )
}

function enter() {
    ( docker exec -it $* bash )
}

alias vu='homestead up'
alias vs='homestead ssh'
alias vh='homestead halt'
alias vp='homestead reload --provision'

alias gss='git status'
alias ga='git add --all'
alias gc='git commit -S -m'
alias gcl='git clone'
alias gp='git push'
alias gpl='git pull'
alias gct='git checkout'

alias pp='cd ~/playground'
alias hh='cd ~/playground'
alias ii='cd ~/playground/infancy'
alias de='cd ~/Desktop'

alias cu='composer update'
alias pa='php artisan'
alias pacc='php artisan config:cache'
alias pakg='php artisan key:generate'

alias dcu='docker-compose up -d'
alias dcs='docker-compose stop'
alias dcd='docker-compose down'
alias dcl='docker-compose logs -f'
alias dps='docker ps'
alias dim='docker image'
alias dst='docker stop'
alias drm='docker rm'

alias start_='sudo bash ~/service_manager.sh start'
alias stop_='sudo bash ~/service_manager.sh stop'
alias reload_='sudo bash ~/service_manager.sh reload'
alias restart_='sudo bash ~/service_manager.sh restart'