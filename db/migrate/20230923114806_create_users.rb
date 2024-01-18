class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users do |t|
      t.string :social_type, null: false
      t.string :social_id, index: true, null: false
      t.string :username, index: true, null: false
      t.string :display_name
      t.string :last_post_id # tweet_id
      t.jsonb :social_metadata

      t.timestamps
    end
  end
end
