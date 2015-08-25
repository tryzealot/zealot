class AddGitBranchAndCommitToRelease < ActiveRecord::Migration
  def change
    add_column :releases, :channel, :string, after: :app_id

    add_column :releases, :branch, :string, after: :icon
    add_column :releases, :last_commit, :string, after: :branch
    add_column :releases, :ci_url, :string, after: :last_commit
  end
end
