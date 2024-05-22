class AddSettingsToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :locale, :string, null: false, default: Setting.site_locale
    add_column :users, :appearance, :string, null: false, default: Setting.site_appearance
    add_column :users, :timezone, :string, null: false, default: (ENV['TIME_ZONE'] || 'Asia/Shanghai')
  end
end
