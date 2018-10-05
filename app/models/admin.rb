require 'digest'
include Style

class Admin < ActiveRecord::Base
  PROMPT = TTY::Prompt.new
  def self.admin_signin(username)
    pass = hash(PROMPT.mask("#{normal("Please Enter a Password:")}", required: true))

    if Admin.exists?(username: username) == false && pass == hash("admin")
      pass = hash(PROMPT.mask(normal("Please enter a new password:"), required: true,))
      user = Admin.create(username: username, password: pass)
      validate(user)
    elsif Admin.exists?(username: username)
      validate(Admin.find_by(username: username))
    end
  end

  private
  def self.hash(pass) #hide password
    sha256 = Digest::SHA256.new
    hash = sha256.digest pass
    hash.force_encoding('UTF-8')
  end

  def self.validate(user)
    loop do
      pass = hash(PROMPT.mask(normal("Please Enter Your Password:"), required: true))
      if self.find_by(username: user.username, password: pass)
        puts
        puts "#{warning("======== Admin Detected ========")}"
        puts
        admin_page
        break
      else
        puts warning("======== Access Denied ========")
        break
      end
    end
  end

  def self.admin_page
    reset
    options = ["User Management", "Exit"]
    selection = PROMPT.select("#{menu('======= God Menu =======')}\n", options)
    puts
    case selection
    when 'User Management'
      user_management
    # when 'Movie Management'
    #   movie_management
    when 'Exit'
      puts message('======== Goodbye ========')
    end
  end

  def self.user_management
    reset
    options = ["Find User Based on Name", "Go Back"]
    selection = PROMPT.select("#{menu('======= God Menu =======')}\n", options)
    puts
    case selection
    # when 'Find Users'
    #   find_users
    when 'Find User Based on Name'
      find_user_by_name
    when 'Go Back'
      admin_page
    end
  end

  # def self.movie_management
  #   reset
  #   options = ["Find Movies", "Go Back"]
  #   selection = PROMPT.select("#{menu('======= Movie Menu =======')}\n", options)
  #   puts
  #   case selection
  #   when 'Find Movies'
  #     find_movies
  #   when 'Go Back'
  #     admin_page
  #   end
  # end

  # def self.find_movies
  #   reset
  #   options = ["Find by Genre", "Find by Rated", "Find by IMDB Score", "Find Least Popular", "Find Most Popular", "Go Back"]
  #   selection = PROMPT.select("#{menu('======= Movie Menu =======')}\n", options)
  #   puts
  #   case selection
  #   when 'Find by Genre'
  #     find_movie_by("genre")
  #   when 'Find by Rated'
  #     find_movie_by("rated")
  #   when 'Find by IMDB Score'
  #     find_movie_by("imdb_score")
  #   when 'Find Least Popular'
  #     find_most_or_least("min")
  #   when 'Find Most Popular'
  #     find_most_or_least("max")
  #   when "Go Back"
  #     admin_page
  #   end
  # end
  #
  # def self.find_movie_by(input)
  #   case input
  #   when "genre"
  #     Movie.all.find_by('genre')
  #   when "rated"
  #   when "imdb_score"
  #   end
  # end


  def self.find_user_by_name
    reset
    name = PROMPT.ask(message("Please Type the User You Would Like to Find:"), required: true)
    if User.exists?(username: name)
      show_user(User.find_by(username: name))
      user_management
    else
      puts warning("Sorry This User Does Not Exist.")
      user_management
    end
  end

  def self.show_user(user)
    puts
    puts message("====== User Profile for: #{user.username} ======")
    puts
    puts message("=== Age:#{user.age} Gender:#{user.gender} Location:#{user.location} ===")
    puts
    options = ["Reset Password", "Delete User"]
    selection = PROMPT.select("#{menu('======= Options =======')}\n", options)
    case selection
    when 'Reset Password'
      user.update(password: hash(user.location))
      user.update(password_flag: 1)
      puts
      puts message("User Password Successfully Reset.")
      puts
    when 'Delete User'
      User.delete(user.id)
      puts
      puts message("User Account Successfully Deleted.")
      puts
    end
  end

  # def self.show_movie(movie)
  #   puts
  #   puts message("====== Movie Title: #{movie.title} ======")
  #   puts
  #   puts message("=== Rated:#{movie.rated} IMDB Score:#{movie.imdb_score} Favourited:#{Favourite.where(movie_id: movie.id).count} ===")
  #   puts
  #   options = ["Delete Movie"]
  #   selection = PROMPT.select("#{menu('======= Options =======')}\n", options)
  #   case selection
  #   when 'Delete Movie'
  #     Movie.delete(movie.id)
  #     puts
  #     puts message("Movie Account Successfully Deleted.")
  #     puts
  #   end
  # end

  def self.reset
    system('reset')
  end

end
