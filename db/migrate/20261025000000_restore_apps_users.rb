# frozen_string_literal: true

# Heals databases that ran the since-deleted
# `20260913133000_drop_apps_users_and_promote_collaborators` migration. Its
# first version dropped `apps_users`, a later version renamed it to
# `apps_users_legacy`; app collaborators are back, so both shapes converge on
# `apps_users` here. Databases that never ran it are left untouched.
class RestoreAppsUsers < ActiveRecord::Migration[8.1]
  def up
    return if table_exists?(:apps_users)

    if table_exists?(:apps_users_legacy)
      rename_table :apps_users_legacy, :apps_users
      return
    end

    create_table :apps_users, id: false do |t|
      t.bigint :app_id, null: false
      t.boolean :owner, default: false, null: false
      t.integer :role, default: 0, null: false
      t.bigint :user_id, null: false
      t.index %i[app_id user_id], name: 'index_apps_users_on_app_id_and_user_id', unique: true
      t.index %i[user_id app_id], name: 'index_apps_users_on_user_id_and_app_id', unique: true
    end
  end

  def down
    # `apps_users` is part of the baseline schema; nothing to undo.
  end
end
