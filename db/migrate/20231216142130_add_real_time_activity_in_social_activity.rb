class AddRealTimeActivityInSocialActivity < ActiveRecord::Migration[7.0]
  def change
    add_column :social_activities, :realtime_activity, :jsonb
  end
end
