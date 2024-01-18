class AddAggregatedColumnInSocialActivity < ActiveRecord::Migration[7.0]
  def change
    add_column :rewards, :aggregated_points, :jsonb
    change_column :rewards, :total_activity_points, :string
    change_column :rewards, :total_activity_count, :string

    remove_column :social_activities, :activity_points, :string
    remove_column :social_activities, :activity_count, :string
  end
end
