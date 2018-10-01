class User < ActiveRecord::Base
  has_many :searches
  has_many :movies, through: :searches
end
