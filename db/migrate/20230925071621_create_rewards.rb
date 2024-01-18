class CreateRewards < ActiveRecord::Migration[7.0]
  def change
    create_table :rewards do |t|
      t.references :user, null: false, foreign_key: true      
      t.references :epoch, null: false, foreign_key: true
      t.string :social_type, null: false # Optional, if needed
      t.integer :total_activity_points, default: 0
      t.integer :total_activity_count, default: 0
      t.string :claim_address
      t.string :claim_status
      t.datetime :claimed_at
      t.string :claim_reference

      t.timestamps
    end
    add_index :rewards, [:user_id, :epoch_id], unique: true
  end
end
