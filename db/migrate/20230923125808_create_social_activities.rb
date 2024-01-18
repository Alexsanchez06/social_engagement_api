class CreateSocialActivities < ActiveRecord::Migration[7.0]
  def change
    create_table :social_activities do |t|
      t.references :user, null: false, foreign_key: true      
      t.references :epoch, null: false, foreign_key: true
      t.string :social_type, null: false
      t.string :activity_type, null: false # From Twitter (if from twitter)
      t.string :activity_id, null: false # From tweet_id (if from twitter)
      t.jsonb :activity, null: false # JSONB column to store activity data
      t.integer :activity_points, null: false, default: 0
      t.integer :activity_count, null: false, default: 0

      t.timestamps
    end
    
    add_index :social_activities, [:user_id, :epoch_id]
  end
end
