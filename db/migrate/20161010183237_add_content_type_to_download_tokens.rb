class AddContentTypeToDownloadTokens < ActiveRecord::Migration[5.0]
  def change
    add_column :download_tokens, :content_type, :string
  end
end
