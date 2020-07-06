# ZSH - Tmux - Vim Config Files

## Installation

- Clone this repo
- Run `./deploy.sh`
- You are done! Just log out the terminal session nad log in again. 🎉


## Components
The automated script will install the following package and plugin: 

### ZSH
1. zsh-completions
2. zsh-syntax-highlighting
3. zsh-autosuggestions

### TMUX
1. tmux-plugins/tpm
2. tmux-plugins/tmux-battery
3. tmux-plugins/tmux-prefix-highlight
4. tmux-plugins/tmux-online-status
5. tmux-plugins/tmux-sidebar
6. tmux-plugins/tmux-copycat
7. tmux-plugins/tmux-yank
8. tmux-plugins/tmux-open
9. samoshkin/tmux-plugin-sysstat

### VIM
1. VundleVim/Vundle.vim
2. tpope/vim-fugitive
3. junegunn/fzf.vim
4. itchyny/lightline.vim
5. scrooloose/nerdtree
6. flazz/vim-colorschemes
7. joshdick/onedark.vim

### Others
1. oh-my-zsh
2. a hybrid `zsh-theme` based on `agnostar-zak`
3. a interactive prompt to make `zsh` as yur default shell


## Tested Platform
This repository is tested on following platforms:
- Arch/Linux
- Ubuntu Server
- macOS

## Update
You can update any of the package or library very easily by simply running `./deploy.sh`.