require 'rails_helper'

RSpec.describe "Users", type: :request do
  describe "GET /index" do
    it 'returns a successful response with the expected JSON structure' do
      get '/api/stats'
      expect(response).to have_http_status(:success)
      expect(response.content_type).to eq('application/json; charset=utf-8')

      json_response = JSON.parse(response.body)
      expect(json_response).to include('success' => true)
      start_date = json_response['data'].dig("start_time")
      expect(json_response['data']).to include(
        'total_points' => '0',
        'total_mentions' => '0',
        'start_time' => start_date,
        'total_participants' => 0
      )
    end    
  end
end
