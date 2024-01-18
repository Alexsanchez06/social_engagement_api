class ChangeInSocialActivity < ActiveRecord::Migration[7.0]
  def change
    remove_column :social_activities, :activity_type
    remove_column :social_activities, :activity_id
  end
end