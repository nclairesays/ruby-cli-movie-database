class CreateMoviesTable < ActiveRecord::Migration[5.0]
  def change
    create_table :movies do |t|
      t.string :title
      t.integer :year
      t.string :rated
      t.string :director
      t.string :plot
      t.float :imdb_score
      t.string :genre
    end
  end
end
