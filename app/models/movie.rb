class Movie < ActiveRecord::Base
  has_many :searches
  has_many :recommendations
  has_many :favourites
  has_many :users, through: :searches
end
