#! /bin/bash
# Script that serves up a file to the Salsa app and starts the Salsa server
#
#   run.sh fileToServe

scriptDir=`dirname $0`

#
#---------------------------------------------------------
# Arg processing
#---------------------------------------------------------
#

while [[ $# -gt 0 ]]
do
key="$1"
case $key in
    #
    # Terminate Salsa and exit
    #
    -k|--kill)
        ruby $scriptDir/run.rb --kill
        exit 0
    ;;
    #
    # Request a line from Salsa
    #
    -l|--line)
        LINE_NO="$2"
        shift # past argument
        shift # past value
        ruby $scriptDir/run.rb --line "$LINE_NO"
        exit 0
    ;;
    #
    # File to serve
    #
    -f|--file_name)
        FILE_TO_SERVE="$2"
        shift # past argument
        shift # past value
    ;;
    # unknown option, assume it's the name of the file to serve up
    *)
        FILE_TO_SERVE=$1
        shift # past value
    ;;
esac
done

#
# If no file passed in, launch another instance of the ui
#
if [ -z "$FILE_TO_SERVE" ]; then
    ruby $scriptDir/run.rb
    exit
fi

#
# If a file passed in and it doesn't exist, error and bail
#
if [ ! -e $FILE_TO_SERVE ]; then
    echo "File '$FILE_TO_SERVE' not found.  Exiting."
    exit 1
fi

#
#---------------------------------------------------------
# Let run.rb do the heavy lifting here (i.e. check if
# a rails server is already running, filename is ok, ...)
#---------------------------------------------------------
#
ruby $scriptDir/run.rb -f $FILE_TO_SERVE