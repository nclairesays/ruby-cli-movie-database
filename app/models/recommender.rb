require 'decisiontree'
include Style

class Recommender < ActiveRecord::Base

  def self.surprise_me(user)
    if User.all.count > 5 && Search.all.count > 5 && Movie.all.count > 5
      random = Random.new
      chance = random.rand(1.0)
      if chance < 0.4
        labels = ["age", "gender", "genre", "imdb"]
        training = []
        Search.all.each do |s|
          if User.exists?(s.user_id)
            # if User.all.count > 100
            #   average_favourites = Favourite.where(movie_id: s.movie_id).count / Search.where(movie_id: s.movie_id).count
            #   average_total_favourites = Favourite.where(movie_id: s.movie_id).count / Favourite.all.count
            #   average_from_searches = Favourite.where(movie_id: s.movie_id).count / Search.all.count
            #   average_movie_search = Search.where(movie_id: s.movie_id).count / Search.all.count
              imdb = Movie.find(s.movie_id).imdb_score / 10
            #
            #   score = (average_favourites + average_total_favourites + average_from_searches + average_movie_search + imdb) / 5
              training << [User.find(s.user_id).age, User.find(s.user_id).gender, Movie.find(s.movie_id).genre, imdb, s.movie_id]
            # end
          end
        end
        dec_tree = DecisionTree::ID3Tree.new(labels, training, 0, age: :continuous,
          gender: :discrete, genre: :discrete, imdb: :continuous)
          # binding.pry
        dec_tree.train
        data = [user.age, user.gender, user.movies.group('genre').order('count(genre) DESC').limit(1)[0].genre, 0.5]
        pred = dec_tree.predict(data)
        Recommendation.create(user_id: user.id, movie_id: pred)
        show_recommendations(Movie.find(pred).title, user)
      else
        user_genre_recommendation(user)
      end
    else
      user_genre_recommendation(user)
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

  def self.user_genre_recommendation(user)
    genre = user.movies.group('genre').order('count(genre) DESC').limit(1)[0].genre
    movie = Movie.all.where(genre: genre).sample
    Recommendation.create(user_id: user.id, movie_id: movie.id)
    show_recommendations(movie.title, user)
  end

  def self.view_recommendations(user)
    CLI.reset
    CLI.title_header
    recommendations = []
    movies = Recommendation.all.where(user_id: user.id).reverse.take(10).map{|t| t.movie_id}
    movies.uniq.each do |m|
      recommendations << Movie.find(m).title.split.map(&:capitalize).join(' ')
    end
    recommendations << message("Go Back")
    selection = PROMPT.select(normal("Please Select A Movie For More Info:\n"), recommendations)
    if selection == message("Go Back")
      refresh(user)
    else
    show_recommendations(selection, user)
    end
  end

  def self.show_recommendations(movie_title, user)
    CLI.reset
    title_header
    movie = Movie.find_by(title: movie_title.downcase)
    text(movie)
    input = PROMPT.ask('Would You Like To Keep This In Your Recommendations? (Y/N)') do |q|
      q.required true
      q.validate(/\A[y|Y|n|N]\z{1}/, warning('Invalid Input'))
    end
    if input == 'Y' || input == 'y'
      puts
      selection = PROMPT.ask('Would You Like To Favourite This? (Y/N)') do |q|
        q.required true
        q.validate(/\A[y|Y|n|N]\z{1}/, warning('Invalid Input'))
      end
      if selection == 'Y' || input == 'y'
        if Favourite.exists?(user_id: user.id, movie_id: movie.id)
          puts
          puts message("You Have Already Favourited This Movie")
          puts
          PROMPT.keypress(normal("Please Press Space to Continue..."),require: true, keys: [:space])
          refresh(user)
        else
          Favourite.create(user_id: user.id, movie_id: movie.id)
          puts
          puts message('New Favourite Successfully Added.')
          sleep(1.5)
          refresh(user)
        end
      elsif selection == 'N' || 'n'
        refresh(user)
      end
    elsif input == 'N' || input == 'n'
      Recommendation.delete(Recommendation.find_by(user_id: user.id, movie_id: movie.id).id)
      puts
      puts message("This Movie Has Been Successfully Removed From Your Recommendations.")
      sleep(1.5)
      refresh(user)
    end
  end

  def self.refresh(user)
    CLI.reset
    CLI.recommendations(user)
  end

  def self.text(movie)
    puts
    puts message("====== #{movie.title.split.map(&:capitalize).join(' ')}, #{movie.year} ======")
    puts
    puts normal(movie.plot.to_s)
    puts
    puts menu("IMDB Score: #{movie.imdb_score}")
    puts
  end
end


# user.movies.group('genre').order('count(genre) DESC')
