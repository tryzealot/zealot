class AppendGitCommitToiOs < ActiveRecord::Migration
  def change
    add_column :ios, :last_commit_date, :string, after: :dsym_file
    add_column :ios, :last_commit_email, :string, after: :dsym_file
    add_column :ios, :last_commit_author, :string, after: :dsym_file
    add_column :ios, :last_commit_message, :string, after: :dsym_file
    add_column :ios, :last_commit_branch, :string, after: :dsym_file
    add_column :ios, :last_commit_hash, :string, after: :dsym_file
  end
end
