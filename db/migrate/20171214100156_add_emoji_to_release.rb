class AddEmojiToRelease < ActiveRecord::Migration[5.1]
  def up
    execute <<-SQL
      ALTER TABLE releases CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
    SQL
  end

  def down
  end
end
