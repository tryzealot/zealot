# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2024_02_23_040132) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "apple_keys", force: :cascade do |t|
    t.string "issuer_id", null: false
    t.string "key_id", null: false
    t.string "filename", null: false
    t.string "private_key", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["checksum"], name: "index_apple_keys_on_checksum"
    t.index ["issuer_id"], name: "index_apple_keys_on_issuer_id"
    t.index ["key_id"], name: "index_apple_keys_on_key_id"
  end

  create_table "apple_keys_devices", id: false, force: :cascade do |t|
    t.bigint "apple_key_id", null: false
    t.bigint "device_id", null: false
    t.index ["apple_key_id", "device_id"], name: "index_apple_keys_devices_on_apple_key_id_and_device_id"
    t.index ["device_id", "apple_key_id"], name: "index_apple_keys_devices_on_device_id_and_apple_key_id"
  end

  create_table "apple_teams", force: :cascade do |t|
    t.bigint "apple_key_id"
    t.string "team_id"
    t.string "name", null: false
    t.string "display_name", default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["apple_key_id"], name: "index_apple_teams_on_apple_key_id"
  end

  create_table "apps", force: :cascade do |t|
    t.string "name", null: false
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_apps_on_name"
  end

  create_table "apps_users", id: false, force: :cascade do |t|
    t.bigint "app_id", null: false
    t.bigint "user_id", null: false
    t.index ["app_id", "user_id"], name: "index_apps_users_on_app_id_and_user_id"
    t.index ["user_id", "app_id"], name: "index_apps_users_on_user_id_and_app_id"
  end

  create_table "backups", force: :cascade do |t|
    t.string "key", null: false
    t.string "schedule", null: false
    t.boolean "enabled_database", default: true
    t.integer "enabled_apps", default: [], array: true
    t.integer "max_keeps", default: -1
    t.string "notification"
    t.boolean "enabled"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_backups_on_key"
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
    t.index ["slug"], name: "index_channels_on_slug", unique: true
  end

  create_table "channels_web_hooks", id: false, force: :cascade do |t|
    t.bigint "channel_id", null: false
    t.bigint "web_hook_id", null: false
    t.datetime "created_at", precision: nil
    t.index ["channel_id", "web_hook_id"], name: "index_channels_web_hooks_on_channel_id_and_web_hook_id"
    t.index ["web_hook_id", "channel_id"], name: "index_channels_web_hooks_on_web_hook_id_and_channel_id"
  end

  create_table "debug_file_metadata", force: :cascade do |t|
    t.bigint "debug_file_id", null: false
    t.string "uuid"
    t.string "type"
    t.string "object"
    t.jsonb "data", default: {}, null: false
    t.integer "size"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["debug_file_id"], name: "index_debug_file_metadata_on_debug_file_id"
  end

  create_table "debug_files", force: :cascade do |t|
    t.bigint "app_id"
    t.string "device_type"
    t.string "release_version"
    t.string "build_version"
    t.string "file"
    t.string "checksum"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["app_id", "device_type"], name: "index_debug_files_on_app_id_and_device_type"
    t.index ["app_id"], name: "index_debug_files_on_app_id"
    t.index ["id", "device_type"], name: "index_debug_files_on_id_and_device_type"
  end

  create_table "devices", force: :cascade do |t|
    t.string "udid", null: false
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "model"
    t.string "platform"
    t.string "status"
    t.string "device_id"
    t.index ["udid"], name: "index_devices_on_udid"
  end

  create_table "devices_releases", id: false, force: :cascade do |t|
    t.bigint "release_id", null: false
    t.bigint "device_id", null: false
    t.index ["device_id", "release_id"], name: "index_devices_releases_on_device_id_and_release_id"
    t.index ["release_id", "device_id"], name: "index_devices_releases_on_release_id_and_device_id"
  end

  create_table "good_job_batches", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "description"
    t.jsonb "serialized_properties"
    t.text "on_finish"
    t.text "on_success"
    t.text "on_discard"
    t.text "callback_queue_name"
    t.integer "callback_priority"
    t.datetime "enqueued_at"
    t.datetime "discarded_at"
    t.datetime "finished_at"
  end

  create_table "good_job_executions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "active_job_id", null: false
    t.text "job_class"
    t.text "queue_name"
    t.jsonb "serialized_params"
    t.datetime "scheduled_at"
    t.datetime "finished_at"
    t.text "error"
    t.integer "error_event", limit: 2
    t.index ["active_job_id", "created_at"], name: "index_good_job_executions_on_active_job_id_and_created_at"
  end

  create_table "good_job_processes", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "state"
  end

  create_table "good_job_settings", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "key"
    t.jsonb "value"
    t.index ["key"], name: "index_good_job_settings_on_key", unique: true
  end

  create_table "good_jobs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.text "queue_name"
    t.integer "priority"
    t.jsonb "serialized_params"
    t.datetime "scheduled_at"
    t.datetime "performed_at"
    t.datetime "finished_at"
    t.text "error"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "active_job_id"
    t.text "concurrency_key"
    t.text "cron_key"
    t.uuid "retried_good_job_id"
    t.datetime "cron_at"
    t.uuid "batch_id"
    t.uuid "batch_callback_id"
    t.boolean "is_discrete"
    t.integer "executions_count"
    t.text "job_class"
    t.integer "error_event", limit: 2
    t.index ["active_job_id", "created_at"], name: "index_good_jobs_on_active_job_id_and_created_at"
    t.index ["active_job_id"], name: "index_good_jobs_on_active_job_id"
    t.index ["batch_callback_id"], name: "index_good_jobs_on_batch_callback_id", where: "(batch_callback_id IS NOT NULL)"
    t.index ["batch_id"], name: "index_good_jobs_on_batch_id", where: "(batch_id IS NOT NULL)"
    t.index ["concurrency_key"], name: "index_good_jobs_on_concurrency_key_when_unfinished", where: "(finished_at IS NULL)"
    t.index ["cron_key", "created_at"], name: "index_good_jobs_on_cron_key_and_created_at"
    t.index ["cron_key", "cron_at"], name: "index_good_jobs_on_cron_key_and_cron_at", unique: true
    t.index ["finished_at"], name: "index_good_jobs_jobs_on_finished_at", where: "((retried_good_job_id IS NULL) AND (finished_at IS NOT NULL))"
    t.index ["priority", "created_at"], name: "index_good_jobs_jobs_on_priority_created_at_when_unfinished", order: { priority: "DESC NULLS LAST" }, where: "(finished_at IS NULL)"
    t.index ["queue_name", "scheduled_at"], name: "index_good_jobs_on_queue_name_and_scheduled_at", where: "(finished_at IS NULL)"
    t.index ["scheduled_at"], name: "index_good_jobs_on_scheduled_at", where: "(finished_at IS NULL)"
  end

  create_table "metadata", force: :cascade do |t|
    t.bigint "release_id"
    t.bigint "user_id"
    t.string "device", null: false
    t.string "name"
    t.string "release_version"
    t.string "build_version"
    t.string "bundle_id"
    t.integer "size"
    t.string "min_sdk_version"
    t.string "target_sdk_version"
    t.jsonb "url_schemes", default: [], null: false
    t.jsonb "activities", default: [], null: false
    t.jsonb "services", default: [], null: false
    t.jsonb "permissions", default: [], null: false
    t.jsonb "features", default: [], null: false
    t.string "release_type"
    t.jsonb "mobileprovision", default: {}, null: false
    t.jsonb "developer_certs", default: [], null: false
    t.jsonb "entitlements", default: {}, null: false
    t.jsonb "devices", default: [], null: false
    t.jsonb "capabilities", default: [], null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "platform"
    t.jsonb "deep_links", default: [], null: false
    t.index ["checksum"], name: "index_metadata_on_checksum"
    t.index ["release_id"], name: "index_metadata_on_release_id"
    t.index ["user_id"], name: "index_metadata_on_user_id"
  end

  create_table "releases", force: :cascade do |t|
    t.bigint "channel_id"
    t.string "bundle_id"
    t.integer "version", null: false
    t.string "release_version"
    t.string "build_version"
    t.string "release_type"
    t.string "source"
    t.string "branch"
    t.string "git_commit"
    t.string "icon"
    t.string "ci_url"
    t.jsonb "changelog", null: false
    t.string "file"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "custom_fields", default: [], null: false
    t.string "name"
    t.string "device_type"
    t.index ["build_version"], name: "index_releases_on_build_version"
    t.index ["bundle_id"], name: "index_releases_on_bundle_id"
    t.index ["channel_id", "version"], name: "index_releases_on_channel_id_and_version", unique: true
    t.index ["release_type"], name: "index_releases_on_release_type"
    t.index ["release_version", "build_version"], name: "index_releases_on_release_version_and_build_version"
    t.index ["source"], name: "index_releases_on_source"
    t.index ["version"], name: "index_releases_on_version"
  end

  create_table "schemes", force: :cascade do |t|
    t.bigint "app_id"
    t.string "name", null: false
    t.boolean "new_build_callout", default: true
    t.integer "retained_builds", default: 0, null: false
    t.index ["app_id"], name: "index_schemes_on_app_id"
    t.index ["name"], name: "index_schemes_on_name"
  end

  create_table "settings", force: :cascade do |t|
    t.string "var", null: false
    t.text "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["var"], name: "index_settings_on_var", unique: true
  end

  create_table "solid_cache_entries", force: :cascade do |t|
    t.binary "key", null: false
    t.binary "value", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_solid_cache_entries_on_key", unique: true
  end

  create_table "user_providers", force: :cascade do |t|
    t.bigint "user_id"
    t.string "name"
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

  create_table "users", force: :cascade do |t|
    t.string "username"
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "token", default: "", null: false
    t.integer "role", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at", precision: nil
    t.datetime "remember_created_at", precision: nil
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at", precision: nil
    t.datetime "last_sign_in_at", precision: nil
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at", precision: nil
    t.datetime "confirmation_sent_at", precision: nil
    t.string "unconfirmed_email"
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token"
    t.datetime "locked_at", precision: nil
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "web_hooks", force: :cascade do |t|
    t.bigint "channel_id"
    t.string "url"
    t.text "body"
    t.integer "upload_events", limit: 2
    t.integer "download_events", limit: 2
    t.integer "changelog_events", limit: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["channel_id"], name: "index_web_hooks_on_channel_id"
    t.index ["url"], name: "index_web_hooks_on_url"
  end

  add_foreign_key "apple_teams", "apple_keys", on_delete: :cascade
  add_foreign_key "channels", "schemes", on_delete: :cascade
  add_foreign_key "debug_file_metadata", "debug_files"
  add_foreign_key "debug_files", "apps", on_delete: :cascade
  add_foreign_key "metadata", "releases", on_delete: :cascade
  add_foreign_key "metadata", "users", on_delete: :cascade
  add_foreign_key "releases", "channels", on_delete: :cascade
  add_foreign_key "schemes", "apps", on_delete: :cascade
  add_foreign_key "user_providers", "users", on_delete: :cascade
  add_foreign_key "web_hooks", "channels", on_delete: :cascade
end
