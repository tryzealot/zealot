class RemoveWechatTables < ActiveRecord::Migration[5.1]
  def change
    drop_table :wechat_options
  end
end
