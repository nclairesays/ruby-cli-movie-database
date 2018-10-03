require 'decisiontree'

class Recommender < ActiveRecord::Base

  def self.surprise_me(user)
    random = Random.new
    chance = random.rand(1.0)

    if chance < 0.8
      labels = ["age", "gender", "genre"]
      training = []
      Search.all.each do |s|
        if User.exists?(s.user_id)
          training << [User.find(s.user_id).age, User.find(s.user_id).gender,
            Movie.find(s.movie_id).genre, s.movie_id]
        end
      end
      dec_tree = DecisionTree::ID3Tree.new(labels, training, 0, age: :continuous,
        gender: :discrete, genre: :discrete)
      dec_tree.train
      data = [user.age, user.gender, user.movies.group('genre').order('count(genre) DESC').limit(1)[0].genre]
      pred = dec_tree.predict(data)
      Recommendation.create(user_id: user.id, movie_id: pred)
      table = TTY::Table.new []
      renderer = TTY::Table::Renderer::Basic.new(table)
      table << CLI.movie_info_basic(Movie.find(pred))
      puts renderer.render
    else
      genre = user.movies.group('genre').order('count(genre) DESC').limit(1)[0].genre
      movie = Movie.all.where(genre: genre).sample
      Recommendation.create(user_id: user.id, movie_id: movie.id)
      table = TTY::Table.new []
      renderer = TTY::Table::Renderer::Basic.new(table)
      table << CLI.movie_info_basic(movie)
      puts renderer.render
    end
  end

  def self.recommend_based_on_genre(genre, user)
    movie = Movie.all.where(genre: genre).sample
    Recommendation.create(user_id: user.id, movie_id: movie.id)
    table = TTY::Table.new []
    renderer = TTY::Table::Renderer::Basic.new(table)
    table << CLI.movie_info_basic(movie)
    puts renderer.render
  end

  def self.view_recommendations(user)
    movies = Recommendation.all.where(user_id: user.id).reverse.take(10).map{|t| t.movie_id}
    table = TTY::Table.new []
    renderer = TTY::Table::Renderer::Basic.new(table)
    movies.each do |m|
      table << CLI.movie_info_basic(Movie.find(m))
    end
    puts renderer.render
  end
end


# user.movies.group('genre').order('count(genre) DESC')
