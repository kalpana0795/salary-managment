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

    it 'sorts employees by salary descending' do
      create(:employee, salary: 30000)
      create(:employee, salary: 400000)

      get '/employees', params: {
        sort_by: 'salary',
        order: 'desc'
      }

      body = JSON.parse(response.body)

      expect(body['data'].first['salary']).to eq(400000)
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

    it 'returns bad request when employee param is missing' do
      post '/employees', params: {}

      expect(response).to have_http_status(:bad_request)
    end
  end

  describe 'PATCH /employees/:id' do
    let!(:employee) { create(:employee, full_name: 'Old Name') }

    it 'updates an employee' do
      patch "/employees/#{employee.id}", params: {
        employee: {
          full_name: 'New Name'
        }
      }

      expect(response).to have_http_status(:ok)

      body = JSON.parse(response.body)

      expect(body['data']['full_name']).to eq('New Name')
    end

    it 'returns validation errors for invalid update' do
      patch "/employees/#{employee.id}", params: {
        employee: {
          salary: 0
        }
      }

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe 'DELETE /employees/:id' do
    let!(:employee) { create(:employee) }

    it 'deletes an employee' do
      expect {
        delete "/employees/#{employee.id}"
      }.to change(Employee, :count).by(-1)

      expect(response).to have_http_status(:no_content)
    end
  end
end
