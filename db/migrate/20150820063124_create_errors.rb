class CreateErrors < ActiveRecord::Migration
  def change
    create_table :errors do |t|
      t.string  :usable_type
      t.integer :usable_id
      t.text    :class_name
      t.text    :message
      t.text    :trace
      t.text    :target_url
      t.text    :referer_url
      t.text    :params
      t.text    :user_agent
      t.timestamps
    end
  end
end