require_relative '../models/user.rb'
require 'pry'
class CLI
  def self.welcome
    puts "Welcome to anything"
    puts "Please enter your username:"
    username = gets.chomp

    puts "Please select an option"
    puts "1: Sign Up"
    puts "2: Login"
    puts "8: Exit"

    loop do
      selection = gets.chomp.to_i
      case selection
      when 1
        User.signup(username)
        break
      when 2
        User.login(username)
        break
      when 8
        puts "Good Bye"
        break
      else
        puts "Please make a valid selection"
        puts "1: Sign Up"
        puts "2: Login"
        puts "8: Exit"
      end
    end
  end

  def self.mainmenu(username)
    user = User.find_by(username: username)
    puts "Please choose from the following menu:"
    puts "1. FIND MOVIE BY TITLE"
    puts "2. FIND ACTIVITIES BY LOCATION"
    puts "3. MY RECOMMENDATIONS"
    puts "4. MY PROFILE"
    puts "5. SURPRISE ME"
    puts "6. HELP"
    puts "7. ABOUT"
    puts "8. EXIT"

    loop do
      selection = gets.chomp.to_i
      case selection
      when 1
        menu_one(user)
        break
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
      when 8
        puts "Good Bye"
        break
      else
        puts "Please make a valid selection"
      end

      #
      # if selection == 1
      #   find_by_movie
      # elsif selection ==
    end
  end

  private
  def self.menu_one(user)
    puts "<<Find Movie by Title>>"
    puts
    puts "1. Find new movie by title"
    puts "2. Recent searches"
    puts "3. Popular amongst users"
    puts "4. Return to main menu"

    loop do
      selection = gets.chomp.to_i
      case selection
      when 1
        find_by_movie(user)
        menu_one(user)
        break
      when 2
        user.movies.each do |movies|
          movie_info_basic(movies)
        end
        menu_one(user)
        break
      when 3
        var = Search.group(:movie_id).order('movie_id').limit(5).map{|t| Movie.find(t.movie_id)}
        var.each do |movie|
          movie_info_basic(movie)
        end
        menu_one(user)
        break
      when 4
        mainmenu(user.username)
        break
      end
    end
  end

  def self.find_by_movie(user)
    puts "Please enter a movie title"
    input = gets.chomp.downcase
    movie = Movie.find_by(title: input)
    # user = User.find_by(username: username)
    if movie == nil
      result = get_movie_from_api(input)
      # binding.pry
      if result == nil
        puts "Please enter a valid movie title"
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
    puts "#{movie.title.split.map(&:capitalize).join(" ")}, #{movie.year}"
    puts "#{movie.plot}"
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
