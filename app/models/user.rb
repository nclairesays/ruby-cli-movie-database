require 'digest'
# require_relative '../lib/cli.rb'

class User < ActiveRecord::Base
  has_many :searches
  has_many :movies, through: :searches

  PROMPT = TTY::Prompt.new

  def self.signup(username)
    pass = hash(PROMPT.mask("Please Enter a Password:", required: true))
    puts
    if hash(PROMPT.mask("Please Enter Your Password Again:", required: true)) == pass
      postcode = validate_postcode
      age = validate_age
      gender = validate_gender
      user = User.create(username: username, password: pass, location: postcode, age: age, gender: gender)
      puts
      puts "==== Thank you for signing up #{user.username}! ===="
      puts
      CLI.mainmenu(username)
    else
      puts "The Passwords You Have Entered Did not Match."
      CLI.signin_page(username)
    end
  end

  def self.login(username)
    validate(username)
  end

  private
  def self.validate(username)
    i = 0
    loop do
      pass = hash(PROMPT.mask("Please Enter Your Password:", required: true))
      if self.find_by(username: username, password: pass) && i < 3
        puts
        puts "#{Rainbow("==== Welcome #{username.capitalize}! ====").red.underline}"
        puts
        CLI.mainmenu(username)
        break
      elsif i == 2
        puts "You Have Exceeded The Password Attempt Limit."
        CLI.welcome
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
    PROMPT.ask("Please Input Your Postcode") do |postcode|
      postcode.required true
      postcode.validate(/^[a-zA-Z0-9]{3,4}\s[a-zA-Z0-9]{3,4}$/, 'Invalid Postcode')
      postcode.modify :remove, :down
    end
  end

  def self.validate_age
    PROMPT.ask("Please Input Your Age") do |age|
      age.required true
      age.in('16-115', 'You must be over the age of 16')
      age.validate(/\d{2,3}/, 'Invalid Age')
      age.convert :int
    end
  end

  def self.validate_gender
    PROMPT.select("Please Select Your Gender", %w(M F O))
  end

end
