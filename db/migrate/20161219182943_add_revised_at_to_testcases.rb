class AddRevisedAtToTestcases < ActiveRecord::Migration[5.0]
  def change
    add_column :testcases, :revised_at, :datetime
  end
end
