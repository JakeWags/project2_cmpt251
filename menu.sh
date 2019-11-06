#!/bin/bash

# functions
init () {
	if [ "$(ls -A todo_completed)" ]; then
		C_ITEM_COUNT=0
		for t in todo_completed/*
		do
			C_ITEM_COUNT=$((C_ITEM_COUNT+1))
		done
	fi
}

list_items () {
	echo "----------------------"	
	echo "Current items in list:"
	if [ "$(ls -A $1)" ]; then
	COUNT=0
		for t in $1/*
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

cont () {
	read -p "Continue? (Y/N) " C
	if [ $C == 'Y' ]; then
		display_menu
	else
		quit
	fi
}

complete_item () {
	# COMPLETE AN ITEM
	C=$1
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
					j=$((i))
				else
					j=$((i-1))
				fi
				mv "$f" "$j.txt"
			fi	
		done
		cd ../
		display_menu	
	else
		no_option_error
	fi
}

# TODO: FUNCTIONALIZE THESE TO TAKE ARGUMENTS FOR COMMAND LINE INTERFACE RATHER THAN JUST MENU
use_input () {
	if [ $CHOICE == 'A' ]; then
		if [ $((COUNT)) -gt 0 ]; then
			list_items todo
			read -p "Which number? (1-$COUNT) " C
			complete_item $C
		else
			list_empty_error
		fi
	elif [ $CHOICE == 'B' ]; then
		# ADD AN ITEM
		COUNT=$((COUNT+1))
		cd todo
		touch $COUNT.txt
		read -p "Title? " TITLE
		read -p "Description? " DESC
		echo "$TITLE" >> "$COUNT.txt"
		echo "------" >> "$COUNT.txt"
		echo "$DESC" >> "$COUNT.txt"	
		cd ../
		display_menu
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
		if [ $((CHOICE)) -le $COUNT ] && [ $((CHOICE)) -gt 0 ]; then
			while IFS= read -r line
			do
				echo "$line"
			done < "todo/$CHOICE.txt"
			cont
		elif [ $((COUNT)) == 0 ]; then
			list_empty_error
		else
			no_option_error
		fi
	else
		# NO OPTION
		no_option_error
	fi
}

list_empty_error () {
	generic_error "list is empty"
}

no_option_error () {
	generic_error "not an option"
}

generic_error () {
	echo "----------------"		
	echo -e "\nERROR: $1\n"
	echo "----------------"
	display_menu
}

quit () {
	exit 1
}

display_menu () {
	list_items todo 
	list_options
	read_input
	use_input
}

# Menu display
init
display_menu
