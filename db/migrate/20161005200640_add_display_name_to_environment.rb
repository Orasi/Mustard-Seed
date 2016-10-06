class AddDisplayNameToEnvironment < ActiveRecord::Migration[5.0]
  def change
    add_column :environments, :display_name, :string
    remove_column :environments, :deleted
    remove_column :environments, :options
  end
end
