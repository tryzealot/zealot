class CreateWechatOptions < ActiveRecord::Migration[5.0]
  def change
    create_table :wechat_options do |t|
      t.string :wechat_id
      t.string :key
      t.string :value

      t.timestamps
    end

    add_index :wechat_options, :wechat_id
    add_index :wechat_options, [:wechat_id, :key], name: 'index_wechat_options_on_wechat_id_and_key', unique: true
  end
end
