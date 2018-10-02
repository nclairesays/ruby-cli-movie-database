require 'digest'
# require_relative '../lib/cli.rb'

class User < ActiveRecord::Base
  has_many :searches
  has_many :movies, through: :searches

  def self.signup(username)
    puts "Please enter a password"
    pass = hash(gets.chomp) #some hash, also blur out with gems
    puts "Please enter your password again"
    if hash(gets.chomp) == pass #need to figure out pass perhaps .to_s
      puts "Please input your postcode:" #some sort of postcode validation
      postcode = validate_postcode
      puts "Please input your age:"
      age = validate_age
      puts "Please input your gender: M / F / O"
      gender = validate_gender
      # binding.pry
      user = User.create(username: username, password: pass, location: postcode, age: age, gender: gender)
      # puts username
      # puts pass
      # puts postcode
      # puts age
      # puts gender
      puts "Thank you for signing up #{user.username}"
      # puts "Thank you for setting up your account #{user.username}"
      CLI.mainmenu(username)
    else
      puts "Your passwords did not match."
      puts "1: Sign Up"
      puts "2: Login"
    end
  end

  def self.login(username)
    puts "Please enter your password"
    validate(username)
  end

  private
  def self.validate(username)
    i = 0
    loop do
      pass = gets.chomp
      if self.find_by(username: username, password: hash(pass)) && i < 3
        puts "Welcome #{username.capitalize}"
        CLI.mainmenu(username)
        break
      elsif i == 3
        puts ":("
        break
      else
        i += 1
        puts "Wrong username or password"
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
        puts "Please enter a valid postcode"
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
        puts "Please enter a valid age"
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
        puts "Please enter a valid gender"
      else
        break
      end
      gender
    end
  end


end
