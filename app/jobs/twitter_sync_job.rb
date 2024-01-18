require 'async'

class TwitterSyncJob < ApplicationJob
  queue_as :twitter_jobs

  API_POOL = (0..AppConfig.batch_size).collect{ Social::Twitter.new('') }

  def perform(*args)
    eod = args.first.with_indifferent_access["eod"]
    epoch = Epoch.unscoped.last
    if epoch
      today = Time.now.utc.to_date
      yesterday = (Time.now - 1.day).utc.to_date
      Reward.includes(:user).where(social_type: Social::Twitter::SOCIAL_TYPE, epoch_id: epoch.id).where('created_at < ?', today).each.with_index do |reward, i|
      #Reward.includes(:user).where(social_type: Social::Twitter::SOCIAL_TYPE, epoch_id: epoch.id).each.with_index do |reward, i|
        reward_eod = reward.eod || {}
        #if reward_eod[yesterday] == 'success'
        #  continue
        #end
        api = Social::Twitter.new('')
        api.reset!
        api.username = reward.user.username
        puts "##{i+1} Processing... #{api.username}"
        begin
          social_acitivity = SocialActivity.find_or_initialize_by(
            user_id: reward.user.id, 
            epoch: epoch, 
            social_type: Social::Twitter::SOCIAL_TYPE)
            aggregated_points = social_acitivity.update_points(api.tweets(eod), eod)
            reward_eod[yesterday] = "success" if eod

            reward.update_columns(
              aggregated_points: aggregated_points[:aggregated_points], 
              total_activity_points: aggregated_points[:aggregated_points][:_total_points],
              total_activity_count: aggregated_points[:aggregated_points][:_total_counts],
              updated_at: Time.now.utc,
              eod: reward_eod
            )
          puts "Processed... #{api.username}"
            Cache.clear_cache Cache.user_stats_key(reward.user.id, epoch.id)
            Cache.clear_cache Cache.user_social_activity_key(reward.user.id, epoch.id)
        rescue => error
          reward_eod[yesterday] = "fail" if eod
          reward.update_columns(eod: reward_eod)
          logger.error("Error processing for username #{Social::Twitter::SOCIAL_TYPE} #{api.username}")
          logger.error(error)
        end
        sleep 0.25

        if ((i+1) % AppConfig.batch_size) == 0
          puts "#{i+1} Waiting..."
          epoch.aggregate_points
          Cache.clear_cache Cache.stats_key
          Cache.clear_cache Cache.full_stats_key
          Cache.clear_cache Cache.leader_board_key    
          sleep 15.minutes
        end
      end
    end
  end
end
