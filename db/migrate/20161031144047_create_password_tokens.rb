class CreatePasswordTokens < ActiveRecord::Migration[5.0]
  def change
    create_table :password_tokens do |t|

      t.integer :user_id
      t.string :token
      t.datetime :expiry
      t.timestamps
    end
  end
end
