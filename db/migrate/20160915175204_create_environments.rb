class CreateEnvironments < ActiveRecord::Migration[5.0]
  def change
    create_table :environments do |t|
      t.string 'uuid'
      t.integer 'project_id'
      t.boolean 'deleted'
      t.json 'options'
      t.timestamps
    end
  end

end
