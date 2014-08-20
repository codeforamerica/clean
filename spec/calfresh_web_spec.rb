require 'spec_helper'
require File.expand_path("../../calfresh_web", __FILE__)

describe CalfreshWeb do
  describe 'GET /application/basic_info' do
    it 'responds successfully' do
      get '/application/basic_info'
      expect(last_response.status).to eq(200)
    end
  end

  describe 'POST /application/basic_info' do
    it 'asdasd' do
      input_hash = { name: 'dave', date_of_birth: '06/01/75' }
      post '/application/basic_info', input_hash
      expect(last_request.session).to eq(input_hash)
    end
  end
end
