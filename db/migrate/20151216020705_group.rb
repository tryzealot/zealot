class Group < ActiveRecord::Migration
  def change
    create_table :groups do |t|
      t.integer  :qyer_id, null: false, index: true
      t.string   :im_id, null: false, index: true
      t.string   :name, null: false, index: true
      t.string   :type, default: 'chatroom'
    end
  end
end
