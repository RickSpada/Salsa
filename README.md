# Salsify Coding Exercise

## Salsa Line Server
The *Salsa Line Server* is a system that serves lines out of a file to network clients.

## Requirements
Ruby version 2.2.2 or later is required for *Salsa*

## Building
Run the build.sh script to build Salsa on your host machine.

## Usage
The run.sh script accepts a single command line parameter, the name of the file that **Salsa** is to serve.

Other command line options to run.sh include:

-f | --file FILE_NAME
Set the Salsa file to serve to FILE_NAME.  If the **Salsa** server is not running, it will be started.

-l | --line LINE_NO
Request a line from **Salsa**.  If the **Salsa** server is not running, it will be started.

-k | --kill
Shutdown the **Salsa** server.

**Note:** At the time of this writing, **Salsa** sometimes will not run due to a "Connection refused" error.  The problem hasn't been repeatable enough for me to debug and fix.  My suggestion is to try running **Salsa** again.

## Controllers / Endpoints
### POST /file?file_name=FILE_NAME
This endpoint instructs *Salsa* to serve up a new file, `FILE_NAME`.  When called with a valid filename, *Salsa* will read in the file, line by line, creating `SalsaLine` objects for each line.  Upon completion, the `SalsaFile` singleton is updated with the new file and number of lines in the file.

Upon completion the controller returns to the caller in a JSON payload the number of lines in the file and status of 200.

If an error occurs, an error message is returned with a status of 400.

### GET /lines?line_number=LINE_NUMBER
This endpoint requests a line, `LINE_NUMBER` from *Salsa*.  If the line is within the range of the file (1 to num_lines), the line is returned to the caller in a JSON payload with a status of 200.  If the line number is out of bounds, an error message is returned with a status of 413.

## System Models
There are two models that comprise the Salsa server, the **SalsaFile** and the **SalsaLine**.

### SalsaFile
The **SalsaFile** is a Singleton that has two primary attributes, the `file_name` and `line_count`.  The `file_name` contains the name of the file being served up by **Salsa** and the `line_count` contains the number of lines in the file.

As mentioned, this construct is a Singleton as there can only be one **Salsa** file being served up at a time.

### SalsaLine
The **SalsaLine** contains a single line from the **Salsa** file.  The two attributes of interest are the `line_no` and `text`.  The `line_no` as it sounds is the line number in the **Salsa** file and `text` is the text at that line.

## How the system works
When the *Salsa* `/file` endpoint is called to set or change the file being served the system responds by:

1. Deleting all existing **SalsaLine** objects.
2. Reading in the file line by line, creating new `**SalsaLine** objects, one per line.

Upon reading in the file, the **SalsaFile** singleton is updated with the new file name and number of lines in the file.

When the `/lines` endpoint is called, *Salsa* responds by:

1. Checking that the line number is within bounds (i.e., less than or equal to the `line_count` stored in the **SalsaFile** singleton).  If not within bounds, an error is returned.
2. Performing an **ActiveRecord** query to find the **SalsaLine** with the specified line number.

## How will the system perform with a 1GB file? a 10 GB file? a 100 GB file?
The key algorithmic components in the system are:

1. Reading in the file
2. Creating a **SalsaLine** object for each line
3. Searching for a **SalsaLine** given a line number

Reading in a file, line by line, is of complexity O(n) where `n` is the size of the file, meaning that reading the file will increase linearly with the size of the file.

I'll assume that there's little to no cost of creating a **SalsaLine** and that there's sufficient memory to create them given any file size.

Depending upon whether the database is indexed or not, the complexity for searching for a single **SalsaLine** object is O(long n) (indexed) or O(n) (non-indexed).

Assuming an indexed database, then as the file size increases towards infinity, the O(n) components will dominate, yielding a system with O(n) complexity.

In summary, as the file size increases, the time to read in the file and to locate a single line increases linearly.

## How will the system perform with 100 users?  10000 users?  1000000 users?
Since the system stores only one set of data that is shared amongst all users, the performance should be good regardless of the number of users.  As there is thread safety built into the `Lines::Get` class that retrieves a line of text, there would be no performance penalty in servicing multiple users, other than that which is involved in instantiating a `Lines::Get` object (pretty small). 

## What documention, websites, papers etc did you consult in doing this assignment.
The primary sources of information that I consulted were **Stack Overflow** and online *Rails* documentation.

## What third-party-librarys or other tools does the system use?  How did you choose each library or framework you used?
1. Ruby on Rails - I chose RoR because of the framework it provides for building a web app.
2. Launchy - Launchy provides methods to open a web-site from within Ruby.  I used this capability to launch each **Salsa** instance. 
3. HTTParty - HTTParty provides methods to call a server endpoint.  I used this in order to request a line from **Salsa** from a shell prompt.

## How long did you spend on this exercise?  If you had unlimited more time to spend on this, how would you spend it and how would you prioritize each item?
The primary effort for coding up **Salsa** took approximately 20 hours to get the overall functionality working, with the time broken up as:

1. 4 hours foundation - setting up the Rails app, writing run.sh, run.rb
2. 4 hours model and endpoints
3. 6 hours on the UI - I've only worked on the backend of web apps, so writing front end involved a little bit extra in terms of learning.
4. 3 hours debugging
5. 2 hours documentation
6. 1 hour miscellaneous

The durations above include not only coding, but also consulting documentation, websites, etc.

If there were unlimited time to spend I would do the following (highest priority first):

* Writing unit tests
* Performance analysis and tuning
* UI Enhancements
  * Put the name of the file served in the UI
  * Put the line of text on the same line as the label
* There is one bug which in which sometimes even though **Salsa** successfully served up a line to the UI, the text for the line was not propagated to the UI in the `ajax:success` event.
* Add authentication
* DRY up some of the controller error handling code

## If you were to critique your code, what would you have to say about it?
Overall, the code and design are pretty good.  The Ruby code is well structured, which has a lot to do with the Ruby on Rails framework.  The endpoints are very lightweight, leaving the heavy lifting to other classes in the system.  Using ActiveRecord simplified a lot of the effort in managing the data model.

The shell script, run.sh, is ok, I don't do a lot of shell scripting so each time it's a learning experience.
