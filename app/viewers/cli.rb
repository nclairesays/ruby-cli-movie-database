require_relative '../models/user.rb'
require_relative '../models/recommender.rb'
require 'pry'
require 'rainbow'
include Style

class CLI
  # Instantiate new UI objects


  # Welcome Screen With Logo And Username Prompt
  def self.welcome
    reset
    title_header
    signin_page
  end

  # Registration / Login page
  def self.signin_page
    username = User.validate_username
    puts
    selection = PROMPT.select("#{normal("Please Select From One of the Following Options:")}", %w[Register Login Exit])
    puts
    case selection
    when 'Register'
      if User.find_by(username: username)
        puts warning("Username Already Exists. Please Login Or Choose a Different Username.")
        signin_page
      else
        User.signup(username)
      end
    when 'Login'
      if User.find_by(username: username)
        User.login(User.find_by(username: username))
      else
        puts warning("Username Does Not Exist. Please Register.")
        signin_page
      end
    when 'Exit'
      puts message("==== Goodbye & Thank You For Using Our Database! ====")
    end
  end

  def self.mainmenu(user)
    reset
    title_header
    options = ["Find Movie By Title", "Find Cinemas Near You", "Find Restaurants Near You", "My Recommendations",
    "Account Management", "About", "Exit"]
    selection = PROMPT.select("#{menu('======= Main Menu =======')}\n", options)
    puts
    case selection
    when 'Find Movie By Title'
      reset
      menu_one(user)
    when 'Find Cinemas Near You'
      reset
      find_by_location(user)
    when 'Find Restaurants Near You'
      reset
      restaurant_by_location(user)
    when 'Account Management'
      # required password verification to transition
      reset
      User.account_management_validation(user)
    when "My Recommendations"
      reset
      recommendations(user)
    when "About"
      reset
      about_info(user)
    when 'Exit'
      puts message('==== Goodbye & Thank You For Using Our Database! ====')
    end
  end

  def self.movie_info_basic(movie)
    puts "#{message("#{movie.title.split.map(&:capitalize).join(" ")}, #{movie.year}")}, #{menu("IMDB Rating: #{movie.imdb_score}")}"
  end

  def self.menu_one(user)
    title_header
    options = ['Movie Search', 'Recent Searches', "My Favourites","What's Popular Amongst All Users", 'Return to Main Menu']
    selection = PROMPT.select("#{menu('<< Find Movie by Title >>')}\n", options)

    puts
    case selection
    when 'Movie Search'
      reset
      find_by_movie(user)
      menu_one(user)
    when "Recent Searches"
      reset
      recent_searches(user)
      menu_one(user)
    when "My Favourites"
      reset
      my_favourites(user)
    when "What's Popular Amongst All Users"
      reset
      # groups movies by the amount of searches then returns descending list, limited to 5
      popular(user)
      menu_one(user)
    when 'Return to Main Menu'
      mainmenu(user)
    end
  end

  def self.popular(user)
    var = Search.group('movie_id').order('count(movie_id) DESC').limit(5).map { |t| Movie.find(t.movie_id) }
    table = TTY::Table.new []
    renderer = TTY::Table::Renderer::Basic.new(table)
    var.each do |movie|
      table << movie_info_basic(movie)
    end
    title_header
    puts menu("<< Popular Movies >>")
    puts
    puts renderer.render
    puts
    PROMPT.keypress("Press space to continue...", keys: [:space])
    reset
  end

  def self.my_favourites(user)
    reset
    title_header
    favourites = []
    Favourite.all.where(user_id: user.id).reverse.take(10).each{|t| favourites << Movie.find(t.movie_id).title.split.map(&:capitalize).join(' ')}
    favourites << message("Go Back")
    selection = PROMPT.select(normal("Please Select A Movie For More Info:\n"), favourites)
    if selection == message("Go Back")
      reset
      menu_one(user)
    else
    show_fave(selection, user)
    PROMPT.keypress("Press space to continue...", keys: [:space])
    reset
    end
  end

  def self.show_fave(movie_title, user)
    reset
    title_header
    movie = Movie.find_by(title: movie_title.downcase)
    puts
    puts message("====== #{movie.title.split.map(&:capitalize).join(' ')}, #{movie.year} ======")
    puts
    puts normal(movie.plot.to_s)
    puts
    input = PROMPT.yes?(normal('Would You Like To Keep This In Your Favourites?'))
    case input
    when true
      reset
      my_favourites(user)
    when false
      Favourite.delete(Favourite.find_by(user_id: user.id, movie_id: movie.id).id)
      reset
      my_favourites(user)
    end
  end

  def self.recent_searches(user)
    title_header
    puts menu("<< #{user.username.capitalize}'s Recent Searches >>")
    puts
    table = TTY::Table.new []
    renderer = TTY::Table::Renderer::Basic.new(table)
    user.movies.reverse.first(10).each do |movies|
      table << movie_info_basic(movies)
    end
    puts renderer.render
    puts
    PROMPT.keypress("Press space to continue...", keys: [:space])
    reset
  end

  def self.find_by_movie(user)
    title_header
    input = PROMPT.ask(normal('Please Enter A Movie Title:')).downcase
    # checks whether any titles in the db contain what the user has input
    # returns true / false value
    check = Movie.exists?(['title LIKE ?', "%#{input}%"])
    if check == false
      result = get_movie_from_api(input)
      if result.nil?
        puts
        spinner_animation(warning('We Were Unable To Find A Movie With That Title.'))
        puts
        PROMPT.keypress("Press space to return to Find Movie by Title...", keys: [:space])
        reset
      else
        puts
        spinner_animation(message("Movie Found!"))
        movie_info(user, result)
      end
    # find the matching db entry to user input
    elsif check == true
      # finds the movie that contains whatever the user has inputted
      # returns relavant title / plot info from db
      movie = Movie.find_by(['title LIKE ?', "%#{input}%"])
      puts
      spinner_animation(message("Movie Found!"))
      movie_info(user, movie)
    end
  end

  def self.movie_info(user, movie)
    reset
    title_header
    Search.create(user_id: user.id, movie_id: movie.id)
    puts
    puts message("====== #{movie.title.split.map(&:capitalize).join(' ')}, #{movie.year} ======")
    puts
    puts normal(movie.plot.to_s)
    puts
    input = PROMPT.yes?(normal('Would You Like To Keep This In Your Favourites?'))
    case input
    when true
      if Favourite.exists?(user_id: user.id, movie_id: movie.id)
        puts message("You Have Already Favourited This Movie")
        PROMPT.keypress(normal("Please Press Space or Enter to Continue"),require: true, keys: [:space, :return])
        reset
      else
        Favourite.create(user_id: user.id, movie_id: movie.id)
        reset
      end
    when false
      reset
    end
  end

  def self.movie_info_basic(movie)
    ["#{message("#{movie.title.split.map(&:capitalize).join(' ')}, #{movie.year}")}", "#{menu("IMDB Rating: #{movie.imdb_score}")}"]
  end

  def self.about_info(user)
    title_header
    puts
    puts menu("'Movie Database' Is A Product of Ryan Barker & Sang Song")
    puts
    puts message('==== Ryan Barker ====')
    puts normal('Ryan is a young, software engineer in training. He has passion for technology and problem solving.')
    puts
    puts message('==== Sang Song ====')
    puts normal('Sang is a young, software engineer in training. He has passion for technology and problem solving.')
    puts
    puts
    puts message("==== APIs Used ====")
    puts normal("1. OMDB API\n2. Google Maps API")
    puts
    PROMPT.keypress("Press space to return to the Main Menu...", keys: [:space])
    mainmenu(user)
  end

  def self.find_by_location(user)
    Launchy.open("www.google.com/maps/search/?api=1&query=Cinemas+near+#{user.location.upcase}")
    mainmenu(user)
  end

  def self.restaurant_by_location(user)
    Launchy.open("www.google.com/maps/search/?api=1&query=Restaurants+near+#{user.location.upcase}")
    mainmenu(user)
  end

  def self.recommendations(user)
    title_header
    puts
    options = ["Surprise Me", "Recommend Me Based on Genre", "View my Recommendations", "Return to Main Menu"]
    selection = PROMPT.select(menu("<< Recommendations >>\n"), options)
    puts
    case selection
    when "Surprise Me"
      Recommender.surprise_me(user)
    when "Recommend Me Based on Genre"
      genres = []
      Movie.all.group('genre').distinct.map{|m| genres << m.genre}
      selection = PROMPT.select(normal("Please Select a Genre:"), genres)
      Recommender.recommend_based_on_genre(selection, user)
      #Recommend a single movie based on the movie they choose
    when "View my Recommendations"
      Recommender.view_recommendations(user)
      #Return last 10 recommended movies for user
    when "Return to Main Menu"
      mainmenu(user)
    end
  end

  def self.reset
    system('reset')
  end
end
