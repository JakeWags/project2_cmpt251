#!/bin/bash
DIR="todo"

# functions
list_items () {	
	echo "Current items in list:"
	if [ "$(ls -A $DIR)" ]; then
	COUNT=0
		for t in $DIR/*
		do
			COUNT=$((COUNT+1))
			echo "$COUNT. $(head -n 1 $t)"	
		done
	else
		echo "The list is empty."
	fi
}

list_options () {
	echo -e "\nWhat would you like to do?"
	# COUNT is a global variable by default
	echo "1-$COUNT. See more information on this item"
	echo "A. Mark an item as complete"
	echo "B. Add a new item"
	echo -e "C. See completed items\n"
	echo -e "Q. Quit\n"
}

read_input () {
	read -p "Enter your choice: " CHOICE
}

# Menu display
list_items
list_options
read_input
