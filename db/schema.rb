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

ActiveRecord::Schema.define(version: 20171222075142) do

  create_table "apps", id: :bigint, default: nil, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer "user_id"
    t.string "name", null: false
    t.string "slug", null: false
    t.string "identifier"
    t.string "device_type", null: false
    t.string "jenkins_job"
    t.string "git_url"
    t.string "password"
    t.string "key"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["device_type"], name: "index_apps_on_device_type"
    t.index ["identifier"], name: "index_apps_on_identifier"
    t.index ["name"], name: "index_apps_on_name"
    t.index ["slug"], name: "index_apps_on_slug", unique: true
    t.index ["user_id"], name: "index_apps_on_user_id"
  end

  create_table "deep_links", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string "name"
    t.string "category"
    t.text "links"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "devices", id: :bigint, default: nil, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string "name"
    t.string "udid"
    t.string "model"
    t.string "platform"
    t.string "device_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["udid"], name: "index_devices_on_udid", unique: true
  end

  create_table "dsyms", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.bigint "app_id"
    t.string "release_version"
    t.string "build_version"
    t.string "file"
    t.string "file_hash"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["app_id"], name: "index_dsyms_on_app_id"
  end

  create_table "pacs", id: :bigint, default: nil, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.string "title"
    t.string "host"
    t.string "port"
    t.text "script"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "permissions", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer "role_id"
    t.string "action"
    t.string "resource"
    t.integer "resource_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "releases", id: :bigint, default: nil, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.bigint "app_id", null: false
    t.bigint "user_id"
    t.string "channel"
    t.integer "filesize"
    t.string "release_version", null: false
    t.string "build_version", null: false
    t.string "identifier", null: false
    t.integer "version"
    t.string "release_type"
    t.string "distribution"
    t.string "store_url"
    t.string "icon"
    t.string "branch"
    t.string "last_commit"
    t.string "ci_url"
    t.text "changelog", limit: 16777215
    t.string "md5"
    t.string "file"
    t.text "devices", limit: 16777215
    t.text "extra", limit: 16777215
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["app_id", "version"], name: "index_releases_on_app_id_and_version", unique: true
    t.index ["app_id"], name: "index_releases_on_app_id"
    t.index ["channel"], name: "index_releases_on_channel"
    t.index ["identifier"], name: "index_releases_on_identifier"
    t.index ["release_type"], name: "index_releases_on_release_type"
    t.index ["release_version"], name: "index_releases_on_release_version"
    t.index ["user_id"], name: "index_releases_on_user_id"
    t.index ["version"], name: "index_releases_on_version"
  end

  create_table "roles", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "roles_users", id: false, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer "user_id", null: false
    t.integer "role_id", null: false
    t.index ["role_id"], name: "role_id"
    t.index ["user_id"], name: "user_id"
  end

  create_table "settings", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string "name", null: false
    t.text "value", null: false
    t.string "note", default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_settings_on_name", unique: true
  end

  create_table "users", id: :bigint, default: nil, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string "name"
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "key"
    t.string "secret"
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["key"], name: "index_users_on_key", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "web_hooks", id: :bigint, default: nil, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.string "url"
    t.integer "app_id"
    t.integer "upload_events"
    t.integer "changelog_events"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["app_id"], name: "index_web_hooks_on_app_id"
    t.index ["url"], name: "index_web_hooks_on_url", length: { url: 191 }
  end

  create_table "wechat_options", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string "wechat_id"
    t.string "key"
    t.string "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["wechat_id", "key"], name: "index_wechat_options_on_wechat_id_and_key", unique: true
    t.index ["wechat_id"], name: "index_wechat_options_on_wechat_id"
  end

  create_table "wechat_sessions", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string "openid", null: false
    t.string "hash_store"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["openid"], name: "index_wechat_sessions_on_openid", unique: true
  end

end
