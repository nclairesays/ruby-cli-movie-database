require_relative '../models/user.rb'
require 'pry'
require 'rainbow'

class CLI
  PROMPT = TTY::Prompt.new

  def self.welcome
    welcome_style = "==== Welcome To The Internet's No. 1 Movie Database ===="
    puts
    puts "#{Rainbow(welcome_style).red.underline}"
    puts
    username = PROMPT.ask("To begin, please enter your username:")
    puts
    selection = PROMPT.select("Please Select From One of the Following Options:", %w(Register Login Exit))
    puts #continue working on this and change.
    case selection
    when "Register"
      User.signup(username)
      # break
    when "Login"
      User.login(username)
      # break
    when "Exit"
      goodbye_style = "==== Goodbye & Thank You For Using Our Database! ===="
      puts "#{Rainbow(goodbye_style).red.underline}"
      puts
      # break
    end
    # end
  end

  def self.mainmenu(username)
    user = User.find_by(username: username)
    puts "#{Rainbow("==== Main Menu ====").red.underline}"
    puts
    options = ["Find Movie By Title", "Find Activities By Location", "My Recommendations",
    "My Profile", "Surprise Me!", "Help", "About", "Exit"]
    selection = PROMPT.select("Please Select From One of the Following Options:", options)
    puts
    case selection
    when "Find Movie By Title"
      menu_one(user)
    # when 2
      # user = User.find_by(username: username)
      # puts "#{user.movies}"
      # find_by_location
    # when 3
    #   recommendations
    # when 4
    #   profile
    # when 5
    #   surprise
    # when 6
    #   help
    # when 7
    #   about
    when "Exit"
      puts "Goodbye"
    end
  end

  private
  def self.menu_one(user)
    puts "#{Rainbow("<< Find Movie by Title >>").yellow.underline}"
    puts
    options = ["Movie Search", "Recent Searches", "What's Popular Amongst All Users", "Return to Main Menu"]
    selection = PROMPT.select("Find Movie by Title:", options)

    puts
    case selection
    when "Movie Search"
      find_by_movie(user)
      menu_one(user)
    when "Recent Searches"
      user.movies.each do |movies|
        movie_info_basic(movies)
      end
      menu_one(user)
    when "What's Popular Amongst All Users"
      var = Search.group(:movie_id).order('movie_id').limit(5).map{|t| Movie.find(t.movie_id)}
      var.each do |movie|
        movie_info_basic(movie)
      end
      menu_one(user)
    when "Return to Main Menu"
      mainmenu(user.username)
    end
  end

  def self.find_by_movie(user)
    puts "Please Enter A Movie Title:"
    puts
    input = gets.chomp.downcase
    movie = Movie.find_by(title: input)
    # user = User.find_by(username: username)
    if movie == nil
      result = get_movie_from_api(input)
      # binding.pry
      if result == nil
        puts "We Were Unable To Find A Movie With That Title."
        puts "Please Enter A Valid Movie Title:"
        puts
      else
        # Search.create(user_id: user, movie_id: result)
        movie_info(user, result)
      end
     #find the matching db entry to user input
    elsif movie.title == input

      movie_info(user, movie)
    end
  end

  def self.movie_info(user, movie)
    Search.create(user_id: user.id, movie_id: movie.id)
    puts
    puts "==== #{Rainbow("#{movie.title.split.map(&:capitalize).join(" ")}, #{movie.year}").red.underline} ===="
    puts
    puts "#{movie.plot}"
    puts
  end

  def self.movie_info_basic(movie)
    puts "#{movie.title.split.map(&:capitalize).join(" ")}, #{movie.year}, IMDB Rating: #{movie.imdb_score}"
  end

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
