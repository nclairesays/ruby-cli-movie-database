require_relative '../models/user.rb'
require_relative '../models/recommender.rb'
require 'pry'
require 'rainbow'

class CLI
  PROMPT = TTY::Prompt.new
  FONT = TTY::Font.new(:starwars)

  def self.welcome
    # welcome_style = "==== Welcome To The Internet's No. 1 Movie Database ===="
    puts
    # puts "#{Rainbow(welcome_style).red.underline}"
    puts FONT.write("MOVIE")
    puts FONT.write("DATABASE")
    puts
    username = PROMPT.ask("To begin, please enter your username:", required: true)
    puts
    signin_page(username)
  end

  def self.signin_page(username)
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
    options = ["Find Movie By Title", "Find Cinemas Near You", "My Recommendations",
    "My Profile", "About", "Exit"]
    selection = PROMPT.select("Please Select From One of the Following Options:", options)
    puts
    case selection
    when "Find Movie By Title"
      menu_one(user)
    when "Find Cinemas Near You"
      find_by_location(user)
    when "My Recommendations"
      recommendations(user) #consider adding a recommendations thing.
    when "My Profile"
    #   profile
    when "About"
      about_info(user)
    when "Exit"
      puts "#{Rainbow("==== Goodbye & Thank You For Using Our Database! ====").red.underline}"
    end
  end

  def self.movie_info_basic(movie)
    puts "#{movie.title.split.map(&:capitalize).join(" ")}, #{movie.year}, IMDB Rating: #{movie.imdb_score}"
  end

  private
  def self.menu_one(user)
    puts
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
      user.movies.reverse.first(10).each do |movies|
        movie_info_basic(movies)
      end
      menu_one(user)
    when "What's Popular Amongst All Users"
      # groups movies by the amount of searches then returns descending list, limited to 5
      var = Search.group('movie_id').order('count(movie_id) DESC').limit(5).map{|t| Movie.find(t.movie_id)}
      var.each do |movie|
        movie_info_basic(movie)
      end
      menu_one(user)
    when "Return to Main Menu"
      mainmenu(user.username)
    end
  end

  def self.find_by_movie(user)
    # binding.pry
    input = PROMPT.ask("Please Enter A Movie Title:").downcase
    # checks whether any titles in the db contain what the user has input
    # returns true / false value
    check = Movie.exists?(['title LIKE ?', "%#{input}%"])
    # user = User.find_by(username: username)
    if check == false
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
   elsif check == true
     # finds the movie that contains whatever the user has inputted
     # returns relavant title / plot info from db
     movie = Movie.find_by(['title LIKE ?', "%#{input}%"])
     movie_info(user, movie)
    end
  end

  def self.movie_info(user, movie)
    # binding.pry
    Search.create(user_id: user.id, movie_id: movie.id)
    puts
    puts "==== #{Rainbow("#{movie.title.split.map(&:capitalize).join(" ")}, #{movie.year}").red.underline} ===="
    puts
    puts "#{movie.plot}"
    puts
  end



  def self.about_info(user)
    puts
    puts "Movie Database Is A Product of Ryan Barker & Sang Song"
    puts
    puts "==== Ryan Barker ===="
    puts "Ryan is a young, software engineer in training. He has passion for technology and problem solving."
    puts
    puts "==== Sang Song ===="
    puts "Sang is a young, software engineer in training. He has passion for technology and problem solving."
    puts
    puts
    puts "==== APIs Used ===="
    puts "OMDB API"
    puts "TMDB API"
    mainmenu(user)
  end

  def self.find_by_location(user)
    Launchy.open("www.google.com/maps/search/?api=1&query=Cinemas+#{user.location.upcase}")
    mainmenu(user.username)
  end

  def self.my_profile(user)
  end

  def self.recommendations(user)
    options = ["Surprise Me", "Recommend Me Based on Genre", "View my Recommendations", "Return to Main Menu"]
    selection = PROMPT.select("Please Select From One of the Following Options:", options)
    puts
    case selection
    when "Surprise Me"
      # binding.pry
      #Recommend based on features + throw a wildcard every couplee
      Recommender.surprise_me(user)
      recommendations(user)
    when "Recommend Me Based on Genre"
      genres = []
      Movie.all.group('genre').distinct.map{|m| genres << m.genre}
      selection = PROMPT.select("Please Select a Genre:", genres)
      Recommender.recommend_based_on_genre(selection, user)
      recommendations(user)
      #Recommend a single movie based on the movie they choose
    when "View my Recommendations"
      Recommender.view_recommendations(user)
      recommendations(user)
      #Return last 10 recommended movies for user
    when "Return to Main Menu"
      mainmenu(user.username)
    end
  end
end
