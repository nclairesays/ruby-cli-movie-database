# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20181005094242) do

  create_table "admins", force: :cascade do |t|
    t.string "username"
    t.string "password"
  end

  create_table "favourites", force: :cascade do |t|
    t.integer "user_id"
    t.integer "movie_id"
  end

  create_table "movies", force: :cascade do |t|
    t.string  "title"
    t.integer "year"
    t.string  "rated"
    t.string  "director"
    t.string  "plot"
    t.float   "imdb_score"
    t.string  "genre"
  end

  create_table "recommendations", force: :cascade do |t|
    t.integer "user_id"
    t.integer "movie_id"
  end

  create_table "searches", force: :cascade do |t|
    t.integer "user_id"
    t.integer "movie_id"
  end

  create_table "users", force: :cascade do |t|
    t.string  "username"
    t.string  "password"
    t.string  "location"
    t.integer "age"
    t.string  "gender"
    t.integer "password_flag"
  end

end
