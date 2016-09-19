class ChangeResults < ActiveRecord::Migration[5.0]
  def change
    remove_column :results, :result_type
    remove_column :results, :status
    remove_column :results, :comment
    remove_column :results, :options
    add_column :results, :results, :json


  end
end
