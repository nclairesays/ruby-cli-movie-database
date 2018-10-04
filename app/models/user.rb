require 'digest'
include Style

class User < ActiveRecord::Base
  has_many :searches
  has_many :recommendations
  has_many :favourites
  has_many :movies, through: :searches

  PROMPT = TTY::Prompt.new

  def self.signup(username)
    pass = hash(PROMPT.mask("#{normal("Please Enter a Password:")}", required: true))
    puts
    if hash(PROMPT.mask("#{message("Please Enter Your Password Again:")}", required: true)) == pass
      puts
      postcode = validate_postcode
      age = validate_age
      gender = validate_gender
      user = User.create(username: username, password: pass, location: postcode, age: age, gender: gender)
      puts
      puts message("==== Thank You For Signing Up #{user.username}! ====")
      puts
      CLI.mainmenu(user)
    else
      puts warning("The Passwords You Have Entered Did Not Match.")
      CLI.signin_page
    end
  end

  def self.account_management_validation(user)
    i = 0
    loop do
      pass = hash(PROMPT.mask(normal("Please Enter Your Password:"), required: true))
      if self.find_by(username: user.username, password: pass) && i < 3
        break
      elsif i == 2
        puts warning("You Have Exceeded The Password Attempt Limit.")
        CLI.welcome
        break
      else
        i += 1
        puts warning("The Password You Have Entered Was Incorrect.")
      end
    end
    my_profile(user)
  end

  def self.login(user)
    validate(user)
  end

  def self.my_profile(user)
    puts
    puts message("<< #{user.username.capitalize}'s Account >>")
    puts
    options = ['Change Username', 'Change Password', 'Change Postcode', 'Delete Account', 'Return To Main Menu']
    selection = PROMPT.select(menu('Please Select From One of the Following Options:'), options)
    puts
    case selection
    when 'Change Username'
      #requires password, then prompts for username change
      username_change(user)
    when 'Change Password'
      password_change(user)
    when 'Change Postcode'
      postcode_change(user)
    when 'Delete Account'
      delete_account(user)
    when 'Return To Main Menu'
      CLI.mainmenu(user)
    end
  end

  private
  def self.validate(user)
    i = 0
    loop do
      pass = hash(PROMPT.mask(normal("Please Enter Your Password:"), required: true))
      if self.find_by(username: user.username, password: pass) && i < 3
        puts
        puts "#{message("==== Welcome #{user.username.capitalize}! ====")}"
        puts
        CLI.mainmenu(user)
        break
      elsif i == 2
        puts warning("You Have Exceeded The Password Attempt Limit.")
        CLI.welcome
        break
      else
        i += 1
        puts warning("The Username Or Password You Have Entered Was Incorrect.")
      end
    end
  end

  def self.validate_username
    PROMPT.ask("#{normal("Please Enter Your Username:")}") do |q|
      q.required true
      q.validate(/\A\w{4,20}\z/, warning("User Must Be Alphanumeric And Must Be Betwen 4 and 20 Letters Long."))
      q.modify :down
      q.modify :remove
    end

  end

  def self.hash(pass) #hide password
    sha256 = Digest::SHA256.new
    hash = sha256.digest pass
    hash.force_encoding('UTF-8')
  end

  def self.validate_postcode
    PROMPT.ask(normal("Please Input Your Postcode:")) do |postcode|
      postcode.required true
      postcode.validate(/^[a-zA-Z0-9]{3,4}\s[a-zA-Z0-9]{3,4}$/, warning('Invalid Postcode'))
      postcode.modify :remove, :down
    end
  end

  def self.validate_age
    PROMPT.ask(normal("Please Input Your Age:")) do |age|
      age.required true
      age.in('16-115', warning('You must be over the age of 16'))
      age.validate(/\d{2,3}/, warning('Invalid Age'))
      age.convert :int
    end
  end

  def self.validate_gender
    PROMPT.select(normal("Please Select Your Gender:"), %w(M F O))
  end

  def self.username_change(user)
    puts
    new_username = validate_username
    user.update(username: new_username)
    puts
    puts message("Your Username Has Been Successfully Updated!")
    my_profile(user)
  end

  def self.password_change(user)
    i = 0
    loop do
      pass = hash(PROMPT.mask("Please Enter Your Old Password:", required: true))
      if self.find_by(username: user.username, password: pass) && i < 3
        break
      elsif i == 2
        puts warning("You Have Exceeded The Password Attempt Limit.")
        CLI.welcome
        break
      else
        i += 1
        puts warning("The Password You Have Entered Was Incorrect.")
      end
    end
    # prompt to change password
    puts
    pass = hash(PROMPT.mask(normal("Please Enter Your New Password:"), required: true))
    puts
    if hash(PROMPT.mask(message("Please Confirm Your New Password:"), required: true)) == pass
      user.update(password: pass)
      puts
      puts message("Your Password Has Been Successfully Updated!")
      my_profile(user)
    else
      puts
      puts warning("The Passwords You Have Entered Did Not Match.")
      my_profile(user)
    end
  end

  # this validates the postcode in order for us to change through Account Management
  # this is required so we can reference the variable in the postcode_change method below
  def self.postcode_change_validation
    PROMPT.ask(normal("Please Enter Your New Postcode:")) do |postcode|
      postcode.required true
      postcode.validate(/^[a-zA-Z0-9]{3,4}\s[a-zA-Z0-9]{3,4}$/, 'Invalid Postcode')
      postcode.modify :remove, :down
    end
  end

  def self.postcode_change(user)
    puts normal("Your current postcode is set to: '#{user.location.upcase}'")
    puts
    postcode = postcode_change_validation
    user.update(location: postcode)
    puts
    puts message("Your Postcode Has Been Successfully Updated!")
    my_profile(user)
  end

  def self.delete_account(username)
    PROMPT.ask(warning('Type "DELETE" To Confirm Account Deletion:'), required: "DELETE")
    User.delete(username.id)
    puts message("DELETED")
  end
end
