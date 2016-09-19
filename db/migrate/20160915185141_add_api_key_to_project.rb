class AddApiKeyToProject < ActiveRecord::Migration[5.0]
  def change
    add_column :projects, :api_key, :string
  end
end
