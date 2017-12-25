class AddUserIdToReleases < ActiveRecord::Migration[5.1]
  def up
    change_column :releases, :id, :bigint, auto_increment: true
    change_column :releases, :app_id, :bigint
    add_reference :releases, :user, after: :app_id

    # 更新默认上传者
    Releases.all.update_all user_id: User.find_by(email: 'mobile@qyer.com')
  end

  def down
    change_column :releases, :id, :int, auto_increment: true
    change_column :releases, :app_id, :int
    remove_reference :releases, :user
  end
end
