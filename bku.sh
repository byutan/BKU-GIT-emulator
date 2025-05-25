#!/bin/bash
init() 
{
	if [ ! -d .bku ]
	then
		mkdir .bku
		mkdir .bku/tracked_files
		mkdir .bku/diff
		touch .bku/history.log
		echo "Backup initialized."
		commit_id=$(date +"%H:%M-%d/%m/%Y")
		message="BKU Init."
		printf "$commit_id: $message\n" >> .bku/history.log
	else
		echo "Error: Backup already initialized in this folder."
	fi
}

check_root()
{
	if [ ! -d "$PWD/.bku" ]
	then
		echo "Must be BKU root folder."
		exit 1
	fi
}

add()
{
	check_root
	file_path="$1"
	# If file path exists.
	if [ -f "$file_path" ]
	then
		add_single_file "$file_path"
	# If file path is not provided.
	elif [ -z "$file_path" ]
	then
		add_all_file
	# If file path does not exist.
	else
		echo "Error: $file_path does not exist." | awk '{gsub("^\\./", "", $2); print $1, $2, $3, $4, $5}'
	fi
}

add_single_file()
{
	file_path="$1"
	file_name=$(basename "$file_path")
	found=false
	# Check if there is a file with the same name.
	for file in ".bku/tracked_files"/*
	do
		# If there is a file with the same name, throw error.
		if [ -e "$file" ] && [ "$file_name" = "$(basename "$file")" ]
		then
			echo "Error: $file_path is already tracked." | awk '{gsub("^\\./", "", $2); print $1, $2, $3, $4, $5}'
			exit 1
		fi
	done
	# If not, copy the file and paste into .bku/tracked_files folder.
	cp "$file_path" ".bku/tracked_files"
	echo "Added $file_path to backup tracking." | awk '{gsub("^\\./", "", $2); print $1, $2, $3, $4, $5}'
}

add_all_file()
{
	# For every file except .bku folder.
	find . -mindepth 1 -not -path "./.bku/*" -type f | while read file_path
	do
		file_name=$(basename "$file_path")
		# Flag variable for checking.
		found=false
		# Check if there is a file with the same name.
		for file in ".bku/tracked_files"/*
		do
			# If there is a file with the same name, throw error.
			if [ -e "$file" ] && [ "$file_name" = "$(basename "$file")" ]
			then
				echo "Error: $file_path is already tracked." | awk '{gsub("^\\./", "", $2); print $1, $2, $3, $4, $5}'
				found=true
				break
			fi
		done
		# If not found, copy the file and paste into .bku/tracked_files folder.
		if [ "$found" = "false" ]
		then
			cp "$file_path" ".bku/tracked_files"
    		echo "Added $file_path to backup tracking." | awk '{gsub("^\\./", "", $2); print $1, $2, $3, $4, $5}'
		fi
	done
}

status()
{
	check_root
	file_path="$1"
	# If file path exists.
	if [ -f "$file_path" ]
	then
		status_single_file "$file_path"
	# If file path is not provided.
	elif [ -z "$file_path" ]
	then
		status_all_file
	# If file path does not exist.
    else
        echo "Error: $file_path does not exist." | awk '{gsub("^\\./", "", $2); print $1, $2, $3, $4, $5}'
    fi
}

status_single_file()
{
	if [ -z "$(ls -A ".bku/tracked_files")" ]
	then
		echo "Error: Nothing has been tracked."
		exit 1
  	fi
	file_path="$1"
	# Flag variable for checking.
	found=false
	file_name=$(basename "$file_path")
	# Check if there is a file with the same name.
	for file in ".bku/tracked_files"/*
	do
		# If there is a commited file with the same name.
		if [ -e "$file" ] && [ "$file_name" = "$(basename "$file")" ]
		then
			found=true
		fi
		# If there is no changes between two files.
		if [ "$found" = "true" ] && diff -q "$file" "$file_path" > /dev/null
		then
			#parent_dir=$(basename "$(dirname "$file_path")")
            		#formatted_file="$parent_dir/$file_name"
           		#echo "$formatted_file: No changes"
           		echo "$file_path: No changes"
			exit 0
		# If there are changes between two files.
		elif [ "$found" = "true" ] && ! diff -q "$file" "$file_path" > /dev/null
		then
			parent_dir=$(basename "$(dirname "$file_path")")
            		formatted_file="$parent_dir/$file_name"
            		diff -u "$file" "$file_path" | sed -e "1s|^--- .*$|$formatted_file:|; 2d;"
			exit 0
		fi
	done
	# If the commited version of the file is not found, throw error.
	if [ "$found" = "false" ]
    then
		echo "Error: $file_path is not tracked." | awk '{gsub("^\\./", "", $2); print $1, $2, $3, $4, $5}'
		exit 1
    fi
}

status_all_file()
{
	# If tracked_files folder contains no commited version of any file, throw error.
	if [ -z "$(ls -A ".bku/tracked_files")" ]
	then
		echo "Error: Nothing has been tracked."
		exit 1
	# If tracked_files folder contains some commited version of files.
	else
		find . -mindepth 1 -not -path "./.bku/*" -type f | while read file_path
		do
			file_name=$(basename "$file_path")
			# Flag variable for checking,
			found=false
			# Check if there is a file with the same name.
			for file in ".bku/tracked_files"/*
			do
				# If there is a commited file with the same name.
				if [ -e "$file" ] && [ "$file_name" = "$(basename "$file")" ]
				then
					found=true
				fi
				# If there is no changes between two files.
				if [ "$found" = "true" ] && diff -q "$file" "$file_path" > /dev/null
				then
					parent_dir=$(basename "$(dirname "$file_path")")
					formatted_file="$parent_dir/$file_name"
					echo "$formatted_file: No changes."
					break
				# If there are changes between two files.
				elif [ "$found" = "true" ] && ! diff -q "$file" "$file_path" > /dev/null
				then
					parent_dir=$(basename "$(dirname "$file_path")")
                    formatted_file="$parent_dir/$file_name"
					diff -u "$file" "$file_path" | sed -e "1s|^--- .*$|$formatted_file:|; 2d;"
					break
				fi
			done
			# If the commited version of the file is not found, throw error.
			if [ "$found" = "false" ]
			then
				echo "Error: $file_path is not tracked." | awk '{gsub("^\\./", "", $2); print $1, $2, $3, $4, $5}'
			fi
		done
	fi
}

commit()
{
    check_root
    message="$1"
    file_path="$2"
    # If there is no message or the message itself is the second argument.
    if [ -z "$message" ] || [ -f "$message" ]
    then
        echo "Error: Commit message is required."
        exit 1
    # If there is not file from the last commit, throw error.
    elif [ -z "$(ls -A ".bku/tracked_files")" ]
    then
        echo "Error: No change to commit."
        exit 1
    # If commit message is provided and file path exists.
    elif [ -f "$file_path" ]
    then
        commit_single_file "$message" "$file_path"
    elif [ -z "$file_path" ]
    then
        commit_all_file "$message"
    fi
}


commit_single_file()
{
    message="$1"
    file_path="$2"
    # Flag variable for checking
    found=false
    file_name=$(basename "$file_path")
    for file in ".bku/tracked_files"/*
    do
        # If the commited version exists
        if [ -e "$file" ] && [ "$file_name" = "$(basename "$file")" ]
        then
            found=true
        fi
        # If there is no changes between two files.
        if [ "$found" = "true" ] && diff -q "$file" "$file_path" > /dev/null
        then
            echo "Error: No change to commit."
            exit 1
        # If there are changes between two files.
        elif [ "$found" = "true" ] && ! diff -q "$file" "$file_path" > /dev/null
        then
            # Save changes into a diff file.
            save_diff "$file" "$file_path"
            # Log date and message into history.log and print to terminal.
            save_log "$message" "$file_path"
            commit_id=$(date +"%H:%M-%d/%m/%Y")
            echo "Committed $file_path with ID $commit_id." | awk '{gsub("^\\./", "", $2); print $1, $2, $3, $4, $5}'
            exit 0
        fi
    done
}


commit_all_file()
{
    message="$1"
    # Create a list of changed files to log.
	file_list=()
	for file_pwd in $(find . -type f ! -path "./.bku/*")
    do
        file_name=$(basename "$file_pwd")
        # Flag variable for checking.
        found=false
        for file in ".bku/tracked_files"/*
        do
            # If the commited version exists.
            if [ -e "$file" ] && [ "$file_name" = "$(basename "$file")" ]
            then
                found=true
            fi
            # If there is no changes between two files.
            if [ "$found" = "true" ] && diff -q "$file" "$file_pwd" > /dev/null
            then
                break
            # If there are changes between two files.
            elif [ "$found" = "true" ] && ! diff -q "$file" "$file_pwd" > /dev/null
            then
                # Saving changes into diff file.
                save_diff "$file" "$file_pwd"
                # Print to terminal
                commit_id=$(date +"%H:%M-%d/%m/%Y")
				# Added changed file to the list
				file_list+=("${file_pwd#./}")
                echo "Committed $file_pwd with ID $commit_id." | awk '{gsub("^\\./", "", $2); print $1, $2, $3, $4, $5}'
                break
            fi
        done
    done
    # Adding commas into the string.
    file_str="${file_list[*]}"
    file_str="${file_str// /,}"
    # Log date and message into history.log
    save_log "$message" "$file_str"
}


save_log()
{
    message="$1"
    file="$2"
    # Create commit id.
    commit_id=$(date +"%H:%M-%d/%m/%Y")
    printf "%s: %s (%s). \n" "$commit_id" "$message" "$file" >> ".bku/history.log"
}


save_diff()
{
    file="$1"
    file_path="$2"
    file_name=$(basename "$file_path")
    # if there is not diff file, create one and save changes.
    if [ ! -e ".bku/diff/$file_name.diff" ]
    then
        touch ".bku/diff/$file_name.diff"
    fi
    # Save changes into diff file.
    diff -u "$file" "$file_path" > ".bku/diff/$file_name.diff"
}

history()
{
	check_root
	init_line=$(head -n 1 ".bku/history.log")
	tail -n +2 ".bku/history.log"
	echo "$init_line"
}

restore()
{
	check_root
	# If file path is provided
	file_path="$1"
	# If there is no diff file.
	if [ -z "$(ls -A ".bku/diff")" ]
	then
		echo "Error: No file to be restored."
		exit 1
	elif [ -f "$file_path" ]
	then
		restore_single_file "$file_path"
	elif [ -z "$file_path" ]
	then
		restore_all_file
	else
		echo "Error: $file_path does not exist." | awk '{gsub("^\\./", "", $2); print $1, $2, $3, $4, $5}'
		exit 1
	fi
}

restore_all_file()
{
	for file_pwd in $(find . -type f ! -path "./.bku/*")
    do
        file_name=$(basename "$file_pwd")
		if [ -e ".bku/diff/$file_name.diff" ]
		then
			patch -s -R "$file_pwd" < ".bku/diff/$file_name.diff"
			echo "Restored $file_path to its previous version." | awk '{gsub("^\\./", "", $2); print $1, $2, $3, $4, $5}'
		else
			echo "Error: No previous version available for $file_pwd" | awk '{gsub("^\\./", "", $2); print $1, $2, $3, $4, $5}'
		fi
	done
}

restore_single_file()
{
	file_path="$1"
	file_name=$(basename "$file_path")
	# If there is a diff for the file.
	if [ -e ".bku/diff/$file_name.diff" ]
	then
		patch -s -R "$file_path" < ".bku/diff/$file_name.diff"
		echo "Restored $file_path to its previous version." 
		exit 0
	# If there is not diff for the file.
	else
		echo "Error: No previous version available for $file_path" 
		exit 1
	fi
}

schedule()
{
	check_root
    case "$1" in
    --daily)
		cron="0 0 * * * $(pwd)/bku.sh commit \"Scheduled backup\""
		echo "Scheduled daily backups at daily."
		;;
    --hourly)
		cron="0 * * * * $(pwd)/bku.sh commit \"Scheduled backup\""
		echo "Scheduled hourly backups at hourly."
		;;
    --weekly)
		cron="0 0 * * 0 $(pwd)/bku.sh commit \"Scheduled backup\""
		echo "Scheduled weekly backups at weekly."
		;;
    --off)
        crontab -l 2>/dev/null | grep -v "bku.sh" | crontab -
       	echo "Backup scheduling disabled."
      	return 0
       	;;
	*)
		echo "Error: Invalid option. Use --daily, --hourly, --weekly, or --off."
		return 1
		;;
	esac
	(crontab -l 2>/dev/null | grep -v "bku.sh"; echo "$cron") | crontab -
}


stop()
{
	check_root
    if [ ! -d .bku ]
    then
        echo "Error: No backup system to be removed."
    else
        rm -r .bku
        crontab -l 2>/dev/null | grep -v "bku.sh" | crontab -
        echo "Backup system removed."
    fi
}

manual()
{
	echo "bku init: initialise backup folder .bku"
	echo "bku add (file_path): track the target file."
	echo "bku add: track all files in current working directory."
	echo "bku status (file_path): show target file's latest changes."
	echo "bku status: show files's latest changes after tracked."
	echo "bku commit (message) (filepath): commit changes on the target file."
	echo "bku commit (message): commit changes on all of the changed files in current working directory."
	echo "bku restore (file_path): revert target to it latest changed commit."
	echo "bku restore: revert all files to their latest changed commit in current working directory."
	echo "bku schedule: schedule auto commit hourly, daily, weekly."
	echo "bku stop: remove all of tool's backup system."
}

if [ "$1" = init ]
then
	init
elif [ "$1" = add ]
then
	add "$2"
elif [ "$1" = status ]
then
	status "$2"
elif [ "$1" = commit ]
then
	commit "$2" "$3"
elif [ "$1" = history ]
then
	history
elif [ "$1" = restore ]
then
	restore "$2"
elif [ "$1" = schedule ]
then
	schedule "$2"
elif [ "$1" = stop ]
then
	stop
else
	manual
fi
