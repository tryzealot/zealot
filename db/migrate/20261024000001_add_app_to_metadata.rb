class AddAppToMetadata < ActiveRecord::Migration[8.1]
  def change
    add_reference :metadata, :app, index: true, foreign_key: { on_delete: :nullify }
  end
end
