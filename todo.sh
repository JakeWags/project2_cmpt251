#!/bin/bash

# Project 2, CMPT251
# Todo list, bash script
# Author: Jake Wagoner

# REQUIREMENTS
# DONE: must have functioning menu mode
# DONE: must have functioning command line mode
# DONE: must allow for spaces
# DONE: sorted list display
# DONE: all files only readable and writable to owner
# DONE: if in menu mode, wrong input displays error and menu again
# DONE: if in command line mode, wrong input displays help menu
# DONE: program structured into functions
# DONE: must use a public git repository

# colors for print formatting
YELLOW="\033[1;33m"
LCYAN="\033[1;36m"
NC="\033[0m"

# argument variables
a_num=$#
a1=$1
a2=$2
a3=$3
a4=$4
args=$@

# functions
# ------------
# initilization function
# checks for arguments and determines mode accordingly
# also counts items in completed list
init () {
	check_directories "todo" "todo_completed"
	check_stdin
	count_incomplete
	count_completed

	if [ $a_num -ne 0  ]; then
		menu_mode=0
		use_args
	else
		menu_mode=1
		display_menu
	fi
}

# checks is the user pipes information into the script (for add_item description)
check_stdin () {
	# if stdin has information
	if [ -p /dev/stdin ]; then
		PIPED_INPUT=$( cat )
	else
		PIPED_INPUT=""
	fi
}

# checks if directories exist and makes them if not
# takes $1 as directory 1 and $2 as directory 2
check_directories () {
	if [ ! -d "$1" ]; then
		mkdir "$1"
	fi

	if [ ! -d "$2" ]; then
		mkdir "$2"
	fi
}

