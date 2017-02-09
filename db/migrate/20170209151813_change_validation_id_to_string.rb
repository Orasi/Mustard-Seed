class ChangeValidationIdToString < ActiveRecord::Migration[5.0]
  def change
    change_column :testcases, :validation_id, :string
  end
end
