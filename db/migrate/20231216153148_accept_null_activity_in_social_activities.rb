class AcceptNullActivityInSocialActivities < ActiveRecord::Migration[7.0]
  def change
    change_column_null(:social_activities, :activity, true)
  end
end
