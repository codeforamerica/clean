require 'spec_helper'
require File.expand_path("../../calfresh_web", __FILE__)

describe CalfreshWeb do
  describe 'GET /application/basic_info' do
    it 'responds successfully' do
      get '/application/basic_info'
      expect(last_response.status).to eq(200)
    end
  end

  pending
  describe 'POST /application/basic_info' do
  end
end
