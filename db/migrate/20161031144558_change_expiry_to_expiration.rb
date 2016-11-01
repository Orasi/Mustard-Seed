class ChangeExpiryToExpiration < ActiveRecord::Migration[5.0]
  def change
    rename_column :password_tokens,:expiry, :expiration
  end
end
