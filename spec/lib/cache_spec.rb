# spec/cache_spec.rb

require 'cache'

RSpec.describe Cache do
  describe '.user_stats_key' do
    it 'generates the correct user stats key' do
      user_id = 123
      epoch_id = 456
      expected_key = "user_stats_#{user_id}_#{epoch_id}"
      actual_key = Cache.user_stats_key(user_id, epoch_id)
      expect(actual_key).to eq(expected_key)
    end
  end

  describe '.user_social_activity_key' do
    it 'generates the correct user social activity key' do
      user_id = 123
      epoch_id = 456
      expected_key = "user_social_activity_#{user_id}_#{epoch_id}"
      actual_key = Cache.user_social_activity_key(user_id, epoch_id)
      expect(actual_key).to eq(expected_key)
    end
  end

  describe '.stats_key' do
    it 'returns the correct stats key' do
      expected_key = 'stats'
      actual_key = Cache.stats_key
      expect(actual_key).to eq(expected_key)
    end
  end

  describe '.full_stats_key' do
    it 'returns the correct full stats key' do
      expected_key = 'full_stats'
      actual_key = Cache.full_stats_key
      expect(actual_key).to eq(expected_key)
    end
  end

  describe '.leader_board_key' do
    it 'returns the correct leader board key' do
      expected_key = 'leader_board'
      actual_key = Cache.leader_board_key
      expect(actual_key).to eq(expected_key)
    end
  end
end