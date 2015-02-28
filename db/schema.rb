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

ActiveRecord::Schema.define(version: 20150228020637) do

  create_table "apps", force: true do |t|
    t.integer  "user_id"
    t.string   "name",        null: false
    t.string   "slug",        null: false
    t.string   "identifier"
    t.string   "device_type", null: false
    t.string   "password"
    t.string   "key"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "apps", ["device_type"], name: "index_apps_on_device_type", using: :btree
  add_index "apps", ["identifier"], name: "index_apps_on_identifier", using: :btree
  add_index "apps", ["name"], name: "index_apps_on_name", using: :btree
  add_index "apps", ["slug"], name: "index_apps_on_slug", unique: true, using: :btree
  add_index "apps", ["user_id"], name: "index_apps_on_user_id", using: :btree

  create_table "ios", force: true do |t|
    t.string   "name"
    t.string   "bundle_id"
    t.string   "profile"
    t.string   "version"
    t.string   "build_version"
    t.string   "username"
    t.string   "email"
    t.string   "project_path"
    t.string   "dsym_uuid"
    t.string   "dsym_file"
    t.datetime "packaged_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "messages", force: true do |t|
    t.string   "im_id"
    t.string   "im_user_id"
    t.string   "im_topic_id"
    t.integer  "chatroom_id"
    t.string   "chatroom_name"
    t.integer  "user_id"
    t.string   "user_name"
    t.string   "message"
    t.text     "custom_data"
    t.string   "content_type"
    t.string   "file_type"
    t.text     "file"
    t.boolean  "is_deleted",              default: false
    t.datetime "timestamp",     limit: 3
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "messages", ["chatroom_id"], name: "index_messages_on_chatroom_id", using: :btree
  add_index "messages", ["im_id"], name: "index_messages_on_im_id", using: :btree
  add_index "messages", ["im_topic_id"], name: "index_messages_on_im_topic_id", using: :btree
  add_index "messages", ["im_user_id"], name: "index_messages_on_im_user_id", using: :btree
  add_index "messages", ["user_id"], name: "index_messages_on_user_id", using: :btree

  create_table "releases", force: true do |t|
    t.integer  "app_id",          null: false
    t.string   "release_version", null: false
    t.string   "build_version",   null: false
    t.string   "identifier",      null: false
    t.integer  "version"
    t.string   "store_url"
    t.string   "icon"
    t.text     "changelog"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "releases", ["app_id", "version"], name: "index_releases_on_app_id_and_version", unique: true, using: :btree
  add_index "releases", ["app_id"], name: "index_releases_on_app_id", using: :btree
  add_index "releases", ["identifier"], name: "index_releases_on_identifier", using: :btree

  create_table "roles", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "roles_users", id: false, force: true do |t|
    t.integer "user_id", null: false
    t.integer "role_id", null: false
  end

  create_table "users", force: true do |t|
    t.string   "name"
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "key"
    t.string   "secret"
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["key"], name: "index_users_on_key", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end
