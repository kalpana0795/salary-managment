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

  describe 'GET /insights/salary-by-title' do
    it 'returns average salary for job title' do
      create(:employee,
            country: 'India',
            job_title: 'Engineer',
            salary: 100000)

      get '/insights/salary-by-title',
          params: {
            country: 'India',
            job_title: 'Engineer'
          }

      body = JSON.parse(response.body)

      expect(body['data']['avg_salary']).to eq(100000.0)
    end
  end
end
