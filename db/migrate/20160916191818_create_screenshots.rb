class CreateScreenshots < ActiveRecord::Migration[5.0]

  def up
    create_table :screenshots do |t|
      t.timestamps
      t.integer :result_id
    end
    add_attachment :screenshots, :screenshot
  end

  def down
    drop_table :screenshots
  end
end
