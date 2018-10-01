class Movie < ActiveRecord::Base
  has_many :searches
  has_many :users, through: :searches
end
