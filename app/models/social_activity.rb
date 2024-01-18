class SocialActivity < ApplicationRecord  
  belongs_to :user
  belongs_to :epoch

  def points
    calculated = (activity).map{|tweet| calculate_twitter_points(tweet) }
    aggregated_points = aggregated_points(calculated)
  end

  def update_points(activity=nil, eod=false)
    realtime_activity = activity
    if social_type == Social::Twitter::SOCIAL_TYPE
      #calculated = (activity || self.activity).map{|tweet| calculate_twitter_points(tweet) }
      calculated = (self.activity.to_a + realtime_activity).map{|tweet| calculate_twitter_points(tweet) }
      aggregated_points = aggregated_points(calculated)

      if eod
        self.activity = calculated
        self.realtime_activity = nil
      else
        self.realtime_activity = realtime_activity
      end

      self.save!

      { status: self.save!, aggregated_points: aggregated_points }
    end
  end
  
  private
  def aggregated_points(activities)
    # Total
    total_activity_points = 0
    total_count_points = 0
    total_counts = 0

    # Level 1 { tweet: 2, retweeted: 3, quoted: 9, replied_to: 2, kickback: 4}
    type_counter = Hash.new(0)

    # Level 2
    retweet_count = 0
    reply_count = 0
    like_count = 0
    quote_count = 0
    impression_count = 0

    activities.each do |activity|

      total_activity_points += activity[:_activity_points] 
      total_counts += activity[:_activity_count]
      activity_type = activity[:_activity_type]
      type_counter[activity_type] += 1

      metrics = activity[:public_metrics]
      retweet_count += metrics.fetch(:retweet_count, 0)
      reply_count += metrics.fetch(:reply_count, 0)
      like_count += metrics.fetch(:like_count, 0)
      quote_count += metrics.fetch(:quote_count, 0)
      impression_count += metrics.fetch(:impression_count, 0)
    end

    # Points calculation for no. of tweets, quotes, replies
    type_counter.each do |key, count|
      (total_count_points += Social::Twitter::TYPE_POINTS[key] * count) unless(key == :retweeted)
    end

    {
      _total_counts: total_counts, 
      _total_activity_points: total_activity_points, 
      _total_count_points: total_count_points,
      _total_points: total_activity_points + total_count_points,
      _retweet_count: retweet_count,
      _reply_count: reply_count, 
      _like_count: like_count, 
      _quote_count: quote_count, 
      _impression_count: impression_count
    }.merge(type_counter)
  end

  def calculate_twitter_points(tweet)    
    tweet = tweet.deep_symbolize_keys
    metrics = tweet[:public_metrics] || {}
    tweet_points = {
      retweet_count: metrics.fetch(:retweet_count, 0) * Social::Twitter::POINTS.fetch(:retweet_count, 0),
      reply_count: metrics.fetch(:reply_count, 0) * Social::Twitter::POINTS.fetch(:reply_count, 0),
      like_count: metrics.fetch(:like_count, 0) * Social::Twitter::POINTS.fetch(:like_count, 0),
      quote_count: metrics.fetch(:quote_count, 0) * Social::Twitter::POINTS.fetch(:quote_count, 0),
      impression_count: metrics.fetch(:impression_count, 0) * Social::Twitter::POINTS.fetch(:impression_count, 0)
    }

    if tweet[:referenced_tweets]
      tweet_type = tweet[:referenced_tweets].last[:type].intern
    else
      tweet_type = :tweet
    end        

    multiply = Social::Twitter::POINT_MULTIPLIER[tweet_type]
    tweet[:_activity_type] = tweet_type
    tweet[:_activity_points] = tweet_points.values.reduce(&:+) * multiply
    tweet[:_activity_count] = [
      metrics.fetch(:retweet_count, 0),
      metrics.fetch(:reply_count, 0),
      metrics.fetch(:like_count, 0),
      metrics.fetch(:quote_count, 0),
      metrics.fetch(:impression_count, 0)
    ].sum
    
    tweet
  end
end
