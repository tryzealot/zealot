class RemoveGitBranchInApps < ActiveRecord::Migration
  def change
    remove_column :apps, :git_branch
  end
end
