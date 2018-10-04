require 'decisiontree'
include Style

class Recommender < ActiveRecord::Base

  def self.surprise_me(user)
    if User.all.count > 5 && Search.all.count > 5 && Movie.all.count > 5
      random = Random.new
      chance = random.rand(1.0)
      if chance < 0.85
        labels = ["age", "gender", "genre", "movie_score"]
        training = []
        Search.all.each do |s|
          if User.exists?(s.user_id)
            average_favourites = Favourite.where(movie_id: s.movie_id).count / Search.where(movie_id: s.movie_id).count
            average_total_favourites = Favourite.where(movie_id: s.movie_id).count / Favourite.all.count
            average_from_searches = Favourite.where(movie_id: s.movie_id).count / Search.all.count
            average_movie_search = Search.where(movie_id: s.movie_id).count / Search.all.count
            imdb = Movie.find(s.movie_id).imdb_score / 10

            score = (average_favourites + average_total_favourites + average_from_searches + average_movie_search + imdb) / 5
            training << [User.find(s.user_id).age, User.find(s.user_id).gender,
              Movie.find(s.movie_id).genre, score, s.movie_id]
          end
        end
        dec_tree = DecisionTree::ID3Tree.new(labels, training, 0, age: :continuous,
          gender: :discrete, genre: :discrete, score: :discrete)
          binding.pry
        dec_tree.train
        data = [user.age, user.gender, user.movies.group('genre').order('count(genre) DESC').limit(1)[0].genre, 0.5]
        pred = dec_tree.predict(data)
        Recommendation.create(user_id: user.id, movie_id: pred)
        show_recommendations(Movie.find(pred).title, user)
      else
        genre = user.movies.group('genre').order('count(genre) DESC').limit(1)[0].genre
        movie = Movie.all.where(genre: genre).sample
        Recommendation.create(user_id: user.id, movie_id: movie.id)
        show_recommendations(movie.title, user)
      end
    else
      puts message("The AI is Still Collecting Data. Thank You For Your Patience.")
      puts
      PROMPT.keypress("Press space to continue...", keys: [:space])
      CLI.reset
      CLI.recommendations(user)
    end
  end

  def self.recommend_based_on_genre(genre, user)
    movie = Movie.all.where(genre: genre).sample
    Recommendation.create(user_id: user.id, movie_id: movie.id)
    selection = Movie.find(movie.id).title.split.map(&:capitalize).join(' ')
    puts
    show_recommendations(selection, user)
    puts
  end

  def self.view_recommendations(user)
    CLI.reset
    CLI.title_header
    recommendations = []
    movies = Recommendation.all.where(user_id: user.id).reverse.take(10).map{|t| t.movie_id}
    movies.uniq.each do |m|
      recommendations << Movie.find(m).title.split.map(&:capitalize).join(' ')
    end
    recommendations << "Go Back"
    selection = PROMPT.select(normal("Please Select A Movie For More Info:\n"), recommendations)
    if selection == "Go Back"
      CLI.reset
      CLI.recommendations(user)
    else
    show_recommendations(selection, user)
    end
  end

  def self.show_recommendations(movie_title, user)
    CLI.reset
    title_header
    movie = Movie.find_by(title: movie_title.downcase)
    puts
    puts message("====== #{movie.title.split.map(&:capitalize).join(' ')}, #{movie.year} ======")
    puts
    puts normal(movie.plot.to_s)
    puts
    puts menu("IMDB Score: #{movie.imdb_score}")
    puts
    input = PROMPT.yes?(normal('Would You Like To Keep This In Your Recommendations?'))
    case input
    when true
      selection = PROMPT.yes?(normal("Would You Like To Favourite This?"))
      case selection
      when true
        Favourite.create(user_id: user.id, movie_id: movie.id)
        CLI.reset
        CLI.recommendations(user)
      when false
        CLI.reset
        CLI.recommendations
      end
    when false
      Recommendation.delete(Recommendation.find_by(user_id: user.id, movie_id: movie.id).id)
      CLI.reset
      CLI.recommendations(user)
    end
  end
end


# user.movies.group('genre').order('count(genre) DESC')
