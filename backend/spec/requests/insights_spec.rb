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

  describe 'GET /insights/distribution' do
    before do
      create(:employee, salary: 30_000)
      create(:employee, salary: 70_000)
      create(:employee, salary: 150_000)
    end

    it 'returns salary distribution buckets' do
      get '/insights/distribution'

      expect(response).to have_http_status(:ok)

      body = JSON.parse(response.body)

      expect(body['data']).to be_an(Array)

      expect(body['data'].first)
        .to include('range', 'count')
    end
  end

  describe 'GET /insights/outliers' do
    before do
      20.times do
        create(:employee, salary: 100_000)
      end

      create(
        :employee,
        full_name: 'High Salary Employee',
        salary: 1_000_000
      )
    end

    it 'returns salary outliers' do
      get '/insights/outliers'

      expect(response).to have_http_status(:ok)

      body = JSON.parse(response.body)

      expect(body['data'].length).to eq(1)

      expect(body['data'][0]['full_name'])
        .to eq('High Salary Employee')
    end
  end
end
