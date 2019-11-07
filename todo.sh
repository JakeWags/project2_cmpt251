#!/bin/bash

# Project 2, CMPT251
# Todo list, bash script
# Author: Jake Wagoner

# REQUIREMENTS
# DONE: must have functioning menu mode
# must have functioning command line mode
# DONE: must allow for spaces
# DONE: sorted list display
# DONE: all files only readable and writable to owner
# DONE: if in menu mode, wrong input displays error and menu again
# if in command line mode, wrong input displays help menu
# DONE: program structured into functions
# DONE: must use a public git repository

# functions
# initilization function
# checks for arguments and determines mode accordingly
# also counts items in completed list
init () {
	check_directories "todo" "todo_completed"
	count_completed
	
	echo "$?" "arguments"
	display_menu
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

# list all items in the supplied directory
# takes $1 as directory to list items from
list_items () {
	echo "----------------------"	
	echo "Current items in list:"
	if [ "$(ls -A $1)" ]; then
	COUNT=0
		for t in $1/*
		do
			COUNT=$((COUNT+1))
			# head -n 1 $t means the first line in the current file (title)
			echo "$COUNT. $(head -n 1 $t)"	
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
	if [ $((C)) == $C ] && [ $C -le $COUNT ] && [ $C -gt 0 ]; then
		C_ITEM_COUNT=$((C_ITEM_COUNT+1))
		COUNT=$((COUNT-1))
		cd todo
		i=0
		for f in *.txt; do
			i=$((i+1))
			# If current file number is the choice, move it
			if [ $((i)) == $((C)) ]; then
				mv "$C.txt" "../todo_completed/$C_ITEM_COUNT.txt"
			# If the current file number is greater than the choice, move it forward by 1
			elif [ $i -gt $C ]; then
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
		display_menu	
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
	display_menu
}

# outputs all file contents
# takes $1 as file to read
more_info () {
	if [ $((CHOICE)) -gt 0 ]; then		
		while IFS= read -r line
		do
			echo "$line"
		done < "todo/$1"
		cont
	elif [ $((COUNT)) == 0 ]; then
		list_empty_error
	fi
}

# TODO: FUNCTIONALIZE THESE TO TAKE ARGUMENTS FOR COMMAND LINE INTERFACE RATHER THAN JUST MENU
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
			more_info "$CHOICE.txt"
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
	echo -e "\nERROR: $1\n"
	echo "----------------"
	display_menu
}

# Exit the program
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
