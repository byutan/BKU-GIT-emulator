install_bku()
{
	echo "Checking dependencies..."
	dependencies=("diff" "cron")
	for cmd in "${dependencies[@]}"
	do
		if ! command -v "$cmd" &>/dev/null
		then
			missing+=("$cmd")
		fi
	done
	if [ "${#missing[@]}" -gt 0 ]
	then
		if command -v apt &>/dev/null
		then
			sudo apt install -y "${missing[@]}"
		elif command -v yum &>dev/null
		then
			sudo yum install -y "${missing[@]}"
		elif command -v brew &>dev/null
        then
            sudo install "${missing[@]}"
		else
			exit 1
		fi
		for cmd in "${missing[@]}"; do
            if ! command -v "$cmd" &>/dev/null; then
                echo "Error: Failed to install packages. Please check your package manager or install them manually."
                exit 1
            fi
        done
	fi
	echo "All dependencies installed."
	#bku_path=$(find / -type f -name "bku.sh" 2>/dev/null | head -n 1)
	sudo cp bku.sh /usr/local/bin/bku
    sudo chmod +x /usr/local/bin/bku
    if command -v bku &>/dev/null; then
        echo "BKU installed to /usr/local/bin/bku."
    else
        exit 1
    fi

}

uninstall_bku()
{
	echo "Checking BKU installation..."
	if [ ! -f "/usr/local/bin/bku" ] 
	then
		echo "Error: BKU is not installed in /usr/local/bin/bku."
		echo "Nothing to install"
		exit 1
	fi
	echo "Removing BKU from /usr/local/bin/bku..."
	sudo rm -f /usr/local/bin/bku
	sudo rm -rf .bku 
	echo "Removing scheduled backups..."
	crontab -l 2>/dev/null | grep -v "bku.sh" | crontab -
	echo "BKU successfully uninstalled."
}

if [ "$1" = "--install" ]
then
	install_bku
elif [ "$1" = "--uninstall" ]
then
	uninstall_bku
fi
