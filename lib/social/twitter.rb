require 'net/http'

module Social
  class Twitter    
    SOCIAL_TYPE = 'twitter'
    TAGS = AppConfig.twitter_tags
    AUTH_TOKEN = AppConfig.twitter_auth_token

    TYPE_POINTS = {      
      tweet: 3000,
      quoted: 2000,
      replied_to: 1000,
      kickback: 200
    }

    POINTS = {
      retweet_count: 300,
      reply_count: 200
      like_count: 100,
      quote_count: 500,
      impression_count: 10
    }      

    POINT_MULTIPLIER = {
      tweet: 30,
      retweeted: 1,
      quoted: 10,
      replied_to: 1,
      kickback: 0.1
    }

    TWEET_SEARCH = URI('https://api.twitter.com/2/tweets/search/recent')

    DEFAULT_QUERY_PARAMS = {
      max_results: Rails.application.credentials.tweets_count_per_user,
      expansions: 'attachments.media_keys,author_id',
      'tweet.fields': 'public_metrics,referenced_tweets',
      'media.fields': 'public_metrics',
      #start_time: "#{Epoch.unscoped.last&.start_time&.strftime("%Y-%m-%d")}T00:00:00Z"
      start_time: "#{Date.yesterday.to_time(:utc).strftime("%Y-%m-%d")}T00:00:00Z",
      end_time: "#{Date.yesterday.to_time(:utc).strftime("%Y-%m-%d")}T23:59:59Z"
      #start_time: "#{Date.today.to_time(:utc).strftime("%Y-%m-%d")}T15:20:00Z",
      #end_time: "#{Date.today.to_time(:utc).strftime("%Y-%m-%d")}T15:35:59Z"
    }
    
    attr_accessor :username, :tweets

    def initialize(username)
      self.username = username
    end
    
    def tweets(eod)
      base_url = URI('https://api.twitter.com/2/tweets/search/recent')
      
      unless eod
        DEFAULT_QUERY_PARAMS.merge!({
          start_time: Time.now.utc.to_date.strftime("%Y-%m-%dT%H:%M:%SZ"),
          end_time: (Time.now.utc - 60.seconds).strftime("%Y-%m-%dT%H:%M:%SZ") #Subtract 60 seconds (1 minute)
          #end_time: Time.now.utc.strftime("%Y-%m-%dT%H:%M:%SZ")
          #end_time: "#{Date.today.to_time(:utc).strftime("%Y-%m-%d")}T15:22:59Z"
        })
      end

      query_params = { query: TAGS.map{|tag| "from:#{username} #{tag}" }.join(' OR ') }
      base_url.query = URI.encode_www_form(DEFAULT_QUERY_PARAMS.merge(query_params))
      request = Net::HTTP::Get.new(base_url)
      request['Authorization'] = "Bearer #{AUTH_TOKEN}"

      puts " ========== Sync for #{self.username} ======== " 
      puts base_url.hostname
      puts base_url.query

      response = Net::HTTP.start(base_url.hostname, base_url.port, use_ssl: true) { |http| http.request(request) }

      if response.code == '200'
        tweets = JSON.parse(response.body) || {}
        if Rails.env.development?     
          puts " -------- Tweets ------ "      
          tweets['data']&.each do |tweet|
            puts "#{tweet} " 
            puts " -------------- " 
          end
        end

        return tweets['data'] || []
      else
        raise "Error: #{response.inspect} #{response.code} #{response.body}"
      end
    end

    def reset!
      username = nil
      tweets = nil
    end
  end
end
