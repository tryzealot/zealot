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

ActiveRecord::Schema.define(version: 2019_10_11_034952) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "action_text_rich_texts", force: :cascade do |t|
    t.string "name", null: false
    t.text "body"
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "apps", force: :cascade do |t|
    t.string "name", null: false
    t.string "description"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["name"], name: "index_apps_on_name"
  end

  create_table "apps_users", id: false, force: :cascade do |t|
    t.bigint "app_id", null: false
    t.bigint "user_id", null: false
    t.index ["app_id", "user_id"], name: "index_apps_users_on_app_id_and_user_id"
    t.index ["user_id", "app_id"], name: "index_apps_users_on_user_id_and_app_id"
  end

  create_table "channels", force: :cascade do |t|
    t.bigint "scheme_id"
    t.string "name", null: false
    t.string "slug", null: false
    t.string "bundle_id", default: "*"
    t.string "device_type", null: false
    t.string "git_url"
    t.string "password"
    t.string "key"
    t.index ["bundle_id"], name: "index_channels_on_bundle_id"
    t.index ["device_type"], name: "index_channels_on_device_type"
    t.index ["name"], name: "index_channels_on_name"
    t.index ["scheme_id", "device_type"], name: "index_channels_on_scheme_id_and_device_type"
    t.index ["scheme_id"], name: "index_channels_on_scheme_id"
    t.index ["slug"], name: "index_channels_on_slug", unique: true
  end

  create_table "debug_file_metadata", force: :cascade do |t|
    t.bigint "debug_file_id", null: false
    t.string "uuid"
    t.string "type"
    t.string "object"
    t.jsonb "data", default: "{}", null: false
    t.integer "size"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["debug_file_id"], name: "index_debug_file_metadata_on_debug_file_id"
  end

  create_table "debug_files", force: :cascade do |t|
    t.bigint "app_id"
    t.string "device_type"
    t.string "release_version"
    t.string "build_version"
    t.string "file"
    t.string "checksum"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["app_id"], name: "index_debug_files_on_app_id"
  end

  create_table "permissions", force: :cascade do |t|
    t.bigint "role_id"
    t.string "action"
    t.string "resource"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["role_id"], name: "index_permissions_on_role_id"
  end

  create_table "releases", force: :cascade do |t|
    t.bigint "channel_id"
    t.string "bundle_id", null: false
    t.integer "version", null: false
    t.string "release_version", null: false
    t.string "build_version", null: false
    t.string "release_type"
    t.string "source"
    t.string "branch"
    t.string "git_commit"
    t.string "icon"
    t.string "ci_url"
    t.text "changelog"
    t.string "file"
    t.bigint "size"
    t.text "devices"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["build_version"], name: "index_releases_on_build_version"
    t.index ["bundle_id"], name: "index_releases_on_bundle_id"
    t.index ["channel_id", "version"], name: "index_releases_on_channel_id_and_version", unique: true
    t.index ["channel_id"], name: "index_releases_on_channel_id"
    t.index ["release_type"], name: "index_releases_on_release_type"
    t.index ["release_version", "build_version"], name: "index_releases_on_release_version_and_build_version"
    t.index ["release_version"], name: "index_releases_on_release_version"
    t.index ["source"], name: "index_releases_on_source"
    t.index ["version"], name: "index_releases_on_version"
  end

  create_table "roles", force: :cascade do |t|
    t.string "name"
    t.string "value"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["name"], name: "index_roles_on_name"
    t.index ["value"], name: "index_roles_on_value"
  end

  create_table "roles_users", id: false, force: :cascade do |t|
    t.bigint "role_id", null: false
    t.bigint "user_id", null: false
    t.index ["role_id", "user_id"], name: "index_roles_users_on_role_id_and_user_id"
    t.index ["user_id", "role_id"], name: "index_roles_users_on_user_id_and_role_id"
  end

  create_table "schemes", force: :cascade do |t|
    t.bigint "app_id"
    t.string "name", null: false
    t.index ["app_id"], name: "index_schemes_on_app_id"
    t.index ["name"], name: "index_schemes_on_name"
  end

  create_table "user_providers", force: :cascade do |t|
    t.bigint "user_id"
    t.string "name"
    t.string "uid"
    t.string "token"
    t.integer "expires_at"
    t.boolean "expires"
    t.string "refresh_token"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["name", "uid"], name: "index_user_providers_on_name_and_uid"
    t.index ["user_id"], name: "index_user_providers_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "username"
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "token", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token"
    t.datetime "locked_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "web_hooks", force: :cascade do |t|
    t.bigint "channel_id"
    t.string "url"
    t.text "body"
    t.integer "upload_events", limit: 2
    t.integer "download_events", limit: 2
    t.integer "changelog_events", limit: 2
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["channel_id"], name: "index_web_hooks_on_channel_id"
    t.index ["url"], name: "index_web_hooks_on_url"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "channels", "schemes", on_delete: :cascade
  add_foreign_key "debug_file_metadata", "debug_files"
  add_foreign_key "debug_files", "apps", on_delete: :cascade
  add_foreign_key "permissions", "roles", on_delete: :cascade
  add_foreign_key "releases", "channels", on_delete: :cascade
  add_foreign_key "schemes", "apps", on_delete: :cascade
  add_foreign_key "user_providers", "users", on_delete: :cascade
  add_foreign_key "web_hooks", "channels", on_delete: :cascade
end
