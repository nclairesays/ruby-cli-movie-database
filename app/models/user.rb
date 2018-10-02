require 'digest'
# require_relative '../lib/cli.rb'

class User < ActiveRecord::Base
  has_many :searches
  has_many :movies, through: :searches

  def self.signup(username)
    puts
    puts "Please Enter A Password:"
    pass = hash(gets.chomp) #some hash, also blur out with gems
    puts
    puts "Please Enter Your Password Again:"
    if hash(gets.chomp) == pass #need to figure out pass perhaps .to_s
      puts
      puts "Please Input Your Postcode:" #some sort of postcode validation
      postcode = validate_postcode
      puts
      puts "Please Input Your Age:"
      age = validate_age
      puts
      puts "Please Input Your Gender: M / F / O"
      gender = validate_gender
      # binding.pry
      user = User.create(username: username, password: pass, location: postcode, age: age, gender: gender)
      # puts username
      # puts pass
      # puts postcode
      # puts age
      # puts gender
      puts
      puts "==== Thank you for signing up #{user.username}! ===="
      puts
      # puts "Thank you for setting up your account #{user.username}"
      CLI.mainmenu(username)
    else
      puts "The Passwords You Have Entered Did not Match."
      puts
      puts "1: Sign Up"
      puts "2: Login"
      puts
      # functionality for menu navigation here
    end
  end

  def self.login(username)
    puts "Please Enter Your Password:"
    puts
    validate(username)
  end

  private
  def self.validate(username)
    i = 0
    loop do
      pass = gets.chomp
      if self.find_by(username: username, password: hash(pass)) && i < 3
        puts
        puts "#{Rainbow("==== Welcome #{username.capitalize}! ====").red.underline}"
        puts
        CLI.mainmenu(username)
        break
      elsif i == 3
        puts "You Have Exceeded The Password Attempt Limit."
        break
      else
        i += 1
        puts "The Username Or Password You Have Entered Was Incorrect."
      end
    end
  end

  def self.hash(pass) #hide password
    sha256 = Digest::SHA256.new
    hash = sha256.digest pass
    hash.force_encoding('UTF-8')
  end

  def self.validate_postcode
    loop do
      code = gets.delete(' ')
      if code.length > 8 || code.length < 6
        puts "The Postcode You Entered Was Not Valid."
        puts "Please Enter A Valid Postcode:"
        puts
      else
        break
      end
      code
    end
  end

  def self.validate_age
    loop do
      age = gets.to_i
      if age < 16 || age > 115
        puts "The Age You Entered Was Not Valid."
        puts "Please Enter A Valid Age:"
        puts
      else
        break
      end
      age
    end
  end

  def self.validate_gender
    loop do
      gender = gets.chomp.upcase
      if gender != "M" && gender != "F" && gender != "O"
        puts "The Gender You Entered Was Not Valid."
        puts "Please Enter A Valid Gender:"
        puts
      else
        break
      end
      gender
    end
  end


end
