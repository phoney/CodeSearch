# CodeSearch
Sample app that uses core data to allow searching for area code descriptions

The area code data comes from a csv file downloaded from 
http://www.nanpa.com/area_codes/index.html. The project parses the csv file and 
stores the content in a core data sqlite database. When the user types in a number or
state or country a query is run to find matches.

This project has two targets. One builds the sqlite database file and the other is the
normal target to build and run the code. A copy of the sqlite database file is in 
the project so the only reason to run the 'build database' target is if the csv file
changes or for curiousity. If you do wish to run the build database target you probably want to 
go to the Manage Schemes view and click the Autocreate Schemes Now button. This will
create a scheme called BuildDataStore. Choose that Scheme and run it in the Sim. It will 
run for a few seconds and then quit (it calls abort() when it's done). 
Copy the 'open /filepath' line at the end of
the debugger console and paste it into a Terminal window and hit return. This will open the 
Documents folder for the app in the Sim. You can then copy the CodeSearch.sqlite 
file from the Documents folder into the project folder. Then run the app normally and it will 
use the new database file.

##TODO

* Add the city name to the area code data. Would need to find a source of this info.
* Add support for other kinds of data like zip codes, country codes, etc.
