# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20180611155707) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "asian_handicaps", force: :cascade do |t|
    t.string   "name"
    t.string   "home_team"
    t.string   "away_team"
    t.string   "payout"
    t.integer  "odd_match_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  add_index "asian_handicaps", ["odd_match_id"], name: "index_asian_handicaps_on_odd_match_id", using: :btree

  create_table "engine_states", force: :cascade do |t|
    t.string   "name"
    t.boolean  "started"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "odd_matches", force: :cascade do |t|
    t.string   "odd_id"
    t.string   "country"
    t.string   "league"
    t.string   "home_team"
    t.string   "away_team"
    t.boolean  "in_play"
    t.string   "time"
    t.string   "score"
    t.string   "homewin"
    t.string   "draw"
    t.string   "awaywin"
    t.string   "bs"
    t.string   "url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "match_day"
  end

  add_index "odd_matches", ["odd_id"], name: "index_odd_matches_on_odd_id", using: :btree

end
