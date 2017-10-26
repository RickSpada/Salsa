#! /user/bin/env/ruby
# script to start the Salsa app from run.sh
#   ruby run.rb file_to_serve

require 'httparty'
require 'launchy'
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
  Process.kill('SIGKILL', salsa_pid) if salsa_pid
end

# Start the salsa process
def start_salsa
  puts 'Starting Salsa'
  Dir.chdir File.dirname(__FILE__)
  system 'rails s &>salsa.log &'

  # Salsa takes a little bit to start up.  Loop here, say for 10
  # seconds while it does so
  10.times do
    if is_salsa_alive?
      break
    else
      sleep(1)
    end
  end

  if not is_salsa_alive?
    puts ">>>>> Something went wrong, the Salsa server did not start.  Exiting…"
    exit!
  end
end

# ------------------------------------------------------------------------------
# Start of script
# ------------------------------------------------------------------------------

options = OpenStruct.new
OptionParser.new do |opts|
  opts.banner = 'Usage: run.rb [--file FileName | --restart | --kill]'

  opts.on('-f', '--file FILE_NAME', 'File to serve by Salsa') do |file_name|
    options.file_name = file_name
  end

  opts.on('-k', '--kill', 'Kill Salsa') do
    options.kill_salsa = true
  end

  opts.on('-l', '--line LINE_NO', 'Request a line') do |line_no|
    options.line_no = line_no
  end
end.parse!

# Restart or Terminate Salsa
if options.kill_salsa
  kill_salsa
  exit!
end

# Start Salsa if necessary
if !is_salsa_alive?
  start_salsa
end

# if a line was requested, get it and exit
if options.line_no
  response = HTTParty.get('http://0.0.0.0:3333/lines', {
      body: "line_number=#{options.line_no}"
  })

  parsed_response = response
  if parsed_response.key?('errors')
    puts ">>> ERROR: #{parsed_response['errors']}"
    exit
  end

  puts parsed_response['line']
  exit
end

# if a file name was passed in, open salsa and point it to the
# file, otherwise, just open another instance of the salsa UI
if not options.file_name.nil?
  HTTParty.post('http://0.0.0.0:3333/file', {
      body: "file_name=#{options.file_name}"
  })
end

# no args passed in, just launch another instance
Launchy.open('http://0.0.0.0:3333')
