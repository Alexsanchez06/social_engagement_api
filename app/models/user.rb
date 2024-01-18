class User < ApplicationRecord
  has_many :rewards, through: :epoch
  has_many :social_activities
  has_many :claim_requests

  def self.find_or_create_by_auth(auth, reference)
    if Social::Twitter::SOCIAL_TYPE == auth[:provider]
      social_type = Social::Twitter::SOCIAL_TYPE
      social_id = auth[:uid]
      username = auth[:info][:nickname]
      display_name = auth[:info][:name]
    end

    user = nil
    User.transaction do
      user = User.find_or_create_by(username: username, social_type: social_type, social_id: social_id)
      user.update_columns(display_name: display_name, auth_reference: reference, meta_data: auth)
      Reward.find_or_create_by(user: user, epoch: Epoch.live, social_type: social_type) if Epoch.live
    end

    user
  end

  def stats(epoch_id=nil)
    # epoch_id ||= Epoch.live&.id
    epoch_id ||= Epoch.unscoped.last&.id
    return {} unless(epoch_id) 
    Reward.where(user_id: id, epoch_id: epoch_id).first&.points || {}
  end

  def epoch_activities(epoch_id=nil)
    # epoch_id ||= Epoch.live&.id
    epoch_id ||= Epoch.unscoped.last&.id
    return nil unless epoch_id 
    SocialActivity.where(epoch_id: epoch_id, user_id: self.id).last
  end

  def claims(epoch_id=nil)
    ClaimRequest.where(user_id: self.id).includes(:epoch).select(*ClaimRequest::PUBLIC_FIELDS).order("ID DESC")
  end
end