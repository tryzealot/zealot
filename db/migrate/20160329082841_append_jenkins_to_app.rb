class AppendJenkinsToApp < ActiveRecord::Migration
  def change
    add_column :apps, :jenkins_job, :string, after: :device_type, null: true
    add_column :apps, :git_url, :string, after: :jenkins_job, null: true
    add_column :apps, :git_branch, :string, after: :git_url, default: 'develop'
  end
end
