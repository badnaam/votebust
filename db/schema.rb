# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20100925163014) do

  create_table "categories", :force => true do |t|
    t.string   "name"
    t.integer  "vote_topics_count", :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "comments", :force => true do |t|
    t.text     "body",                                          :null => false
    t.datetime "created_at"
    t.integer  "vi_id"
    t.datetime "updated_at"
    t.integer  "vote_topic_id"
    t.integer  "user_id"
    t.boolean  "approved",                    :default => true
    t.string   "user_ip",       :limit => 50
    t.string   "user_agent",    :limit => 50
    t.string   "referrer"
  end

  add_index "comments", ["user_id"], :name => "user_id"
  add_index "comments", ["vote_topic_id"], :name => "vote_topic_id"

  create_table "contact_messages", :force => true do |t|
    t.string   "name"
    t.string   "email"
    t.string   "subject"
    t.text     "body"
    t.integer  "msg_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "friend_invite_messages", :force => true do |t|
    t.string   "message"
    t.text     "emails"
    t.integer  "user_id"
    t.boolean  "sent",       :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "friend_invite_messages", ["user_id"], :name => "user_id"

  create_table "geocode_caches", :force => true do |t|
    t.string   "address"
    t.float    "lat"
    t.float    "lng"
    t.string   "provider",   :limit => 50
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "city"
    t.string   "state"
  end

  add_index "geocode_caches", ["address"], :name => "address"
  add_index "geocode_caches", ["lat"], :name => "lat"
  add_index "geocode_caches", ["lng"], :name => "lng"

  create_table "interests", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.integer  "category_id"
  end

  create_table "notifiers", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "roles", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "rpx_identifiers", :force => true do |t|
    t.string   "identifier",    :null => false
    t.string   "provider_name"
    t.integer  "user_id",       :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "rpx_identifiers", ["identifier"], :name => "index_rpx_identifiers_on_identifier", :unique => true
  add_index "rpx_identifiers", ["user_id"], :name => "index_rpx_identifiers_on_user_id"

  create_table "searches", :force => true do |t|
    t.datetime "created_at"
    t.string   "term"
    t.datetime "updated_at"
  end

  create_table "slugs", :force => true do |t|
    t.string   "name"
    t.integer  "sluggable_id"
    t.integer  "sequence",                     :default => 1, :null => false
    t.string   "sluggable_type", :limit => 40
    t.string   "scope"
    t.datetime "created_at"
  end

  add_index "slugs", ["name", "sluggable_type", "sequence", "scope"], :name => "index_slugs_on_n_s_s_and_s", :unique => true
  add_index "slugs", ["sluggable_id"], :name => "index_slugs_on_sluggable_id"

  create_table "trackings", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "vote_topic_id"
    t.integer  "user_id"
  end

  create_table "users", :force => true do |t|
    t.string   "email"
    t.string   "user_cached_slug"
    t.string   "zip",                 :limit => 5
    t.string   "username"
    t.integer  "sex"
    t.integer  "birth_year"
    t.integer  "voting_power",                       :default => 0
    t.float    "lat"
    t.float    "lng"
    t.integer  "role_id"
    t.integer  "votes_count",                        :default => 0
    t.integer  "p_topics_count",                     :default => 0
    t.integer  "edit_count",                         :default => 0
    t.integer  "trackings_count",                    :default => 0
    t.string   "state",               :limit => 15
    t.string   "city",                :limit => 50
    t.boolean  "update_yes",                         :default => false
    t.boolean  "local_update_yes",                   :default => false
    t.boolean  "active"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "crypted_password"
    t.string   "password_salt"
    t.string   "persistence_token",                                     :null => false
    t.string   "single_access_token",                                   :null => false
    t.string   "perishable_token",                                      :null => false
    t.integer  "login_count",                        :default => 0,     :null => false
    t.integer  "failed_login_count",                 :default => 0,     :null => false
    t.datetime "current_login_at"
    t.datetime "last_login_at"
    t.string   "current_login_ip"
    t.string   "last_login_ip"
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.string   "image_url",           :limit => 300
    t.boolean  "processing",                         :default => true
  end

  add_index "users", ["active"], :name => "active"
  add_index "users", ["city"], :name => "city"
  add_index "users", ["image_file_name"], :name => "image_file_name"
  add_index "users", ["lat"], :name => "lat"
  add_index "users", ["lng"], :name => "lng"
  add_index "users", ["p_topics_count"], :name => "p_topics_count"
  add_index "users", ["role_id"], :name => "role_id"
  add_index "users", ["state"], :name => "state"
  add_index "users", ["trackings_count"], :name => "trackings_count"
  add_index "users", ["user_cached_slug"], :name => "user_cached_slug"
  add_index "users", ["username"], :name => "username"
  add_index "users", ["votes_count"], :name => "votes_count"

  create_table "vote_facets", :force => true do |t|
    t.integer  "vote_topic_id"
    t.integer  "last_update_tv", :default => 0
    t.string   "m"
    t.string   "w"
    t.string   "ag1"
    t.string   "ag2"
    t.string   "ag3"
    t.string   "ag4"
    t.string   "dag"
    t.string   "wl"
    t.string   "ll"
    t.string   "vl"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "vote_facets", ["vote_topic_id"], :name => "vote_topic_id"

  create_table "vote_items", :force => true do |t|
    t.string   "option",        :limit => 150
    t.string   "info"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "vote_topic_id"
    t.integer  "votes_count",                  :default => 0
    t.integer  "male_votes",                   :default => 0
    t.integer  "female_votes",                 :default => 0
    t.integer  "ag_1_v",                       :default => 0
    t.integer  "ag_2_v",                       :default => 0
    t.integer  "ag_3_v",                       :default => 0
    t.integer  "ag_4_v",                       :default => 0
  end

  add_index "vote_items", ["female_votes"], :name => "female_votes"
  add_index "vote_items", ["male_votes"], :name => "male_votes"
  add_index "vote_items", ["vote_topic_id"], :name => "vote_topic_id"

  create_table "vote_topics", :force => true do |t|
    t.text     "topic"
    t.string   "friend_emails",   :limit => 500
    t.string   "status",          :limit => 4,   :default => "p",   :null => false
    t.datetime "published_at"
    t.datetime "created_at"
    t.datetime "expires"
    t.integer  "power_offered",                  :default => 0
    t.datetime "updated_at"
    t.integer  "user_id"
    t.string   "header",          :limit => 200, :default => "",    :null => false
    t.integer  "category_id"
    t.integer  "votes_count",                    :default => 0
    t.integer  "comments_count",                 :default => 0
    t.string   "flags",           :limit => 75
    t.integer  "trackings_count",                :default => 0
    t.boolean  "anon",                           :default => false
    t.boolean  "unan",                           :default => false
  end

  add_index "vote_topics", ["anon"], :name => "unan"
  add_index "vote_topics", ["category_id"], :name => "category_id"
  add_index "vote_topics", ["comments_count"], :name => "comments_count"
  add_index "vote_topics", ["created_at"], :name => "created_at"
  add_index "vote_topics", ["status"], :name => "index_vote_topics_on_status"
  add_index "vote_topics", ["trackings_count"], :name => "trackings_count"
  add_index "vote_topics", ["user_id"], :name => "index_vote_topics_on_user_id"
  add_index "vote_topics", ["votes_count"], :name => "votes_count"

  create_table "votes", :force => true do |t|
    t.string   "city",            :limit => 100
    t.float    "lat"
    t.float    "lng"
    t.string   "state",           :limit => 10
    t.integer  "vote_item_id",                                     :null => false
    t.integer  "vote_topic_id",                                    :null => false
    t.integer  "user_id"
    t.integer  "del",             :limit => 2,   :default => 0
    t.boolean  "never_processed",                :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "votes", ["del"], :name => "del"
  add_index "votes", ["lat"], :name => "lat"
  add_index "votes", ["lng"], :name => "lng"
  add_index "votes", ["user_id"], :name => "fk_voters"
  add_index "votes", ["vote_item_id"], :name => "fk_voteables"
  add_index "votes", ["vote_item_id"], :name => "vote_item_id"
  add_index "votes", ["vote_topic_id"], :name => "vote_topic_id"

end
