# Movie Database

[![asciicast](https://asciinema.org/a/OOUJUttKJT6v6Ipgm5OPuAPty.png)](https://asciinema.org/a/OOUJUttKJT6v6Ipgm5OPuAPty)

## About
Movie Database was created by [rgbarker](https://github.com/Ryanbarker0) and [ssong-eu](https://github.com/ssong-eu) as part of the Flatiron School's Mod 1 project. It is a Ruby CLI application that uses the Open Movie Database API and the Google Maps API to provide the user with movie information, as well as, relevant cinema and restaurant information. The [`decisiontree`](https://github.com/igrigorik/decisiontree) gem was used to implement a basic recommender for movie recommendations.

## Instructions
To try it out, simply clone the repository and run `bundle install` in terminal at the repo directory. Once the relevant gems are installed run `rake db:migrate` to initialize the sqlite3 database. Then run `ruby bin/run.rb` and enjoy!


## Features

1. Search for Movies by Titles - information is returned in a Title, Date, Plot format for the most recent movie released with the closest match to user's input.

2. Cinemas Near Me - Based on the user's postcode, it finds cinemas close-by. This is opened in the user's default web browser via Google Maps

3. Recommendations - The facility to provide the user with recommendations for movies based on their recent searches and provide suitable recommendations based on the relevant demographic of all user's searches.

4. Account Management - When a user runs the application for the first time, they will be required to 'Register'. Registering requests information such as a username, password, their postcode, age and gender. The user then has the freedom to amend any information via the account management panel, with the additional freedom to delete their account entirely.

5. Admin - Gives a single admin user full control over resetting and deleting User accounts. Can be accessed through username `superuser` in the login page and the default password is `admin`.

## APIs

1. [OMDB](https://omdbapi.com)
2. Google Maps
3. [getAddress()](https://getaddress.io/) - for postcode validity check
