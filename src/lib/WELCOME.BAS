' Welcome to Milix in ASCII with color and music

' Declare variables
DIM SHARED welcomeMessage$(100)

' Assign the welcome message
welcomeMessage$ = " _   _ _____ _____ _____ _   _ _____ _____ _____ _____ _____ _____ " & _
                  "| | | |_   _|_   _|_   _| \ | |_   _|_   _|_   _|_   _|_   _|  __ \ " & _
                  "| | | | | |   | |   | | |  \| | | |   | |   | |   | |   | | | |  | |" & _
                  "| | | | | |   | |   | | | . ` | | |   | |   | |   | |   | | | |  | |" & _
                  "| |_| |_| |_ _| |_ _| |_| |\  |_| |_ _| |_ _| |_ _| |_ _| |_| |__/ /" & _
                  " \___/ \___/ \___/ \___/\_| \_/\___/ \___/ \___/ \___/ \___/ \____/ "

' Set the text color to yellow
COLOR 14

' Print the welcome message
PRINT welcomeMessage$

' Reset the text color to white
COLOR 7

' Play a simple melody
SOUND 500, 100
SOUND 750, 100
SOUND 1000, 100
SOUND 750, 100
SOUND 500, 100
SOUND 250, 500

' Wait for user to press enter
INPUT "Press ENTER to continue..."
