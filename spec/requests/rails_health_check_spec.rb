require 'rails_helper'

RSpec.describe 'Rails Health Check', type: :request do
  describe 'GET /up' do
    it 'returns a successful response' do
      get '/up'
      expect(response).to have_http_status(:ok) # Expects a 200 OK status
    end

    it 'returns a response with the correct content type' do
      get '/up'
      expect(response.content_type).to eq('text/html; charset=utf-8')
    end

    it 'returns a green body' do
      get '/up'
      expect(response.body).to include("green")
    end
  end
end
