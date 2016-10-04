class AddEnvironmentTypeToMigration < ActiveRecord::Migration[5.0]
  def change
    add_column :environments, :environment_type, :string
  end
end
