class AddCurrentStatusToResults < ActiveRecord::Migration[5.0]
  def change
    add_column :results, :current_status, :string
  end
end
