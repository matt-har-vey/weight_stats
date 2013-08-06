class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :fitbit_id, null: false
      t.string :access_token_value
      t.string :access_token_secret
      t.timestamp :weights_updated_at
      t.date :weights_start
      t.date :weights_end
      t.timestamps
    end
  end
end
