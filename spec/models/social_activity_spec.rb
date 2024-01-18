require 'rails_helper'

RSpec.describe SocialActivity, type: :model do

  before :all do
    @epoch = Epoch.create(name: 'Epoch 1', start_time: Time.now.utc, end_time: Time.now.utc + 6.days, alive: true)
    @user = User.create(social_type: 'X', social_id: 119999720, username: 'forbethink', display_name: 'Manoj')
  end

  [:tweet, :quoted, :replied_to, :kickback].each do |tweet_type|
  
  describe '#calculate_twitter_points' do    
    let(:social_activity) { SocialActivity.new(user: @user, epoch: @epoch, social_type: Social::Twitter::SOCIAL_TYPE) }
    let(:tweet_type) { tweet_type }
    let(:metrics) {{
      retweet_count: 1,
      reply_count: 1,
      like_count: 1,
      quote_count: 1,
      impression_count: 1,
      bookmark_count: 1
    }}
    
    let(:expected) {{
      count_1: { points: 1851, total: 5 }, # (1000*1 + 250*1 + 100*1 + 500*1 + 1*1) => 1851
      count_3: { points: 5553, total: 15 }, # (1000*3 + 250*3 + 100*3 + 500*3 + 3*1) => 5553
      retweet_only: { points: 3000, total: 3 }, # (1000*3) => 5553
      reply_only: { points: 750, total: 3 }, # (250*3) => 750
      like_only: { points: 300, total: 3 }, # (100*3) => 300
      quote_only: { points: 1500, total: 3 }, # (500*3) => 300
      view_only: { points: 3, total: 3 }, # (500*3) => 300
    }}

    let(:multiplier) { Social::Twitter::POINT_MULTIPLIER[tweet_type.intern] }

    let(:retweet) do
      {
        public_metrics: metrics,
        referenced_tweets: [
          { type: tweet_type }
        ]
      }
    end

    it 'calculates Twitter points for all zero values' do
      retweet[:public_metrics] = { }

      social_activity.update_points([retweet])
      retweet = social_activity.activity.last.deep_symbolize_keys

      expect(retweet[:_activity_type].intern).to eq(tweet_type)
      expect(retweet[:_activity_points]).to eq(0)
      expect(retweet[:_activity_count]).to eq(0)
    end   

    it 'calculates Twitter points for all zero values' do
      retweet[:public_metrics] = {
        retweet_count: 0,
        reply_count: 0,
        like_count: 0,
        quote_count: 0,
        impression_count: 0,
        bookmark_count: 1
      }

      social_activity.update_points([retweet])
      retweet = social_activity.activity.last.deep_symbolize_keys

      expect(retweet[:_activity_type].intern).to eq(tweet_type)
      expect(retweet[:_activity_points]).to eq(0) 
      expect(retweet[:_activity_count]).to eq(0)
    end

    it 'calculates Twitter points with all count 1' do
      social_activity.update_points([retweet])
      retweet = social_activity.activity.last.deep_symbolize_keys

      expect(retweet[:_activity_type].intern).to eq(tweet_type)
      expect(retweet[:_activity_points]).to eq(expected[:count_1][:points] * multiplier)  # (1000*1) * 15
      expect(retweet[:_activity_count]).to eq(expected[:count_1][:total])
    end    

    it 'calculates Twitter points with all count 3' do

      retweet[:public_metrics] = {
        retweet_count: 3,
        reply_count: 3,
        like_count: 3,
        quote_count: 3,
        impression_count: 3,
        bookmark_count: 3
      }
      social_activity.update_points([retweet])
      retweet = social_activity.activity.last.deep_symbolize_keys

      expect(retweet[:_activity_type].intern).to eq(tweet_type)
      expect(retweet[:_activity_points]).to eq(expected[:count_3][:points] * multiplier)  # (1000*1) * 15
      expect(retweet[:_activity_count]).to eq(expected[:count_3][:total])
    end

    it 'calculates Twitter points with only retweet count' do
      retweet[:public_metrics] = { retweet_count: 3 }

      social_activity.update_points([retweet])
      retweet = social_activity.activity.last.deep_symbolize_keys

      expect(retweet[:_activity_type].intern).to eq(tweet_type)
      expect(retweet[:_activity_points]).to eq(expected[:retweet_only][:points] * multiplier)  # (1000*1) * 15
      expect(retweet[:_activity_count]).to eq(expected[:retweet_only][:total])
    end

    it 'calculates Twitter points with only reply count' do
      retweet[:public_metrics] = { reply_count: 3 }

      social_activity.update_points([retweet])
      retweet = social_activity.activity.last.deep_symbolize_keys

      expect(retweet[:_activity_type].intern).to eq(tweet_type)
      expect(retweet[:_activity_points]).to eq(expected[:reply_only][:points] * multiplier)  # (1000*1) * 15
      expect(retweet[:_activity_count]).to eq(expected[:reply_only][:total])
    end

    it 'calculates Twitter points with only like count' do
      retweet[:public_metrics] = { like_count: 3 }

      social_activity.update_points([retweet])
      retweet = social_activity.activity.last.deep_symbolize_keys

      expect(retweet[:_activity_type].intern).to eq(tweet_type)
      expect(retweet[:_activity_points]).to eq(expected[:like_only][:points] * multiplier)  # (1000*1) * 15
      expect(retweet[:_activity_count]).to eq(expected[:like_only][:total])
    end

    it 'calculates Twitter points with only like count' do
      retweet[:public_metrics] = { quote_count: 3 }

      social_activity.update_points([retweet])
      retweet = social_activity.activity.last.deep_symbolize_keys

      expect(retweet[:_activity_type].intern).to eq(tweet_type)
      expect(retweet[:_activity_points]).to eq(expected[:quote_only][:points] * multiplier)  # (1000*1) * 15
      expect(retweet[:_activity_count]).to eq(expected[:quote_only][:total])
    end    
    
    it 'calculates Twitter points with only view count' do
      retweet[:public_metrics] = { impression_count: 3 }

      social_activity.update_points([retweet])
      retweet = social_activity.activity.last.deep_symbolize_keys

      expect(retweet[:_activity_type].intern).to eq(tweet_type)
      expect(retweet[:_activity_points]).to eq(expected[:view_only][:points] * multiplier)  # (1000*1) * 15
      expect(retweet[:_activity_count]).to eq(expected[:view_only][:total])
    end       
  end  
  end

end
