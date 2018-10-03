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

  def self.account_management_validation(username)
    i = 0
    loop do
      pass = hash(PROMPT.mask("Please Enter Your Password:", required: true))
      if self.find_by(username: username.username, password: pass) && i < 3
        break
      elsif i == 2
        puts "You Have Exceeded The Password Attempt Limit."
        CLI.welcome
        break
      else
        i += 1
        puts "The Password You Have Entered Was Incorrect."
      end
    end
    CLI.my_profile(username)
  end

  def self.username_change(username)
    puts
    new_username = PROMPT.ask('Please Enter Your New Username:', required: true)
    username.update(username: new_username)
    puts
    puts "Your Username Has Been Successfully Updated!"
    CLI.my_profile(username)
  end


  def self.password_change(username)
    i = 0
    loop do
      pass = hash(PROMPT.mask("Please Enter Your Old Password:", required: true))
      if self.find_by(username: username.username, password: pass) && i < 3
        break
      elsif i == 2
        puts "You Have Exceeded The Password Attempt Limit."
        CLI.welcome
        break
      else
        i += 1
        puts "The Password You Have Entered Was Incorrect."
      end
    end
    # prompt to change password
    puts
    pass = hash(PROMPT.mask("Please Enter Your New Password:", required: true))
    puts
    if hash(PROMPT.mask("Please Confirm Your New Password:", required: true)) == pass
      username.update(password: pass)
      puts
      puts "Your Password Has Been Successfully Updated!"
      CLI.my_profile(username)
    else
      puts
      puts "The Passwords You Have Entered Did Not Match."
      CLI.my_profile(username)
    end
  end

  # this validates the postcode in order for us to change through Account Management
  # this is required so we can reference the variable in the postcode_change method below
  def self.postcode_change_validation(username)
    PROMPT.ask("Please Enter Your New Postcode:") do |postcode|
      postcode.required true
      postcode.validate(/^[a-zA-Z0-9]{3,4}\s[a-zA-Z0-9]{3,4}$/, 'Invalid Postcode')
      postcode.modify :remove, :down
    end
  end

  def self.postcode_change(username)
    puts "Your current postcode is set to: '#{username.location.upcase}'"
    puts
    postcode = postcode_change_validation(username)
    username.update(location: postcode)
    puts
    puts "Your Postcode Has Been Successfully Updated!"
    CLI.my_profile(username)
  end

  def self.delete_account(username)
    PROMPT.ask('Type "DELETE" To Confirm Account Deletion:', required: "DELETE")
    User.delete(username.id)
    puts "DELETED"
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
    PROMPT.ask("Please Input Your Postcode:") do |postcode|
      postcode.required true
      postcode.validate(/^[a-zA-Z0-9]{3,4}\s[a-zA-Z0-9]{3,4}$/, 'Invalid Postcode')
      postcode.modify :remove, :down
    end
  end

  def self.validate_age
    PROMPT.ask("Please Input Your Age:") do |age|
      age.required true
      age.in('16-115', 'You must be over the age of 16')
      age.validate(/\d{2,3}/, 'Invalid Age')
      age.convert :int
    end
  end

  def self.validate_gender
    PROMPT.select("Please Select Your Gender:", %w(M F O))
  end

end
