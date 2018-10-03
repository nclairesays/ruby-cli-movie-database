require_relative '../models/user.rb'
require_relative '../models/recommender.rb'
require 'pry'
require 'rainbow'
include Style

class CLI
  # Instantiate new UI objects
  PROMPT = TTY::Prompt.new
  FONT = TTY::Font.new(:starwars)
  PASTEL = Pastel.new

  # Welcome Screen With Logo And Username Prompt
  def self.welcome
    reset
    puts PASTEL.magenta.bold(FONT.write('MOVIE'.center(50)))
    puts PASTEL.magenta.bold(FONT.write('DATABASE'))
    puts
    signin_page
  end

  # Registration / Login page
  def self.signin_page
    username = PROMPT.ask("#{normal("Please Enter Your Username:")}", required: true).downcase
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
    puts
    options = ["Find Movie By Title", "Find Cinemas Near You", "My Recommendations",
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
    when 'Account Management'
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

  private

  def self.menu_one(user)
    options = ['Movie Search', 'Recent Searches', "What's Popular Amongst All Users", 'Return to Main Menu']
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
    puts renderer.render
  end

  def self.recent_searches(user)
    table = TTY::Table.new []
    renderer = TTY::Table::Renderer::Basic.new(table)
    user.movies.reverse.first(10).each do |movies|
      table << movie_info_basic(movies)
    end
    puts renderer.render
  end

  def self.find_by_movie(user)
    input = PROMPT.ask(normal('Please Enter A Movie Title:')).downcase
    # checks whether any titles in the db contain what the user has input
    # returns true / false value
    check = Movie.exists?(['title LIKE ?', "%#{input}%"])
    # user = User.find_by(username: username)
    if check == false
      result = get_movie_from_api(input)
      # binding.pry
      if result.nil?
        puts warning('We Were Unable To Find A Movie With That Title.')
      else
        # Search.create(user_id: user, movie_id: result)
        movie_info(user, result)
      end
    # find the matching db entry to user input
    elsif check == true
      # finds the movie that contains whatever the user has inputted
      # returns relavant title / plot info from db
      movie = Movie.find_by(['title LIKE ?', "%#{input}%"])
      movie_info(user, movie)
    end
  end

  def self.movie_info(user, movie)
    reset
    # binding.pry
    Search.create(user_id: user.id, movie_id: movie.id)
    puts
    puts message("====== #{movie.title.split.map(&:capitalize).join(' ')}, #{movie.year} ======")
    puts
    puts normal(movie.plot.to_s)
    puts
  end

  def self.movie_info_basic(movie)
    ["#{message("#{movie.title.split.map(&:capitalize).join(' ')}, #{movie.year}")}", "#{menu("IMDB Rating: #{movie.imdb_score}")}"]
  end

  def self.about_info(user)
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
    puts normal("OMDB API")
    mainmenu(user)
  end

  def self.find_by_location(user)
    Launchy.open("www.google.com/maps/search/?api=1&query=Cinemas+#{user.location.upcase}")
    mainmenu(user.username)
  end

  def self.recommendations(user)
    options = ["Surprise Me", "Recommend Me Based on Genre", "View my Recommendations", "Return to Main Menu"]
    selection = PROMPT.select(menu("<< Recommendations >>"), options)
    puts
    case selection
    when "Surprise Me"
      Recommender.surprise_me(user)
      recommendations(user)
    when "Recommend Me Based on Genre"
      genres = []
      Movie.all.group('genre').distinct.map{|m| genres << m.genre}
      selection = PROMPT.select(normal("Please Select a Genre:"), genres)
      Recommender.recommend_based_on_genre(selection, user)
      recommendations(user)
      #Recommend a single movie based on the movie they choose
    when "View my Recommendations"
      Recommender.view_recommendations(user)
      recommendations(user)
      #Return last 10 recommended movies for user
    when "Return to Main Menu"
      mainmenu(user)
    end
  end

  def self.reset
    system('reset')
  end
end
