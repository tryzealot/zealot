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

ActiveRecord::Schema.define(version: 20160503060636) do

  create_table "apps", force: :cascade do |t|
    t.integer  "user_id",     limit: 4
    t.string   "name",        limit: 255,                     null: false
    t.string   "slug",        limit: 255,                     null: false
    t.string   "identifier",  limit: 255
    t.string   "device_type", limit: 255,                     null: false
    t.string   "jenkins_job", limit: 255
    t.string   "git_url",     limit: 255
    t.string   "git_branch",  limit: 255, default: "develop"
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
    t.integer  "usable_id",   limit: 4
    t.string   "usable_type", limit: 255
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

  create_table "groups", force: :cascade do |t|
    t.integer "qyer_id", limit: 4,                        null: false
    t.string  "im_id",   limit: 255,                      null: false
    t.string  "name",    limit: 255,                      null: false
    t.string  "type",    limit: 255, default: "chatroom"
  end

  add_index "groups", ["im_id"], name: "index_groups_on_im_id", using: :btree
  add_index "groups", ["name"], name: "index_groups_on_name", using: :btree
  add_index "groups", ["qyer_id"], name: "index_groups_on_qyer_id", using: :btree

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
    t.string   "app_version", limit: 255
    t.text     "script",      limit: 65535
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  add_index "jspatches", ["app_id", "app_version"], name: "index_jspatches_on_app_id_and_app_version", using: :btree
  add_index "jspatches", ["app_id"], name: "index_jspatches_on_app_id", using: :btree

  create_table "messages", force: :cascade do |t|
    t.integer  "group_id",     limit: 4,                               null: false
    t.integer  "user_id",      limit: 4
    t.string   "group_name",   limit: 255
    t.string   "group_type",   limit: 255,        default: "chatroom"
    t.string   "user_name",    limit: 255
    t.string   "message",      limit: 255
    t.datetime "timestamp"
    t.string   "content_type", limit: 255
    t.string   "file_type",    limit: 255
    t.text     "custom_data",  limit: 65535
    t.text     "file",         limit: 4294967295
    t.string   "im_id",        limit: 255
    t.string   "im_user_id",   limit: 255
    t.string   "im_topic_id",  limit: 255
    t.boolean  "is_deleted",                      default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "messages", ["im_id"], name: "index_messages_on_im_id", using: :btree
  add_index "messages", ["im_topic_id"], name: "index_messages_on_im_topic_id", using: :btree
  add_index "messages", ["im_user_id"], name: "index_messages_on_im_user_id", using: :btree
  add_index "messages", ["user_id"], name: "index_messages_on_user_id", using: :btree

  create_table "pacs", force: :cascade do |t|
    t.string   "title",      limit: 255
    t.integer  "is_enabled", limit: 4,     default: 1
    t.string   "host",       limit: 255
    t.string   "port",       limit: 255
    t.text     "script",     limit: 65535
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
  end

  create_table "permissions", force: :cascade do |t|
    t.integer  "role_id",    limit: 4
    t.string   "action",     limit: 255
    t.string   "resource",   limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

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

  create_table "user_apps", force: :cascade do |t|
    t.integer "user_id", limit: 4
    t.integer "app_id",  limit: 4
  end

  add_index "user_apps", ["user_id", "app_id"], name: "index_user_apps_on_user_id_and_app_id", using: :btree

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

  create_table "versions", force: :cascade do |t|
    t.string   "item_type",      limit: 255,        null: false
    t.integer  "item_id",        limit: 4,          null: false
    t.string   "event",          limit: 255,        null: false
    t.string   "whodunnit",      limit: 255
    t.text     "object",         limit: 4294967295
    t.datetime "created_at"
    t.text     "object_changes", limit: 4294967295
  end

  add_index "versions", ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id", using: :btree

  create_table "web_hooks", force: :cascade do |t|
    t.string   "url",              limit: 255
    t.integer  "app_id",           limit: 4
    t.integer  "upload_events",    limit: 4
    t.integer  "changelog_events", limit: 4
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
  end

  add_index "web_hooks", ["app_id"], name: "index_web_hooks_on_app_id", using: :btree
  add_index "web_hooks", ["url"], name: "index_web_hooks_on_url", using: :btree

end
