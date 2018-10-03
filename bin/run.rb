require_relative '../config/environment'
# require 'tty-command'
#
# cmd = TTY::Command.new
# script = 'tell app "Terminal"
#     do script "ruby ~./bin/start.rb"
# end tell'
# cmd.run("osascript -e", script)
system("printf \"\033]0;Movie Database\007\"")
system('clear')


CLI.welcome
