class AddNewBuildCalloutToScheme < ActiveRecord::Migration[7.0]
  def change
    add_column :schemes, :new_build_callout, :boolean, default: true
  end
end
