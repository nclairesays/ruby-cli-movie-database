require 'decisiontree'

class Recommender < ActiveRecord::Base

  def self.surprise_me(user)
    labels = ["age", "gender", "genre"]
    training = []
    Search.all.each do |s|
      training << [User.find(s.user_id).age, User.find(s.user_id).gender,
        Movie.find(s.movie_id).genre, s.movie_id]
    end


    dec_tree = DecisionTree::ID3Tree.new(labels, training, 0, age: :continuous,
      gender: :discrete, genre: :discrete)


    dec_tree.train

    data = [user.age, user.gender, user.movies.group('genre').order('count(genre) DESC').limit(1)[0].genre]

    pred = dec_tree.predict(data)
    # binding.pry
    # puts pred
    Recommendation.create(user_id: user.id, movie_id: pred)
    CLI.movie_info_basic(Movie.find(pred))
    #generate randint between 0 and 10 if smaller than 7 do by
    # user preference, average age, gender, year of production

    # else do random from all movies

    # user.movies.group('genre').order('count(genre) DESC').limit(1)

  end

  def self.recommend_based_on_genre(genre, user)
    arr = []
    Movie.all.map do |mov|
      if mov.genre == genre
        arr << mov
      end
    end
    arr.compact
    movie = arr.sample
    # binding.pry
    Recommendation.create(user_id: user.id, movie_id: movie.id)
    CLI.movie_info_basic(movie)
  end

  def self.view_recommendations(user)
    movies = Recommendation.all.where('user_id' == user.id).reverse.take(10).map{|t| t.movie_id}
    movies.each do |m|
      CLI.movie_info_basic(Movie.find(m))
    end
  end
end


# user.movies.group('genre').order('count(genre) DESC')
