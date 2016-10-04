class CreateScreenshotTokens < ActiveRecord::Migration[5.0]
  def change
    create_table :screenshot_tokens do |t|
      t.string :token
      t.datetime :expiration
      t.integer :screenshot_id
      t.timestamps
    end
  end
end
