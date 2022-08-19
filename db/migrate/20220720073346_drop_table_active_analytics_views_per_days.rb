class DropTableActiveAnalyticsViewsPerDays < ActiveRecord::Migration[7.0]
  def up
    drop_table :active_analytics_views_per_days
  end

  def down
    create_table :active_analytics_views_per_days do |t|
      t.string :site, null: false
      t.string :page, null: false
      t.date :date, null: false
      t.bigint :total, null: false, default: 1
      t.string :referrer_host
      t.string :referrer_path
      t.timestamps
    end
    add_index :active_analytics_views_per_days, :date
    add_index :active_analytics_views_per_days, [:site, :page, :date], name: "index_active_analytics_views_per_days_on_site_and_date"
    add_index :active_analytics_views_per_days, [:referrer_host, :referrer_path, :date], name: "index_active_analytics_views_per_days_on_referrer_and_date"
  end
end