# counts all items in todo list
count_incomplete () {
	# using ls -A [dir] allows us to check if the directory is empty
	# -A means display all hidden files (starting with .) other than '.' and '..' which are present in every folder
	if [ "$(ls -A todo)" ]; then
		COUNT=0
		for t in todo/*.txt
		do
			COUNT=$((COUNT+1))
		done
	fi
}

# counts items in the completed list
count_completed () {
	# using ls -A [dir] allows us to check if the directory is empty
	# -A means display all hidden files (starting with .) other than '.' and '..' which are present in every folder
	if [ "$(ls -A todo_completed)" ]; then
		C_ITEM_COUNT=0
		for t in todo_completed/*.txt
		do
			C_ITEM_COUNT=$((C_ITEM_COUNT+1))
		done
	fi
}

# uses arguments for command line mode
use_args () {
	if [[ "$a1" == "list" ]]; then
		if [[ "$a2" == "completed" ]]; then
			list_items "todo_completed"
		else
			list_items "todo"
		fi
	elif [[ "$a1" == "complete" ]]; then
		complete_item $((a2))
	elif [[ "$a1" == "add" ]]; then
		add_item "$a2" "$PIPED_INPUT"
	elif [[ "$a1" == "info" ]]; then
		more_info "$a2"
	else
		display_help
	fi
}

# displays help message
# COMMAND LINE ONLY
display_help () {
	echo -e "\n${LCYAN}-----------------------${NC}\n"
	echo -e "possible commands:\n"
	echo -e "${LCYAN}help${NC}: displays help message (this)"
	echo -e "${LCYAN}list${NC}: lists all items in the uncompleted todo list"
	echo -e "${LCYAN}complete ${YELLOW}[number]${NC}: completes the item of the chosen number"
	echo -e "${LCYAN}list completed${NC}: lists all items in the completed todo list"
	echo -e "${LCYAN}add ${YELLOW}[title]${NC}: adds an item with the given title to the todo list"
	echo -e "${LCYAN}add ${YELLOW}[title]${NC} cont.: information piped in is the description"
	echo -e "\n${LCYAN}-----------------------${NC}\n"
}

# list all items in the supplied directory
# takes $1 as directory to list items from
list_items () {
	echo -e "${LCYAN}----------------------${NC}"	
	echo "Current items in list:"
	if [ "$(ls -A $1)" ]; then
	COUNT=0
		for t in $1/*
		do
			COUNT=$((COUNT+1))
			# head -n 1 $t means the first line in the current file (title)
			echo -e "${YELLOW}$COUNT.${NC} $(head -n 1 $t)"	
		done
	else
		COUNT=0
		echo "The list is empty."
	fi
}

# list all menu options
# MENU MODE ONLY
list_options () {
	echo -e "\nWhat would you like to do?"
	# COUNT is a global variable by default
	echo "1-$COUNT. See more information on this item"
	echo "A. Mark an item as complete"
	echo "B. Add a new item"
	echo -e "C. See completed items\n"
	echo -e "Q. Quit\n"
}

# take user input and save it to CHOICE
# MENU MODE ONLY
read_input () {
	read -p "Enter your choice: " CHOICE
}

# prompt the user if they'd like to continue
# MENU MODE ONLY
cont () {
	read -p "Continue? (Y/N) " C 
	if [ $C == 'Y' ]; then
		display_menu
	else
		quit
	fi
}

# moves the selected item into todo_completed and adjusted filenames of the remaining files accordingly
complete_item () {
	# COMPLETE AN ITEM
	C=$1
	# If argument, C, is a number, less than or equal to the amount of items in list, and greater than 0
	if [[ $((C)) == $C ]] && [[ $C -le $COUNT ]] && [[ $C -gt 0 ]]; then
		C_ITEM_COUNT=$((C_ITEM_COUNT+1))
		COUNT=$((COUNT-1))
		cd todo
		i=0
		for f in *.txt; do
			i=$((i+1))
			# If current file number is the choice, move it
			if [[ $((i)) == $((C)) ]]; then
				mv "$C.txt" "../todo_completed/$C_ITEM_COUNT.txt"
			# If the current file number is greater than the choice, move it forward by 1
			elif [[ $i -gt $C ]]; then
				if [ $((i)) == 1 ]; then
					# j is the new filename value
					j=$((i))
				else
					j=$((i-1))
				fi
				# rename current file to new 'j' filename
				mv "$f" "$j.txt"
			fi	
		done
		cd ../
		if [[ $menu_mode == 1 ]]; then
			display_menu	
		fi
	else
		no_option_error
	fi
}

# adds an item to the todo list and assigns permissions accordingly
# takes $1 as title and $2 as description
add_item () {
	COUNT=$((COUNT+1))
	cd todo
	touch $COUNT.txt
	chmod 700 $COUNT.txt
	echo "$1" >> "$COUNT.txt"
	echo "------" >> "$COUNT.txt"
	echo "$2" >> "$COUNT.txt"	
	cd ../
	if [[ $menu_mode == 1 ]]; then
		display_menu
	fi
}

# outputs all file contents
# takes $1 as file to read
more_info () {
	if [[ $1 -gt 0 ]] && [[ $1 -le $COUNT ]]; then
		while IFS= read -r line
		do
			echo "$line"
		done < "todo/$1.txt"
		if [[ $menu_mode == 1 ]]; then
			cont
		fi
	elif [ $((COUNT)) == 0 ]; then
		list_empty_error
	else
		no_option_error
	fi
}

# Uses user input as $CHOICE and processes it accordingly
# MENU MODE ONLY
use_input () {
	if [ $CHOICE == 'A' ]; then
		# COMPLETE AN ITEM
		if [ $((COUNT)) -gt 0 ]; then
			list_items todo
			read -p "Which number? (1-$COUNT) " C
			complete_item $C
		else
			list_empty_error
		fi
	elif [ $CHOICE == 'B' ]; then
		# ADD AN ITEM
		read -p "Title? " TITLE
		read -p "Description? " DESC
		add_item "$TITLE" "$DESC"
	elif [ $CHOICE == 'C' ]; then
		# SHOW COMPLETED ITEMS
		list_items todo_completed
		cont
	elif [ $CHOICE == 'Q' ]; then
		# QUIT
		quit
	elif [ $((CHOICE)) == $CHOICE ]; then 
		# MORE INFORMATION ON LIST ITEM
		# If choice evaluates mathematically to itself, 
		# then it is a number value
		# if choice number is within range from count
		if [ $((CHOICE)) -le $COUNT ]; then
			more_info "$CHOICE"
		else
			no_option_error
		fi
	else
		# NO OPTION
		no_option_error
	fi
}

# Error for empty list
list_empty_error () {
	generic_error "list is empty"
}

# Error for invalid option selected
no_option_error () {
	generic_error "not an option"
}

# Formatting for error message and menu display
# Takes $1 as error message
generic_error () {
	echo "----------------"		
	echo -e "\n${LCYAN}ERROR:${NC} $1\n"
	echo "----------------"
	if [[ $menu_mode == 1 ]]; then
		display_menu
	else
		display_help
	fi
}

quit () {
	exit 1
}

# Calls all functions to display the menu and process it
# MENU MODE ONLY
display_menu () {
	list_items todo 
	list_options
	read_input
	use_input
}

# initialize the program
init
