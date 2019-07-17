# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2019_07_17_093259) do

  create_table "apps", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
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

  create_table "deep_links", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.string "category"
    t.text "links"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "dsyms", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.bigint "app_id"
    t.string "release_version"
    t.string "build_version"
    t.string "file"
    t.string "file_hash"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["app_id"], name: "index_dsyms_on_app_id"
  end

  create_table "pacs", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "title"
    t.string "host"
    t.string "port"
    t.text "script"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "permissions", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "role_id"
    t.string "action"
    t.string "resource"
    t.integer "resource_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "releases", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "app_id", null: false
    t.bigint "user_id"
    t.string "channel"
    t.integer "filesize"
    t.string "release_version", null: false
    t.string "build_version", null: false
    t.string "identifier", null: false
    t.integer "version"
    t.string "release_type"
    t.string "icon"
    t.string "branch"
    t.string "last_commit"
    t.string "ci_url"
    t.text "changelog", size: :medium
    t.string "file"
    t.text "devices", size: :medium
    t.text "extra", size: :medium
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

  create_table "roles", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.string "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "roles_users", id: false, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "role_id", null: false
    t.index ["role_id"], name: "role_id"
    t.index ["user_id"], name: "user_id"
  end

  create_table "user_providers", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.bigint "user_id"
    t.string "uid"
    t.string "token"
    t.integer "expires_at"
    t.boolean "expires"
    t.string "refresh_token"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name", "uid"], name: "index_user_providers_on_name_and_uid"
    t.index ["user_id"], name: "index_user_providers_on_user_id"
  end

  create_table "users", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
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
    t.string "activation_token"
    t.datetime "actived_at"
    t.datetime "activation_sent_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["activation_token"], name: "index_users_on_activation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["key"], name: "index_users_on_key", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "web_hooks", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "url"
    t.integer "app_id"
    t.integer "upload_events"
    t.integer "changelog_events"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["app_id"], name: "index_web_hooks_on_app_id"
    t.index ["url"], name: "index_web_hooks_on_url", length: 191
  end

end
