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

ActiveRecord::Schema.define(:version => 20130725202520) do

  create_table "age_groups", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "boards", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.integer  "category_id"
    t.integer  "user_id"
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
    t.string   "cover"
    t.string   "slug"
    t.integer  "comments_count",  :default => 0
    t.integer  "pins_count",      :default => 0
    t.integer  "position"
    t.integer  "cover_source_id"
    t.integer  "trend_position",  :default => 0
  end

  add_index "boards", ["category_id"], :name => "index_boards_on_category_id"
  add_index "boards", ["slug"], :name => "index_boards_on_slug"
  add_index "boards", ["trend_position"], :name => "index_boards_on_trend_position"
  add_index "boards", ["user_id", "position"], :name => "index_boards_on_user_id_and_position"

  create_table "categories", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "categories", ["name"], :name => "index_categories_on_name", :unique => true

  create_table "comments", :force => true do |t|
    t.text     "body"
    t.integer  "user_id"
    t.integer  "commentable_id"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
    t.string   "commentable_type"
  end

  add_index "comments", ["commentable_type", "commentable_id"], :name => "index_comments_on_commentable_type_and_commentable_id"
  add_index "comments", ["user_id"], :name => "index_comments_on_user_id"

  create_table "feedbacks", :force => true do |t|
    t.text     "body"
    t.string   "email"
    t.integer  "user_id"
    t.string   "user_agent"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "friendly_id_slugs", :force => true do |t|
    t.string   "slug",                         :null => false
    t.integer  "sluggable_id",                 :null => false
    t.string   "sluggable_type", :limit => 40
    t.datetime "created_at"
  end

  add_index "friendly_id_slugs", ["slug", "sluggable_type"], :name => "index_friendly_id_slugs_on_slug_and_sluggable_type", :unique => true
  add_index "friendly_id_slugs", ["sluggable_id"], :name => "index_friendly_id_slugs_on_sluggable_id"
  add_index "friendly_id_slugs", ["sluggable_type"], :name => "index_friendly_id_slugs_on_sluggable_type"

  create_table "imports", :force => true do |t|
    t.integer  "user_id"
    t.string   "source"
    t.integer  "attempted"
    t.integer  "completed"
    t.string   "user_agent"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "pins", :force => true do |t|
    t.string   "kind"
    t.string   "url"
    t.decimal  "price",                              :precision => 10, :scale => 2
    t.integer  "user_id"
    t.integer  "board_id"
    t.integer  "category_id"
    t.integer  "age_group_id"
    t.integer  "via_id"
    t.datetime "created_at",                                                                       :null => false
    t.datetime "updated_at",                                                                       :null => false
    t.string   "description",        :limit => 1024
    t.string   "image"
    t.integer  "original_poster_id"
    t.integer  "comments_count",                                                    :default => 0
    t.string   "domain"
    t.string   "via_url"
    t.integer  "repinned_from_id"
    t.integer  "repins_count",                                                      :default => 0
    t.string   "uuid",               :limit => 36
    t.integer  "trend_position",                                                    :default => 0
    t.integer  "import_id"
    t.string   "source_url"
  end

  add_index "pins", ["age_group_id"], :name => "index_pins_on_age_group_id"
  add_index "pins", ["board_id"], :name => "index_pins_on_board_id"
  add_index "pins", ["category_id"], :name => "index_pins_on_category_id"
  add_index "pins", ["trend_position"], :name => "index_pins_on_trend_position"
  add_index "pins", ["url"], :name => "index_pins_on_url"
  add_index "pins", ["user_id"], :name => "index_pins_on_user_id"
  add_index "pins", ["uuid"], :name => "index_pins_on_uuid", :unique => true
  add_index "pins", ["via_id"], :name => "index_pins_on_via_id"

  create_table "users", :force => true do |t|
    t.string   "username",               :default => "",    :null => false
    t.string   "email",                  :default => "",    :null => false
    t.string   "encrypted_password",     :default => "",    :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                                :null => false
    t.datetime "updated_at",                                :null => false
    t.string   "provider"
    t.string   "uid"
    t.string   "avatar"
    t.string   "cover_image"
    t.integer  "kids"
    t.text     "bio"
    t.boolean  "teacher",                :default => false
    t.string   "teacher_grade"
    t.string   "teacher_subject"
    t.boolean  "got_bookmarklet",        :default => false
    t.string   "website"
    t.boolean  "featured",               :default => false
    t.text     "featured_bio"
    t.string   "facebook_account"
    t.string   "twitter_account"
    t.boolean  "admin",                  :default => false
    t.integer  "featured_pin_id"
    t.integer  "failed_attempts",        :default => 0
    t.string   "unlock_token"
    t.datetime "locked_at"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["featured"], :name => "index_users_on_featured"
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true
  add_index "users", ["unlock_token"], :name => "index_users_on_unlock_token", :unique => true
  add_index "users", ["username"], :name => "index_users_on_username"

end
