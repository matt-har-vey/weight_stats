class ChangeUsersHoldToken < ActiveRecord::Migration
  def change
    add_column :users, :access_token_value, :string
    add_column :users, :access_token_secret, :string
    add_column :users, :weights_updated_at, :timestamp
  end
end
