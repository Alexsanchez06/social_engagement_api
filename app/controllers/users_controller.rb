class UsersController < ApplicationController
  before_action :load_user

  def stats
    data = cached_data(user_key) do
      @current_user.stats
    end

    respond_with(data)
  end

  def social_activities
    data = cached_data(social_activity_key) do
      @current_user.epoch_activities&.attributes || {}
    end

    respond_with(data)
  end

  def sync
    TwitterSyncJob.perform_now(eod: false)
    render json: {success: true, message: 'Completed!'}
  end

  def claims
    data = cached_data(claim_request_key) do
      @current_user.claims
    end

    respond_with(data)
  end

  def claim_request
    epoch = Epoch.unscoped.last
    reward = Reward.by_epoch(epoch.id).by_user(@current_user.id).first
    ClaimRequest.create!(
      quantity: params[:quantity], # (params[:quantity].nil? || params[:quantity] == ClaimRequest::FULL_CLAIM_NAME) ? reward.total_activity_points : params[:quantity], 
      address: params[:address], 
      sign: params[:sign], 
      reward: reward, 
      user: @current_user, 
      epoch: epoch, 
      status: ClaimRequest::STATUS.REQUESTED)
    respond_with([])
  rescue ActiveRecord::RecordNotUnique => e
    raise "Claim is already requested"
  end

  private
  def user_key
    Cache.user_stats_key(params[:id], @epoch&.id)
  end
  
  def social_activity_key
    Cache.user_social_activity_key(params[:id], @epoch&.id)
  end

  def claim_request_key
    Cache.user_claim_request_key(params[:id], @epoch&.id)
  end
end
