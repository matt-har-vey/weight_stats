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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130804213635) do

  create_table "users", :force => true do |t|
    t.string   "fitbit_id",           :null => false
    t.string   "access_token_value"
    t.string   "access_token_secret"
    t.datetime "weights_updated_at"
    t.date     "weights_start"
    t.date     "weights_end"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
  end

  create_table "weights", :force => true do |t|
    t.integer  "user_id",     :null => false
    t.datetime "time",        :null => false
    t.float    "weight",      :null => false
    t.float    "fat_percent", :null => false
    t.string   "log_id",      :null => false
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "weights", ["user_id", "time"], :name => "index_weights_on_user_id_and_time", :unique => true
  add_index "weights", ["user_id"], :name => "index_weights_on_user_id"

end
