
class Cache

  def self.user_stats_key(user_id, epoch_id)
    "user_stats_#{user_id}_#{epoch_id}"
  end

  def self.user_social_activity_key(user_id, epoch_id)
    "user_social_activity_#{user_id}_#{epoch_id}"
  end

  def self.user_claim_request_key(user_id, epoch_id)
    "user_claim_request_key_#{user_id}_#{epoch_id}"
  end

  def self.stats_key
    'stats'
  end

  def self.full_stats_key
    'full_stats'
  end

  def self.leader_board_key
    'leader_board'
  end

  def self.clear_cache(key)    
    puts "Clear Cache: #{key} | #{Rails.cache.delete(key)}"
  end

  def self.clear_cache_http(key)
    uri = URI("http://localhost:3000/api/clear_cache/#{key}")
    response = JSON.parse(Net::HTTP.get(uri)) rescue {}
    puts "Clear Cache: #{uri} | #{response}"
    response
  end
end