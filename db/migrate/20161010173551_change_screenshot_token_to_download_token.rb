class ChangeScreenshotTokenToDownloadToken < ActiveRecord::Migration[5.0]
  def change
    remove_column :screenshot_tokens, :screenshot_id
    rename_table :screenshot_tokens, :download_tokens
    add_column :download_tokens, :path, :string
    add_column :download_tokens, :filename, :string
    add_column :download_tokens, :remove, :boolean
  end
end
