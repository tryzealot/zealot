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

ActiveRecord::Schema.define(version: 20150909034953) do

  create_table "apps", force: :cascade do |t|
    t.integer  "user_id",     limit: 4
    t.string   "name",        limit: 255, null: false
    t.string   "slug",        limit: 255, null: false
    t.string   "identifier",  limit: 255
    t.string   "device_type", limit: 255, null: false
    t.string   "password",    limit: 255
    t.string   "key",         limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "apps", ["device_type"], name: "index_apps_on_device_type", using: :btree
  add_index "apps", ["identifier"], name: "index_apps_on_identifier", using: :btree
  add_index "apps", ["name"], name: "index_apps_on_name", using: :btree
  add_index "apps", ["slug"], name: "index_apps_on_slug", unique: true, using: :btree
  add_index "apps", ["user_id"], name: "index_apps_on_user_id", using: :btree

  create_table "errors", force: :cascade do |t|
    t.string   "usable_type", limit: 255
    t.integer  "usable_id",   limit: 4
    t.text     "class_name",  limit: 65535
    t.text     "message",     limit: 65535
    t.text     "trace",       limit: 65535
    t.text     "target_url",  limit: 65535
    t.text     "referer_url", limit: 65535
    t.text     "params",      limit: 65535
    t.text     "user_agent",  limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ios", force: :cascade do |t|
    t.string   "name",                limit: 255
    t.string   "bundle_id",           limit: 255
    t.string   "profile",             limit: 255
    t.string   "version",             limit: 255
    t.string   "build_version",       limit: 255
    t.string   "username",            limit: 255
    t.string   "email",               limit: 255
    t.string   "project_path",        limit: 255
    t.string   "dsym_uuid",           limit: 255
    t.string   "dsym_file",           limit: 255
    t.string   "last_commit_hash",    limit: 255
    t.string   "last_commit_branch",  limit: 255
    t.string   "last_commit_message", limit: 255
    t.string   "last_commit_author",  limit: 255
    t.string   "last_commit_email",   limit: 255
    t.string   "last_commit_date",    limit: 255
    t.datetime "packaged_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "jspatches", force: :cascade do |t|
    t.integer  "app_id",      limit: 4,     null: false
    t.string   "title",       limit: 255
    t.string   "filename",    limit: 255
    t.string   "min_version", limit: 255
    t.string   "max_version", limit: 255
    t.text     "script",      limit: 65535
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  add_index "jspatches", ["app_id"], name: "index_jspatches_on_app_id", using: :btree
  add_index "jspatches", ["filename"], name: "index_jspatches_on_filename", using: :btree

  create_table "messages", force: :cascade do |t|
    t.integer  "chatroom_id",   limit: 4
    t.integer  "user_id",       limit: 4
    t.string   "chatroom_name", limit: 255
    t.string   "user_name",     limit: 255
    t.string   "message",       limit: 255
    t.datetime "timestamp"
    t.string   "content_type",  limit: 255
    t.string   "file_type",     limit: 255
    t.text     "custom_data",   limit: 65535
    t.text     "file",          limit: 4294967295
    t.string   "im_id",         limit: 255
    t.string   "im_user_id",    limit: 255
    t.string   "im_topic_id",   limit: 255
    t.boolean  "is_deleted",                       default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "messages", ["chatroom_id"], name: "index_messages_on_chatroom_id", using: :btree
  add_index "messages", ["im_id"], name: "index_messages_on_im_id", using: :btree
  add_index "messages", ["im_topic_id"], name: "index_messages_on_im_topic_id", using: :btree
  add_index "messages", ["im_user_id"], name: "index_messages_on_im_user_id", using: :btree
  add_index "messages", ["user_id"], name: "index_messages_on_user_id", using: :btree

  create_table "releases", force: :cascade do |t|
    t.integer  "app_id",          limit: 4,     null: false
    t.string   "channel",         limit: 255
    t.integer  "filesize",        limit: 4
    t.string   "release_version", limit: 255,   null: false
    t.string   "build_version",   limit: 255,   null: false
    t.string   "identifier",      limit: 255,   null: false
    t.integer  "version",         limit: 4
    t.string   "store_url",       limit: 255
    t.string   "icon",            limit: 255
    t.string   "branch",          limit: 255
    t.string   "last_commit",     limit: 255
    t.string   "ci_url",          limit: 255
    t.text     "changelog",       limit: 65535
    t.string   "md5",             limit: 255
    t.string   "file",            limit: 255
    t.text     "extra",           limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "releases", ["app_id", "version"], name: "index_releases_on_app_id_and_version", unique: true, using: :btree
  add_index "releases", ["app_id"], name: "index_releases_on_app_id", using: :btree
  add_index "releases", ["identifier"], name: "index_releases_on_identifier", using: :btree

  create_table "roles", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "roles_users", id: false, force: :cascade do |t|
    t.integer "user_id", limit: 4, null: false
    t.integer "role_id", limit: 4, null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  limit: 255, default: "", null: false
    t.string   "encrypted_password",     limit: 255, default: "", null: false
    t.string   "key",                    limit: 255
    t.string   "secret",                 limit: 255
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          limit: 4,   default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name",                   limit: 255
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["key"], name: "index_users_on_key", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end
