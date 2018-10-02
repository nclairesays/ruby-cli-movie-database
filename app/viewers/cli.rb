require_relative '../models/user.rb'
require 'pry'
require 'rainbow'

class CLI
  def self.welcome
    welcome_style = "==== Welcome To The Internet's No. 1 Movie Database ===="
    puts
    puts "#{Rainbow(welcome_style).red.underline}"
    puts
    puts "To Begin, Please Enter Your Username:"
    puts
    username = gets.chomp
    puts
    puts "Please Select From One Of The Following Options:"
    puts
    puts "1: #{Rainbow("Sign Up").underline}"
    puts "2: #{Rainbow("Login").underline}"
    puts "8: #{Rainbow("Exit").underline}"
    puts

    loop do
      selection = gets.chomp.to_i
      puts
      case selection
      when 1
        User.signup(username)
        break
      when 2
        User.login(username)
        break
      when 8
        goodbye_style = "==== Goodbye & Thank You For Using Our Database! ===="
        puts "#{Rainbow(goodbye_style).red.underline}"
        puts
        break
      else
        puts "Please Enter A Valid Navigation Entry."
        puts "1: #{Rainbow("Sign Up").underline}"
        puts "2: #{Rainbow("Login").underline}"
        puts "8: #{Rainbow("Exit").underline}"
        puts
      end
    end
  end

  def self.mainmenu(username)
    user = User.find_by(username: username)
    puts "#{Rainbow("==== Main Menu ====").red.underline}"
    puts
    puts "Please Select From One Of The Following Options:"
    puts
    puts "1. #{Rainbow("Find Movie By Title").underline}"
    puts "2. #{Rainbow("Find Activities By Location").underline}"
    puts "3. #{Rainbow("My Recommendations").underline}"
    puts "4. #{Rainbow("My Profile").underline}"
    puts "5. #{Rainbow("Surprise Me!").underline}"
    puts "6. #{Rainbow("Help").underline}"
    puts "7. #{Rainbow("About").underline}"
    puts "8. #{Rainbow("Exit").underline}"
    puts

    loop do
      selection = gets.chomp.to_i
      puts
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
        puts "Goodbye"
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
    puts "#{Rainbow("<< Find Movie by Title >>").yellow.underline}"
    puts
    puts "1. #{Rainbow("Movie Search").underline}"
    puts "2. #{Rainbow("Recent Searches").underline}"
    puts "3. #{Rainbow("What's Popular Amongst All Users").underline}"
    puts "4. #{Rainbow("Return To Main Menu").underline}"
    puts

    loop do
      selection = gets.chomp.to_i
      puts
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
