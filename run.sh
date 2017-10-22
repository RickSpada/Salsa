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

for i in "$@"
do
case $i in
    #
    # Restart Salsa and exit
    #
    -r|--restart)
        ruby $scriptDir/run.rb --restart
        exit 0
    ;;
    #
    # Terminate Salsa and exit
    #
    -k|--kill)
        echo "Terminating Salsa"
        ruby $scriptDir/run.rb --kill
        exit 0
    ;;
    #
    # File to serve
    #
    -f=*|--file_name=*)
    FILE_TO_SERVE="${i#*=}"
    shift # past argument=value
    ;;
    *)
    # unknown option, assume it's the name of the file to serve up
    FILE_TO_SERVE=$i
    ;;
esac
done

#
# Exit early if no file passed in or if the file doesn't exist
#
if [ -z "$FILE_TO_SERVE" ]; then
    echo "File not passed in.  Exiting."
    exit 1
fi

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
ruby $scriptDir/run.rb -f $fileToServe