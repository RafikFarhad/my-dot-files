#!/bin/sh

YELLOW="\e[0;40;93m"
RED="\e[0;40;91m"
NORMAL="\e[0;40;0m"
GREEN="\e[0;40;92m"
ORANGE="\e[0;40;33m"
PURPLE="\e[0;40;96m"
BLINK="\e[0;40;5m"
DOT_FOLDER=""

dot_file_location() {
	read -p "Where should be the dot-files? (default: "$HOME/.my-dot-files") " INP
	DOT_FOLDER=${INP:-"$HOME/.my-dot-files"}
	if [[ "$DOT_FOLDER" == *"~"* ]]; then
		printf "${RED}\"~\" is not allowed${NORMAL}\n"
		exit 1
	fi
	if [[ "$DOT_FOLDER" == *"\$"* ]]; then
		printf "${RED}\"\$\" is not allowed${NORMAL}\n"
		exit 1
	fi
	# checking if a git folder
	if test -d $DOT_FOLDER/.git; then
		EXISTING_REPO_NAME=$(basename -s ".git" $(git -C "$DOT_FOLDER" config --get remote.origin.url))
		# checking if git repo is same as dot files
		if [ "$EXISTING_REPO_NAME" = "my-dot-files" ]; then
			printf "${YELLOW}Already cloned the dot files repo${NORMAL}\n"
			return
		else
			printf "${RED}Given folder is occupied with another git repository${NORMAL}\n"
			exit 1
		fi
	fi
	if test -d $DOT_FOLDER; then
		printf "${RED}Folder exists${NORMAL}\n"
		printf "${RED}Dot files location is occupied${NORMAL}\n"
		exit 1
	fi
}

clone_repo() {
	if ! test -d $DOT_FOLDER; then
		git clone https://github.com/RafikFarhad/my-dot-files.git $DOT_FOLDER
	else
		git -C $DOT_FOLDER pull
	fi
	cd $DOT_FOLDER
}

prompt_install() {
	echo -n "$1 is not installed. Would you like to install it? (y/n) " >&2
	old_stty_cfg=$(stty -g)
	stty raw -echo
	answer=$(while ! head -c 1 | grep -i '[ny]'; do true; done)
	stty $old_stty_cfg && echo
	if echo "$answer" | grep -iq "^y"; then
		# This could def use community support
		if [ -x "$(command -v apt-get)" ]; then
			sudo apt-get install $1 -y
		elif [ -x "$(command -v brew)" ]; then
			brew install $1
		elif [ -x "$(command -v pkg)" ]; then
			sudo pkg install $1
		elif [ -x "$(command -v pacman)" ]; then
			sudo pacman -S $1
		else
			echo "I'm not sure what your package manager is! Please install $1 on your own and run this deploy script again. Tests for package managers are in the deploy script you just ran starting at line 13. Feel free to make a pull request at https://github.com/parth/dotfiles :)"
		fi
	fi
}

check_for_software() {
	printf "${YELLOW}Checking to see if $1 is installed $NORMAL\n"
	if ! [ -x "$(command -v $1)" ]; then
		prompt_install $1
	else
		printf "${GREEN}$1 is installed $NORMAL\n"
	fi
}

check_default_shell() {
	if [ -z "${SHELL##*zsh*}" ]; then
		printf "${GREEN}Default shell is zsh $NORMAL\n"
	else
		chsh -s $(which zsh)
		if ! [ -z $? ]; then
			echo "${YELLOW}Warning: Your cdefault shell is not zsh and this script could not set zsh as your default shell$NORMAL"
		fi
	fi
}

backup_conf() {
	printf "${NORMAL}\n"
	read -p "Would you like to backup your current dotfiles? (yes/no) (default: no) " INP
	INP="${INP:-no}"
	if ! ([ "$INP" = "yes" ] || [ "$INP" = "YES" ]); then
		printf "${RED}Not backing up old dotfiles $NORMAL\n"
	else
		TIMESTAMP="$(date +%s)"
		mv $HOME/.zshrc $HOME/.zshrc.old.$TIMESTAMP
		mv $HOME/.tmux.conf $HOME/.tmux.conf.old.$TIMESTAMP
		mv $HOME/.vimrc $HOME/.vimrc.old.$TIMESTAMP
		printf "${GREEN}Backup created with suffix: ${TIMESTAMP}${NORMAL}\n"
	fi
}

configure_helpers() {
	# if ! test -f $HOME/service_manager.sh; then
	# 	ln -s -f $(pwd)/legacy/service_manager.sh $HOME
	# fi
	if ! test -f $HOME/.aliases; then
		ln -s -f $(pwd)/legacy/.aliases $HOME
	fi
	printf "${GREEN}Helpers configured${NORMAL}\n"
}

