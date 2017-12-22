class RemoveWechatTables < ActiveRecord::Migration[5.1]
  def up
    drop_table :wechat_options
  end

  def down
    create_table :wechat_options do |t|
      t.string :key
      t.string :value
      t.timestamps
    end
  end
end
