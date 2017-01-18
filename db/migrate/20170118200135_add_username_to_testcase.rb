class AddUsernameToTestcase < ActiveRecord::Migration[5.0]
  def change
    add_column :testcases, :username, :string
  end
end
