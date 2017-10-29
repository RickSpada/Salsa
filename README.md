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
Set the **Salsa** file to serve to FILE_NAME.  If the **Salsa** server is not running, it will be started.

-l | --line LINE_NO
Request a line from **Salsa**.  If the **Salsa** server is not running, it will be started.

-k | --kill
Shutdown the **Salsa** server.

## Controllers / Endpoints
### POST /file?file_name=FILE_NAME
This endpoint instructs **Salsa** to serve up a new file, `FILE_NAME`.  When called with a valid filename, **Salsa** will initiate a thread that will read in the file, line by line, creating `SalsaLine` objects for each line.

If an error occurs, an error message is returned with a status of 400.

### GET /lines?line_number=LINE_NUMBER
This endpoint requests a line, `LINE_NUMBER` from **Salsa**.  If the line is within the range of the file (1 to num_lines), the line is returned to the caller in a JSON payload with a status of 200.  If the line number is out of bounds, an error message is returned with a status of 413.

## System Models
There are two models that comprise the **Salsa** server, the **SalsaFile** and the **SalsaLine**.

### SalsaFile
The **SalsaFile** is a Singleton that has two primary attributes, the `file_name` and `line_count`.  The `file_name` contains the name of the file being served up by **Salsa** and the `line_count` contains the number of lines in the file.

As mentioned, this construct is a Singleton as there can only be one **Salsa** file being served up at a time.

### SalsaLine
The **SalsaLine** contains the line numbers and file offsets.  The `line_no` as it sounds is the line number in the **Salsa** file and `line_offset` is the offset into the file where the text is located.

## How the system works
When the **Salsa** `/file` endpoint is called to set or change the file being served the system responds by:

1. Deleting all existing **SalsaLine** objects.
2. Spawning a thread to read in the file line by line, creating new **SalsaLine** objects, one per line.

While reading in the file, the **SalsaFile** singleton is line count is updated as it processes each line.  This is done so that the user can make requests despite it not being fully processed.

When the `/lines` endpoint is called, **Salsa** responds by:

1. Checking that the line number is within bounds (i.e., less than or equal to the `line_count` stored in the **SalsaFile** singleton).  If not within bounds, an error is returned.
2. Performing an **ActiveRecord** query to find the **SalsaLine** with the specified line number.
3. Using the **SalsaLine** to `seek` into the **Salsa** file to set the I/O position to where the line of text is located.
4. Calling `gets` to retrieve the requested line.

## How will the system perform with a 1GB file? a 10 GB file? a 100 GB file?
The key algorithmic components in the system are:

1. Reading in the file
2. Creating a **SalsaLine** object for each line
3. Searching for a **SalsaLine** given a line number

The processing of the file is by far the biggest time consuming component of **Salsa**.  The system does do the file processing work on a separate thread so as to give the user the impression of a highly performant system.  However, it suffers from the fact that there is no affordance to the user that the file is not fully ready to be served up.

From what I've been able to discover, reading in a file, line by line is of complexity `O(n)` where `n` is the size of the file, meaning that reading the file will increase linearly with the size of the file.

I'll assume that there's little to no cost of creating a **SalsaLine** and that there's sufficient memory to create them given any file size.

Similarly after doing some research I learned that depending upon whether the database is indexed or not, the complexity for searching for a single **SalsaLine** object is O(long n) (indexed) or O(n) (non-indexed).  Assuming an indexed database, then as the file size increases towards infinity, the O(n) components will dominate, yielding a system with O(n) complexity.

In summary, as the file size increases, the time to read in the file and to locate a single line increases linearly.

While I've mitigated the performance hit at startup by spawning a thread to process the file, the amount of time it takes for **Salsa** to be fully operational would increase linearly with the size of the file.

## How will the system perform with 100 users?  10000 users?  1000000 users?
Since the system stores only one set of data that is shared amongst all users, the performance should be good regardless of the number of users.  As there is thread safety built into the `Lines::Get` class that retrieves a line of text, there would be no performance penalty in servicing multiple users, other than that which is involved in instantiating a `Lines::Get` object (pretty small). 

## What documention, websites, papers etc did you consult in doing this assignment.
The primary sources of information that I consulted were **Stack Overflow** and online *Rails* documentation.

## What third-party-librarys or other tools does the system use?  How did you choose each library or framework you used?
1. Ruby on Rails - I chose RoR because of the framework it provides for building a web app.
2. Launchy - Launchy provides methods to open a web-site from within Ruby.  I used this capability to launch each **Salsa** instance. 
3. HTTParty - HTTParty provides methods to call a server endpoint.  I used this in order to request a line from **Salsa** from a shell prompt.

## How long did you spend on this exercise?  If you had unlimited more time to spend on this, how would you spend it and how would you prioritize each item?
The primary effort for coding up **Salsa** took approximately 20 hours with the time broken up as:

1. 4 hours foundation - setting up the Rails app, writing run.sh, run.rb
2. 4 hours model and endpoints
3. 6 hours on the UI - I've only worked on the backend of web apps, so writing front end involved a little bit extra in terms of learning.
4. 3 hours debugging
5. 2 hours documentation
6. 1 hour miscellaneous

The durations above include not only coding, but also consulting documentation, websites, etc.

If there were unlimited time to spend I would do the following (highest priority first):

* Writing unit tests
* More rigorous performance analysis and tuning
* Come up with an approach to handle the case when something goes wrong while processing the file.
* UI Enhancements
  * Make the `file` endpoint foolproof.  Right now it is possible to call the enpoint while **Salsa** is in the midst of processing a file.  Ideally, the endpoint would return an error (Bad Request) or terminate the running thread in order to start its own.
  * Put the name of the file served in the UI
  * Notify the user when the file is still being processed.
  * Put the line of text on the same line as the label
  * Report to the user when the **Salsa** file server is not available.
* Make the build script more foolproof
  * Check that the right version of Ruby (>= 2.2.2) is installed
* DRY up some of the controller error handling code
* Add authentication

## If you were to critique your code, what would you have to say about it?
Overall, I'd give the code a good grade.  It uses memory efficiently by only storing the line numbers and offsets in the database.  The Ruby code is well structured, which has a lot to do with the Ruby on Rails framework.  The endpoints are very lightweight, leaving the heavy lifting to other classes in the system.  Using ActiveRecord simplified a lot of the effort in managing the data model.

The shell script, run.sh, is ok, I don't do a lot of shell scripting so each time it's a learning experience.
