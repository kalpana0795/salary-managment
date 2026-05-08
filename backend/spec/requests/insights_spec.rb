require 'rails_helper'

RSpec.describe 'Insights API', type: :request do
  describe 'GET /insights/salary' do
    before do
      create(:employee, country: 'India', salary: 50000)
      create(:employee, country: 'India', salary: 100000)
    end

    it 'returns salary insights for a country' do
      get '/insights/salary', params: { country: 'India' }

      expect(response).to have_http_status(:ok)

      body = JSON.parse(response.body)

      expect(body['data']['min_salary']).to eq(50000)
      expect(body['data']['max_salary']).to eq(100000)
    end
  end
end
