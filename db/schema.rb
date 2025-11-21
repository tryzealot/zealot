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

ActiveRecord::Schema[8.1].define(version: 2025_11_21_145052) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pg_stat_statements"

  create_table "apple_keys", force: :cascade do |t|
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "issuer_id", null: false
    t.string "key_id", null: false
    t.string "private_key", null: false
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
    t.datetime "created_at", null: false
    t.string "display_name", default: "", null: false
    t.string "name", null: false
    t.string "team_id"
    t.datetime "updated_at", null: false
    t.index ["apple_key_id"], name: "index_apple_teams_on_apple_key_id"
  end

  create_table "apps", force: :cascade do |t|
    t.boolean "archived", default: false, null: false
    t.datetime "created_at", null: false
    t.string "description"
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_apps_on_name"
  end

  create_table "apps_users", id: false, force: :cascade do |t|
    t.bigint "app_id", null: false
    t.boolean "owner", default: false, null: false
    t.integer "role", default: 0, null: false
    t.bigint "user_id", null: false
    t.index ["app_id", "user_id"], name: "index_apps_users_on_app_id_and_user_id", unique: true
    t.index ["user_id", "app_id"], name: "index_apps_users_on_user_id_and_app_id", unique: true
  end

  create_table "backups", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.boolean "enabled"
    t.integer "enabled_apps", default: [], array: true
    t.boolean "enabled_database", default: true
    t.string "key", null: false
    t.integer "max_keeps", default: -1
    t.string "notification"
    t.string "schedule", null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_backups_on_key"
  end

  create_table "channels", force: :cascade do |t|
    t.string "bundle_id", default: "*"
    t.string "device_type", null: false
    t.string "download_filename_type"
    t.string "git_url"
    t.string "key"
    t.string "name", null: false
    t.string "password"
    t.bigint "scheme_id"
    t.string "slug", null: false
    t.index ["bundle_id"], name: "index_channels_on_bundle_id"
    t.index ["device_type"], name: "index_channels_on_device_type"
    t.index ["name"], name: "index_channels_on_name"
    t.index ["scheme_id", "device_type"], name: "index_channels_on_scheme_id_and_device_type"
    t.index ["slug"], name: "index_channels_on_slug", unique: true
  end

  create_table "channels_web_hooks", id: false, force: :cascade do |t|
    t.bigint "channel_id", null: false
    t.datetime "created_at", precision: nil
    t.bigint "web_hook_id", null: false
    t.index ["channel_id", "web_hook_id"], name: "index_channels_web_hooks_on_channel_id_and_web_hook_id"
    t.index ["web_hook_id", "channel_id"], name: "index_channels_web_hooks_on_web_hook_id_and_channel_id"
  end

  create_table "debug_file_metadata", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.jsonb "data", default: {}, null: false
    t.bigint "debug_file_id", null: false
    t.string "object"
    t.integer "size"
    t.string "type"
    t.datetime "updated_at", null: false
    t.string "uuid"
    t.index ["debug_file_id"], name: "index_debug_file_metadata_on_debug_file_id"
  end

  create_table "debug_files", force: :cascade do |t|
    t.bigint "app_id"
    t.string "build_version"
    t.string "checksum"
    t.datetime "created_at", null: false
    t.string "device_type"
    t.string "file"
    t.string "release_version"
    t.datetime "updated_at", null: false
    t.index ["app_id", "device_type"], name: "index_debug_files_on_app_id_and_device_type"
    t.index ["app_id"], name: "index_debug_files_on_app_id"
    t.index ["id", "device_type"], name: "index_debug_files_on_id_and_device_type"
  end

  create_table "devices", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "device_id"
    t.string "model"
    t.string "name"
    t.string "platform"
    t.string "status"
    t.string "udid", null: false
    t.datetime "updated_at", null: false
    t.index ["udid"], name: "index_devices_on_udid"
  end

  create_table "devices_releases", id: false, force: :cascade do |t|
    t.bigint "device_id", null: false
    t.bigint "release_id", null: false
    t.index ["device_id", "release_id"], name: "index_devices_releases_on_device_id_and_release_id"
    t.index ["release_id", "device_id"], name: "index_devices_releases_on_release_id_and_device_id"
  end

  create_table "good_job_batches", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.integer "callback_priority"
    t.text "callback_queue_name"
    t.datetime "created_at", null: false
    t.text "description"
    t.datetime "discarded_at"
    t.datetime "enqueued_at"
    t.datetime "finished_at"
    t.text "on_discard"
    t.text "on_finish"
    t.text "on_success"
    t.jsonb "serialized_properties"
    t.datetime "updated_at", null: false
  end

  create_table "good_job_executions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "active_job_id", null: false
    t.datetime "created_at", null: false
    t.interval "duration"
    t.text "error"
    t.text "error_backtrace", array: true
    t.integer "error_event", limit: 2
    t.datetime "finished_at"
    t.text "job_class"
    t.uuid "process_id"
    t.text "queue_name"
    t.datetime "scheduled_at"
    t.jsonb "serialized_params"
    t.datetime "updated_at", null: false
    t.index ["active_job_id", "created_at"], name: "index_good_job_executions_on_active_job_id_and_created_at"
    t.index ["process_id", "created_at"], name: "index_good_job_executions_on_process_id_and_created_at"
  end

  create_table "good_job_processes", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "lock_type", limit: 2
    t.jsonb "state"
    t.datetime "updated_at", null: false
  end

  create_table "good_job_settings", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "key"
    t.datetime "updated_at", null: false
    t.jsonb "value"
    t.index ["key"], name: "index_good_job_settings_on_key", unique: true
  end

  create_table "good_jobs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "active_job_id"
    t.uuid "batch_callback_id"
    t.uuid "batch_id"
    t.text "concurrency_key"
    t.datetime "created_at", null: false
    t.datetime "cron_at"
    t.text "cron_key"
    t.text "error"
    t.integer "error_event", limit: 2
    t.integer "executions_count"
    t.datetime "finished_at"
    t.boolean "is_discrete"
    t.text "job_class"
    t.text "labels", array: true
    t.datetime "locked_at"
    t.uuid "locked_by_id"
    t.datetime "performed_at"
    t.integer "priority"
    t.text "queue_name"
    t.uuid "retried_good_job_id"
    t.datetime "scheduled_at"
    t.jsonb "serialized_params"
    t.datetime "updated_at", null: false
    t.index ["active_job_id", "created_at"], name: "index_good_jobs_on_active_job_id_and_created_at"
    t.index ["batch_callback_id"], name: "index_good_jobs_on_batch_callback_id", where: "(batch_callback_id IS NOT NULL)"
    t.index ["batch_id"], name: "index_good_jobs_on_batch_id", where: "(batch_id IS NOT NULL)"
    t.index ["concurrency_key"], name: "index_good_jobs_on_concurrency_key_when_unfinished", where: "(finished_at IS NULL)"
    t.index ["cron_key", "created_at"], name: "index_good_jobs_on_cron_key_and_created_at_cond", where: "(cron_key IS NOT NULL)"
    t.index ["cron_key", "cron_at"], name: "index_good_jobs_on_cron_key_and_cron_at_cond", unique: true, where: "(cron_key IS NOT NULL)"
    t.index ["finished_at"], name: "index_good_jobs_jobs_on_finished_at", where: "((retried_good_job_id IS NULL) AND (finished_at IS NOT NULL))"
    t.index ["labels"], name: "index_good_jobs_on_labels", where: "(labels IS NOT NULL)", using: :gin
    t.index ["locked_by_id"], name: "index_good_jobs_on_locked_by_id", where: "(locked_by_id IS NOT NULL)"
    t.index ["priority", "created_at"], name: "index_good_job_jobs_for_candidate_lookup", where: "(finished_at IS NULL)"
    t.index ["priority", "created_at"], name: "index_good_jobs_jobs_on_priority_created_at_when_unfinished", order: { priority: "DESC NULLS LAST" }, where: "(finished_at IS NULL)"
    t.index ["priority", "scheduled_at"], name: "index_good_jobs_on_priority_scheduled_at_unfinished_unlocked", where: "((finished_at IS NULL) AND (locked_by_id IS NULL))"
    t.index ["queue_name", "scheduled_at"], name: "index_good_jobs_on_queue_name_and_scheduled_at", where: "(finished_at IS NULL)"
    t.index ["scheduled_at"], name: "index_good_jobs_on_scheduled_at", where: "(finished_at IS NULL)"
  end

  create_table "metadata", force: :cascade do |t|
    t.jsonb "activities", default: [], null: false
    t.string "build_version"
    t.string "bundle_id"
    t.jsonb "capabilities", default: [], null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.jsonb "deep_links", default: [], null: false
    t.jsonb "developer_certs", default: [], null: false
    t.string "device", null: false
    t.jsonb "devices", default: [], null: false
    t.jsonb "entitlements", default: {}, null: false
    t.jsonb "features", default: [], null: false
    t.string "min_sdk_version"
    t.jsonb "mobileprovision", default: {}, null: false
    t.string "name"
    t.jsonb "native_codes", default: [], null: false
    t.jsonb "permissions", default: [], null: false
    t.string "platform"
    t.bigint "release_id"
    t.string "release_type"
    t.string "release_version"
    t.jsonb "services", default: [], null: false
    t.integer "size"
    t.string "target_sdk_version"
    t.datetime "updated_at", null: false
    t.jsonb "url_schemes", default: [], null: false
    t.bigint "user_id"
    t.index ["checksum"], name: "index_metadata_on_checksum"
    t.index ["release_id"], name: "index_metadata_on_release_id"
    t.index ["user_id"], name: "index_metadata_on_user_id"
  end

  create_table "releases", force: :cascade do |t|
    t.string "branch"
    t.string "build_version"
    t.string "bundle_id"
    t.jsonb "changelog", null: false
    t.bigint "channel_id"
    t.string "ci_url"
    t.datetime "created_at", null: false
    t.jsonb "custom_fields", default: [], null: false
    t.string "device_type"
    t.string "file"
    t.string "git_commit"
    t.string "icon"
    t.string "name"
    t.string "release_type"
    t.string "release_version"
    t.string "source"
    t.datetime "updated_at", null: false
    t.integer "version", null: false
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
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "value"
    t.string "var", null: false
    t.index ["var"], name: "index_settings_on_var", unique: true
  end

  create_table "solid_cable_messages", force: :cascade do |t|
    t.binary "channel", null: false
    t.bigint "channel_hash", null: false
    t.datetime "created_at", null: false
    t.binary "payload", null: false
    t.index ["channel"], name: "index_solid_cable_messages_on_channel"
    t.index ["channel_hash"], name: "index_solid_cable_messages_on_channel_hash"
    t.index ["created_at"], name: "index_solid_cable_messages_on_created_at"
  end

  create_table "solid_cache_entries", force: :cascade do |t|
    t.integer "byte_size", null: false
    t.datetime "created_at", null: false
    t.binary "key", null: false
    t.bigint "key_hash", null: false
    t.binary "value", null: false
    t.index ["byte_size"], name: "index_solid_cache_entries_on_byte_size"
    t.index ["key_hash", "byte_size"], name: "index_solid_cache_entries_on_key_hash_and_byte_size"
    t.index ["key_hash"], name: "index_solid_cache_entries_on_key_hash", unique: true
  end

  create_table "user_providers", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.boolean "expires"
    t.integer "expires_at"
    t.string "name"
    t.string "refresh_token"
    t.string "token"
    t.string "uid"
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["name", "uid"], name: "index_user_providers_on_name_and_uid"
    t.index ["user_id"], name: "index_user_providers_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "appearance", default: "light", null: false
    t.datetime "confirmation_sent_at", precision: nil
    t.string "confirmation_token"
    t.datetime "confirmed_at", precision: nil
    t.datetime "created_at", null: false
    t.datetime "current_sign_in_at", precision: nil
    t.string "current_sign_in_ip"
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.integer "failed_attempts", default: 0, null: false
    t.datetime "last_sign_in_at", precision: nil
    t.string "last_sign_in_ip"
    t.string "locale", default: "zh-CN", null: false
    t.datetime "locked_at", precision: nil
    t.datetime "remember_created_at", precision: nil
    t.datetime "reset_password_sent_at", precision: nil
    t.string "reset_password_token"
    t.integer "role", null: false
    t.integer "sign_in_count", default: 0, null: false
    t.string "timezone", default: "Asia/Shanghai", null: false
    t.string "token", default: "", null: false
    t.string "unconfirmed_email"
    t.string "unlock_token"
    t.datetime "updated_at", null: false
    t.string "username"
  end

  create_table "web_hooks", force: :cascade do |t|
    t.text "body"
    t.integer "changelog_events", limit: 2
    t.bigint "channel_id"
    t.datetime "created_at", null: false
    t.integer "download_events", limit: 2
    t.datetime "updated_at", null: false
    t.integer "upload_events", limit: 2
    t.string "url"
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
