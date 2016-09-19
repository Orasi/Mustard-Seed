class CreateUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :users do |t|
      t.string :username
      t.string :first_name
      t.string :last_name
      t.string :company
      t.string :password_digest
      t.boolean :admin

      t.boolean :deleted
      t.timestamps
    end
  end
end
