class AddFlagColumnToAppConfig < ActiveRecord::Migration[7.0]
  def change
    add_column :app_configs, :is_enable_claim_notification, :boolean
    add_column :app_configs, :is_coming_soon, :boolean
    add_column :app_configs, :is_enable_login, :boolean
    add_column :app_configs, :is_enable_claim, :boolean
  end
end
