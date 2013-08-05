class CreateWeights < ActiveRecord::Migration
  def change
    create_table :weights do |t|
      t.integer :user_id, :null => false
      t.timestamp :time, :null => false
      t.float :weight, :null => false
      t.float :fat_percent
    end

    add_index :weights, :user_id
    add_index :weights, [:user_id, :time]
  end
end
