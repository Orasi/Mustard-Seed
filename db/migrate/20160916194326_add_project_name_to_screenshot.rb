class AddProjectNameToScreenshot < ActiveRecord::Migration[5.0]
  def change
    add_column :screenshots, :project_name, :string
  end
end
