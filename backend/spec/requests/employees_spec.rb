require 'rails_helper'

RSpec.describe 'Employees API', type: :request do
  describe 'GET /employees' do
    before do
      create_list(:employee, 3, country: 'India')
    end

    it 'returns all employees' do
      get '/employees'

      expect(response).to have_http_status(:ok)

      body = JSON.parse(response.body)

      expect(body['data'].length).to eq(3)
      expect(body['meta']).to be_present
    end

    it 'supports pagination' do
      create_list(:employee, 20)

      get '/employees', params: { page: 1, per_page: 5 }

      body = JSON.parse(response.body)

      expect(body['data'].length).to eq(5)
    end

    it 'filters employees by country' do
      create(:employee, country: 'USA')

      get '/employees', params: { country: 'India' }

      body = JSON.parse(response.body)

      expect(body['data'].length).to eq(3)
      expect(body['data'][0]['country']).to eq('India')
    end
  end

  describe 'GET /employees/:id' do
    it 'returns employee details' do
      employee = create(:employee)

      get "/employees/#{employee.id}"

      expect(response).to have_http_status(:ok)

      body = JSON.parse(response.body)

      expect(body['data']['id']).to eq(employee.id)
    end

    it 'returns 404 when employee does not exist' do
      get '/employees/invalid-id'

      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'POST /employees' do
    let(:valid_params) do
      {
        employee: {
          full_name: 'John Doe',
          job_title: 'Engineer',
          country: 'India',
          salary: 75000,
          currency: 'USD',
          department: 'Engineering'
        }
      }
    end

    it 'creates a new employee' do
      expect {
        post '/employees', params: valid_params
      }.to change(Employee, :count).by(1)

      expect(response).to have_http_status(:created)

      body = JSON.parse(response.body)

      expect(body['data']['full_name']).to eq('John Doe')
    end

    it 'returns validation errors for invalid params' do
      invalid_params = {
        employee: {
          full_name: '',
          salary: 0
        }
      }

      post '/employees', params: invalid_params

      expect(response).to have_http_status(:unprocessable_entity)

      body = JSON.parse(response.body)

      expect(body['error']).to be_present
    end
  end
end
