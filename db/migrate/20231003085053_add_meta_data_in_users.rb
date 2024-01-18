class AddMetaDataInUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :meta_data, :jsonb
  end
end
