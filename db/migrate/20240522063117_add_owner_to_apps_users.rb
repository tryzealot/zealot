class AddOwnerToAppsUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :apps_users, :owner, :boolean, null: false, default: false

    App.all.each do |app|
      # Fix if previous handle error
      if app.collaborators.count == 1
        collaborator = app.collaborators.first
        collaborator.update(owner: true)
        next
      end

      collaborator = app.collaborators.find_by(role: 'admin')
      next unless collaborator
      next if collaborator.owner

      unless collaborator.update(owner: true)
        puts collaborator.errors
      end
    end
  end
end
