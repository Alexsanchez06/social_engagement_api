# spec/lib/app_config_spec.rb

require 'rails_helper'

describe AppConfig do
  describe '.batch_size' do
    it 'returns the correct value' do
      expect(AppConfig.batch_size).to eq(10)
    end
  end

  describe '.schedule_interval' do
    it 'returns the correct value' do
      expect(AppConfig.schedule_interval).to eq('5 seconds')
    end
  end

  describe '.ui_host' do
    it 'returns the correct value' do
      expect(AppConfig.ui_host).to eq('http://localhost:5173')
    end
  end 

  describe '.schedule_interval' do
    it 'returns the correct value' do
      expect(AppConfig.schedule_interval).to eq('5 seconds')
    end
  end

  describe '.schedule_interval' do
    it 'returns the correct value' do
      expect(AppConfig.twitter_tags).to eq(["#TKNTEST", "@JMPTEST"])
    end
  end

end
