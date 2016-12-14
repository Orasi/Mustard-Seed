class AddTokenTypeToUserTokens < ActiveRecord::Migration[5.0]
  def change
    add_column :user_tokens, :token_type, :string, default: :web
  end
end
