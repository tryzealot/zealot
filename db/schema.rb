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

ActiveRecord::Schema.define(version: 20170609082000) do

  create_table "apps", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer  "user_id"
    t.string   "name",        null: false
    t.string   "slug",        null: false
    t.string   "identifier"
    t.string   "device_type", null: false
    t.string   "jenkins_job"
    t.string   "git_url"
    t.string   "password"
    t.string   "key"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["device_type"], name: "index_apps_on_device_type", using: :btree
    t.index ["identifier"], name: "index_apps_on_identifier", using: :btree
    t.index ["name"], name: "index_apps_on_name", using: :btree
    t.index ["slug"], name: "index_apps_on_slug", unique: true, using: :btree
    t.index ["user_id"], name: "index_apps_on_user_id", using: :btree
  end

  create_table "devices", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string   "name"
    t.string   "udid"
    t.string   "model"
    t.string   "platform"
    t.string   "device_type"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.index ["udid"], name: "index_devices_on_udid", unique: true, using: :btree
  end

  create_table "jspatches", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer  "app_id",                    null: false
    t.string   "title"
    t.string   "app_version"
    t.text     "script",      limit: 65535
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.index ["app_id", "app_version"], name: "index_jspatches_on_app_id_and_app_version", using: :btree
    t.index ["app_id"], name: "index_jspatches_on_app_id", using: :btree
  end

  create_table "pacs", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.string   "title"
    t.string   "host"
    t.string   "port"
    t.text     "script",     limit: 65535
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  create_table "permissions", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer  "role_id"
    t.string   "action"
    t.string   "resource"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "releases", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer  "app_id",                        null: false
    t.string   "channel"
    t.integer  "filesize"
    t.string   "release_version",               null: false
    t.string   "build_version",                 null: false
    t.string   "identifier",                    null: false
    t.integer  "version"
    t.string   "release_type"
    t.string   "distribution"
    t.string   "store_url"
    t.string   "icon"
    t.string   "branch"
    t.string   "last_commit"
    t.string   "ci_url"
    t.text     "changelog",       limit: 65535
    t.string   "md5"
    t.string   "file"
    t.text     "devices",         limit: 65535
    t.text     "extra",           limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["app_id", "version"], name: "index_releases_on_app_id_and_version", unique: true, using: :btree
    t.index ["app_id"], name: "index_releases_on_app_id", using: :btree
    t.index ["channel"], name: "index_releases_on_channel", using: :btree
    t.index ["identifier"], name: "index_releases_on_identifier", using: :btree
    t.index ["release_type"], name: "index_releases_on_release_type", using: :btree
    t.index ["release_version"], name: "index_releases_on_release_version", using: :btree
    t.index ["version"], name: "index_releases_on_version", using: :btree
  end

  create_table "roles", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "roles_users", id: false, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer "user_id", null: false
    t.integer "role_id", null: false
  end

  create_table "user_apps", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer "user_id"
    t.integer "app_id"
    t.index ["user_id", "app_id"], name: "index_user_apps_on_user_id_and_app_id", using: :btree
  end

  create_table "users", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
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
    t.string   "name"
    t.index ["email"], name: "index_users_on_email", unique: true, using: :btree
    t.index ["key"], name: "index_users_on_key", unique: true, using: :btree
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  end

  create_table "versions", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string   "item_type",                         null: false
    t.integer  "item_id",                           null: false
    t.string   "event",                             null: false
    t.string   "whodunnit"
    t.text     "object",         limit: 4294967295
    t.datetime "created_at"
    t.text     "object_changes", limit: 4294967295
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id", using: :btree
  end

  create_table "web_hooks", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.string   "url"
    t.integer  "app_id"
    t.integer  "upload_events"
    t.integer  "changelog_events"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.index ["app_id"], name: "index_web_hooks_on_app_id", using: :btree
    t.index ["url"], name: "index_web_hooks_on_url", length: { url: 191 }, using: :btree
  end

  create_table "wechat_options", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string   "wechat_id"
    t.string   "key"
    t.string   "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["wechat_id", "key"], name: "index_wechat_options_on_wechat_id_and_key", unique: true, using: :btree
    t.index ["wechat_id"], name: "index_wechat_options_on_wechat_id", using: :btree
  end

  create_table "wechat_sessions", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string   "openid",     null: false
    t.string   "hash_store"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["openid"], name: "index_wechat_sessions_on_openid", unique: true, using: :btree
  end

end
