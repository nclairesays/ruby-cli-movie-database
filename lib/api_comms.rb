require 'rest-client'
require 'json'
require 'pry'
include Style


##### Makes an API call based on the user input "title"
##### Saves the movie information to the database and
##### and returns the relevant movie object
def get_movie_from_api(user_input)

  url = "http://www.omdbapi.com/?apikey=5c74cb50&t=#{user_input}"

  response_string = RestClient.get(url)
  response = JSON.parse(response_string)

  if response["Title"] != nil
    Movie.create(title: response["Title"].downcase,
              year: response["Year"],
              rated: response["Rated"],
              director: response["Director"],
              plot: response["Plot"],
              imdb_score: response["imdbRating"],
              genre: response["Genre"].split(',').first.downcase)
  end

  # Genre.new(genre: response["Genre"])
  # Actor.new() need to split and iterate and split
end

def get_postcode_from_api(user_postcode)

  url = "https://api.getAddress.io/find/#{user_postcode}?api-key=W7MxRjU3wU-ZRq1XgMY0rg15574"

    begin
      RestClient.get(url)
    rescue
    puts
    puts warning("Please Enter a Valid UK Postcode.")
    puts
    User.validate_postcode
    end
  user_postcode
end

  # response = JSON.parse(response_string)
