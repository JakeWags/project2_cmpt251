# Project 2 : Computer Science 251
### Westminster College

### Author: Jake Wagoner

This is a todo list CLI with menu interface as well as command line arguement functionality.
This is solo work, but feel free to reference it and use it for anything. It should have full functionality on any linux/unix based system.

Written in bash as a shell script.


### Documentation:
To run after downloading, type the following command while in the directory it is located in:
`chmod +x todo.sh`

This makes the file runnable as an executable.

#### MENU MODE:
To run the script in menu mode, run the command without any arguments: `./todo.sh`

#### COMMANDS:
When arguments are provided, the script will run in command line mode.

_Possible commands:_

`help`: Displays the help message

`list`: Displays the itemized list of current items in the todo list

`list completed`: Displays the itemized list of current items in the completed todo list

`complete [number]`: Completes an item in the todo list. `[number]` is the item number to be completed

`add [title]`: Adds an item with the given `[title]` to the todo list. If data is piped in via stdin, this will become the description of the item

`info [number]`: Displays detailed information on todo list item `[number]`
