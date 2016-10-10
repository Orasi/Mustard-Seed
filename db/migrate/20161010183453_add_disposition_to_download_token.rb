class AddDispositionToDownloadToken < ActiveRecord::Migration[5.0]
  def change
    add_column :download_tokens, :disposition, :string
  end
end
