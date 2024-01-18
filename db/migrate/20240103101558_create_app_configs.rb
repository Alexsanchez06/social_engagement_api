class CreateAppConfigs < ActiveRecord::Migration[7.0]
  def change
    create_table :app_configs do |t|
      t.string :twitter_client_id
      t.string :twitter_client_secret
      t.string :twitter_auth_token
      t.string :twitter_api_key
      t.string :twitter_api_secret
      t.string :twitter_tags
      t.string :admin_user

      t.timestamps
    end
  end
end
