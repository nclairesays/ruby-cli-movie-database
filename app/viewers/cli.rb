require_relative '../models/user.rb'

def welcome
  puts "Welcome to anything"
  puts "Please enter your username:"
  username = gets.chomp

  puts "Please select an option"
  puts "1: Sign Up"
  puts "2: Login"

  loop do
    selection = gets.chomp.to_i

    if selection == 1
      User.signup(username)
      break
    elsif selection == 2
      User.login(username)
      break
    else
      puts "Please make a valid selection"
    end
  end
end

def test
  User.signup(gets.chomp)
end
#
# private
# def selection(username, value)
#   if value == 1
#     User.signup(username)
#   elsif value == 2
#     User.login(username)
#   end
# end