generate_conf() {
	printf "source $(pwd)/zshrc.conf\nsource $(pwd)/legacy/.aliases\n" >$HOME/.zshrc
	printf "source $(pwd)/vimrc.conf" >$HOME/.vimrc
	printf "source-file $(pwd)/tmux.conf" >$HOME/.tmux.conf
	printf "${GREEN}Conf file generated to: ${HOME}${NORMAL}\n"
}

tmux_plugin_setup() {
	# Checking Tmux Plugin Manager
	if ! test -d "$HOME/.tmux/plugins/tpm"; then
		printf "${YELLOW}WARNING: \"Tmux Plugin Manager\" not found\n"
		git clone https://github.com/tmux-plugins/tpm $HOME/.tmux/plugins/tpm
	fi

	# Install TPM plugins.
	# TPM requires running tmux server, as soon as `tmux start-server` does not work
	# create dump __noop session in detached mode, and kill it when plugins are installed
	printf "${PURPLE}Installing TPM plugins\n"
	printf "${ORANGE}"
	tmux new -d -s __noop >/dev/null 2>&1 || true
	tmux set-environment -g TMUX_PLUGIN_MANAGER_PATH "$HOME/.tmux/plugins"
	"$HOME"/.tmux/plugins/tpm/bin/install_plugins || true
	tmux kill-session -t __noop >/dev/null 2>&1 || true
	printf "${GREEN}Tmux plugin setup complete${NORMAL}\n"
}

zsh_plugin_setup() {
	printf "${PURPLE}Installing zsh plugins${NORMAL}\n"
	if ! test -d "$HOME/.oh-my-zsh"; then
		sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
	fi
	if ! test -d "$HOME/.oh-my-zsh/custom/plugins/zsh-completions"; then
		git clone https://github.com/zsh-users/zsh-completions $HOME/.oh-my-zsh/custom/plugins/zsh-completions
	else
		git -C "$HOME/.oh-my-zsh/custom/plugins/zsh-completions" pull
	fi
	if ! test -d $HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting; then
		git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
	else
		git -C "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting" pull
	fi
	if ! test -d $HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions; then
		git clone https://github.com/zsh-users/zsh-autosuggestions $HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions
	else
		git -C ""$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions"" pull
	fi
	printf "${GREEN}Zsh plugin setup complete${NORMAL}\n"
}

zsh_theme_setup() {
	for THEME in $(pwd)/themes/*; do
		ln -f -s "$THEME" "$HOME/.oh-my-zsh/custom/themes"
	done
}

vim_plugin_setup() {
	printf "${PURPLE}Installing vim plugins${NORMAL}\n"
	if ! test -d "$HOME/.vim/bundle/Vundle.vim"; then
		git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
	fi
	vim +PluginInstall +qall
	printf "${GREEN}Vim plugin setup complete${NORMAL}\n"
}

main() {
	printf "${YELLOW}Starting ${RED}Auto ${ORANGE}Environment ${PURPLE}Setup${NORMAL}\n"
	printf "${PURPLE}"
	echo "The following task will be done:"
	printf "${ORANGE}"
	echo "->  Make sure that this device has zsh, vim and tmux installed"
	echo "->  Try to install missing packages"
	echo "->  Make the default shell to ZSH"
	printf "${NORMAL}\n"
	read -p "Get started? (yes/no) (default: yes) " INP
	INP="${INP:-yes}"
	if ! ([ "$INP" = "yes" ] || [ "$INP" = "YES" ]); then
		echo "Quitting, nothing was changed."
		exit 0
	fi

	dot_file_location

	clone_repo

	check_for_software zsh

	check_for_software vim

	check_for_software tmux

	check_default_shell

	backup_conf

	configure_helpers

	generate_conf

	tmux_plugin_setup

	zsh_plugin_setup

	zsh_theme_setup

	vim_plugin_setup

	printf "${BLINK}${YELLOW}Log out and log back in to apply the new conf files$NORMAL\n"
}

main $@
# for clbg in {40..47} {100..107} 49 ; do
#         #Foreground
#         for clfg in {30..37} {90..97} 39 ; do
#                 #Formatting
#                 for attr in 0 1 2 4 5 7 ; do
#                         #Print the result
#                         printfn "^[0;40;${attr};${clbg};${clfg}m ^[${attr};${clbg};${clfg}m ^[0;40;0m"
#                 done
#                 echo #Newline
#         done
# done
