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

ActiveRecord::Schema.define(:version => 20130108230319) do

  create_table "age_groups", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "boards", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.integer  "category_id"
    t.integer  "age_group_id"
    t.integer  "user_id"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
    t.string   "cover"
  end

  add_index "boards", ["age_group_id"], :name => "index_boards_on_age_group_id"
  add_index "boards", ["category_id"], :name => "index_boards_on_category_id"
  add_index "boards", ["user_id"], :name => "index_boards_on_user_id"

  create_table "categories", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "pins", :force => true do |t|
    t.string   "name"
    t.string   "kind"
    t.string   "url"
    t.decimal  "price",        :precision => 10, :scale => 2
    t.integer  "user_id"
    t.integer  "board_id"
    t.integer  "category_id"
    t.integer  "age_group_id"
    t.integer  "via_id"
    t.datetime "created_at",                                  :null => false
    t.datetime "updated_at",                                  :null => false
    t.string   "description"
    t.string   "image"
  end

  add_index "pins", ["age_group_id"], :name => "index_pins_on_age_group_id"
  add_index "pins", ["board_id"], :name => "index_pins_on_board_id"
  add_index "pins", ["category_id"], :name => "index_pins_on_category_id"
  add_index "pins", ["user_id"], :name => "index_pins_on_user_id"
  add_index "pins", ["via_id"], :name => "index_pins_on_via_id"

  create_table "users", :force => true do |t|
    t.string   "username",               :default => "", :null => false
    t.string   "email",                  :default => "", :null => false
    t.string   "encrypted_password",     :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
    t.string   "provider"
    t.string   "uid"
    t.string   "avatar"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
