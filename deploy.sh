YELLOW="\033[93m"
RED="\033[91m"
NORMAL="\033[0m"
GREEN="\033[92m"
BLINK="\033[5m"

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
	echo "${YELLOW}Checking to see if $1 is installed $NORMAL"
	if ! [ -x "$(command -v $1)" ]; then
		prompt_install $1
	else
		echo "${GREEN}$1 is installed $NORMAL"
	fi
}

check_default_shell() {
	if [ -z "${SHELL##*zsh*}" ]; then
		echo "${GREEN}Default shell is zsh $NORMAL"
	else
		echo -n "Default shell is not zsh. Do you want to chsh -s \$(which zsh)? (y/n)"
		old_stty_cfg=$(stty -g)
		stty raw -echo
		answer=$(while ! head -c 1 | grep -i '[ny]'; do true; done)
		stty $old_stty_cfg && echo
		if echo "$answer" | grep -iq "^y"; then
			chsh -s $(which zsh)
		else
			echo "Warning: Your configuration won't work properly. If you exec zsh, it'll exec tmux which will exec your default shell which isn't zsh."
		fi
	fi
}

echo "The following task will be done:"
echo "⮕  Make sure that this device has zsh, vim and tmux installed"
echo "⮕  Try to install missing packages"
echo "⮕  Check the default shell and make the default shell to ZSH"
echo
echo "Let's get started? (y/n)"
old_stty_cfg=$(stty -g)
stty raw -echo
answer=$(while ! head -c 1 | grep -i '[ny]'; do true; done)
stty $old_stty_cfg
if echo "$answer" | grep -iq "^y"; then
	echo
else
	echo "Quitting, nothing was changed."
	exit 0
fi

check_for_software zsh
echo
check_for_software vim
echo
check_for_software tmux
echo

check_default_shell

echo
echo -n "Would you like to backup your current dotfiles? (y/n) "
old_stty_cfg=$(stty -g)
stty raw -echo
answer=$(while ! head -c 1 | grep -i '[ny]'; do true; done)
stty $old_stty_cfg
if echo "$answer" | grep -iq "^y"; then
	mv $HOME/.zshrc $HOME/.zshrc.old
	mv $HOME/.tmux.conf $HOME/.tmux.conf.old
	mv $HOME/.vimrc $HOME/.vimrc.old
else
	echo "\n${YELLOW}Not backing up old dotfiles $NORMAL"
fi

cp $(pwd)/legacy/.service_manager.sh $HOME
cp $(pwd)/legacy/.bash_aliases $HOME
cp $(pwd)/legacy/yank.sh $HOME/.tmux/

printf "source '$(pwd)/zshrc.conf' \nsource $HOME/.bash_aliases" >$HOME/.zshrc
printf "source $(pwd)/vimrc.vim" >$HOME/.vimrc
printf "source-file '$(pwd)/tmux.conf'" >$HOME/.tmux.conf

# Checking Tmux Plugin Manager
if [ ! -e "$HOME/.tmux/plugins/tpm" ]; then
	printf "WARNING: Cannot found TPM (Tmux Plugin Manager) \
 at default location: \$HOME/.tmux/plugins/tpm.\n"
	git clone https://github.com/tmux-plugins/tpm $HOME/.tmux/plugins/tpm
fi

# Install TPM plugins.
# TPM requires running tmux server, as soon as `tmux start-server` does not work
# create dump __noop session in detached mode, and kill it when plugins are installed
echo "Install TPM plugins\n"
tmux new -d -s __noop >/dev/null 2>&1 || true
tmux set-environment -g TMUX_PLUGIN_MANAGER_PATH "$HOME/.tmux/plugins"
"$HOME"/.tmux/plugins/tpm/bin/install_plugins || true
tmux kill-session -t __noop >/dev/null 2>&1 || true

echo "Installing ZSH Plugins"
if [ ! -d "$HOME/.oh-my-zsh/custom/plugins/zsh-completions" ]; then
	git clone https://github.com/zsh-users/zsh-completions $HOME/.oh-my-zsh/custom/plugins/zsh-completions
else
	echo "${GREEN}Updating ${YELLOW}zsh-completions ${GREEN}Plugin $NORMAL"
	cd "$HOME/.oh-my-zsh/custom/plugins/zsh-completions"
	git pull
fi
if [ ! -d $HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting ]; then
	git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
else
	echo "${GREEN}Updating ${YELLOW}zsh-syntax-highlighting ${GREEN}Plugin $NORMAL"
	cd "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting"
	git pull
fi

if [ ! -d $HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions ]; then
	git clone https://github.com/zsh-users/zsh-autosuggestions $HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions
else
	echo "${GREEN}Updating ${YELLOW}zsh-autosuggestions ${GREEN}Plugin $NORMAL"
	cd "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions"
	git pull
fi

echo
echo "${BLINK}${YELLOW}Please log out and log back in for default shell to be initialized $NORMAL"

# for clbg in {40..47} {100..107} 49 ; do
#         #Foreground
#         for clfg in {30..37} {90..97} 39 ; do
#                 #Formatting
#                 for attr in 0 1 2 4 5 7 ; do
#                         #Print the result
#                         echo -en "\e[${attr};${clbg};${clfg}m ^[${attr};${clbg};${clfg}m \e[0m"
#                 done
#                 echo #Newline
#         done
# done

