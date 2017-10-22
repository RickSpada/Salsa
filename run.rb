#! /user/bin/env/ruby
# script to start the Salsa app from run.sh
#   ruby run.rb file_to_serve

require 'optparse'
require 'ostruct'
require 'byebug'

# Is the process alive?
# @param pid [Integer] Process to determine whether or not it's still alive.
# @return [Boolean] Whether or not the process is alive.
def is_alive?(pid)
  Process.getpgid(pid)
  true
rescue Errno::ESRCH
  false
end

# Retrieve the Salsa pid
def salsa_pid
  salsa_dir = File.dirname(__FILE__)
  pid_file = "#{salsa_dir}/tmp/pids/server.pid"
  if File.file?(pid_file) then
    File::read(pid_file).to_i
  else
    nil
  end
end

# Is Salsa alive?
def is_salsa_alive?
  pid = salsa_pid
  if !pid.nil? then
    is_alive?(pid)
  else
    false
  end
end

# Kill the salsa process
def kill_salsa
  puts 'Terminating Salsa'
  Process.kill('TERM', salsa_pid) if salsa_pid
end

# Start the salsa process
def start_salsa
  puts 'Starting Salsa'
  Dir.chdir File.dirname(__FILE__)
  system 'rails s &>salsa.log &'
end

# ------------------------------------------------------------------------------
# Start of script
# ------------------------------------------------------------------------------

options = OpenStruct.new
OptionParser.new do |opts|
  opts.banner = 'Usage: run.rb [--file FileName | --restart | --kill]'

  opts.on('-f', '--file', 'File to serve by Salsa') do |file_name|
    puts "File: #{file_name}"
    options.file_name = file_name
  end

  opts.on('-r', '--restart', 'Restart Salsa') do
    options.restart_salsa = true
  end

  opts.on('-k', '--kill', 'Kill Salsa') do
    options.kill_salsa = true
  end
end.parse!

byebug

# Restart Salsa
if options.restart_salsa
  puts 'Salsa not running' if !is_salsa_alive?
  start_salsa
end

# Terminate Salsa
kill_salsa if options.kill_salsa && is_salsa_alive?

exit! if options.restart_salsa || options.kill_salsa

# Start Salsa if necessary
if !is_salsa_alive?
  start_salsa
end

# if a file name was passed in, open salsa and point it to the
# file, otherwise, just open another instance of the salsa UI
options.file_name.nil? ?
    open("http://0.0.0.0:3333") :
    open("http://0.0.0.0:3333/file&#{options.file_name}")