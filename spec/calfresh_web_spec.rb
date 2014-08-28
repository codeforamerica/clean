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
    before do
      @input_hash = { name: 'dave', date_of_birth: '06/01/75' }
      post '/application/basic_info', @input_hash
    end

    it 'saves basic_info to the session' do
      expect(last_request.session).to eq(@input_hash)
    end

    it 'redirects to contact_info' do
      expect(last_response).to be_redirect
      expect(last_response.location).to include('/application/contact_info')
    end
  end

  describe 'GET /application/contact_info' do
    it 'responds successfully' do
      get '/application/contact_info'
      expect(last_response.status).to eq(200)
    end
  end

  describe 'POST /application/contact_info' do
    before do
      @input_hash = {
        home_phone_number: '1112223333',
        email: 'joe@example.com',
        home_address: '1234 Fake St',
        home_zip_code: '94113',
        home_city: 'San Francisco',
        home_state: 'CA',
        primary_language: "English"
      }
      post '/application/contact_info', @input_hash
    end

    it 'saves contact info into the session' do
      expect(last_request.session).to eq(@input_hash)
    end

    it 'redirects to sex_and_ssn page' do
      expect(last_response).to be_redirect
      expect(last_response.location).to include('/application/sex_and_ssn')
    end
  end

  describe 'GET /application/sex_and_ssn' do
    it 'responds successfully' do
      get '/application/sex_and_ssn'
      expect(last_response.status).to eq(200)
    end
  end

  describe 'POST /application/sex_and_ssn' do
    context 'with ssn and sex selected' do
      before do
        @input_hash = {
          ssn: '1112223333',
          male: 'on'
        }
        post '/application/sex_and_ssn', @input_hash
      end

      it 'saves contact info into the session' do
        desired_hash = {
          ssn: '1112223333',
          sex: 'M'
        }
        expect(last_request.session).to eq(desired_hash)
      end

      it 'redirects to medi-cal page' do
        expect(last_response).to be_redirect
        expect(last_response.location).to include('/application/medical')
      end
    end

    context 'missing sex' do
      before do
        @input_hash = {
          ssn: '1112223333',
        }
        post '/application/sex_and_ssn', @input_hash
      end

      it 'saves contact info into the session' do
        desired_hash = {
          ssn: '1112223333',
          sex: ''
        }
        expect(last_request.session).to eq(desired_hash)
      end

      it 'redirects to medi-cal page' do
        expect(last_response).to be_redirect
        expect(last_response.location).to include('/application/medical')
      end
    end
  end

  describe 'GET /application/medical' do
    it 'responds successfully' do
      get '/application/medical'
      expect(last_response.status).to eq(200)
    end
  end

  describe 'POST /application/medical' do
    context 'with medi-cal yes selected' do
      before do
        @input_hash = {
          yes: 'on'
        }
        post '/application/medical', @input_hash
      end

      it 'marks medi_cal_interest as on in session' do
        desired_hash = {
          medi_cal_interest: 'on'
        }
        expect(last_request.session).to eq(desired_hash)
      end

      it 'redirects to interview page' do
        expect(last_response).to be_redirect
        expect(last_response.location).to include('/application/interview')
      end
    end

    context 'with medi-cal no selected' do
      before do
        @input_hash = {
          no: 'on'
        }
        post '/application/medical', @input_hash
      end

      it 'saves nothing in session' do
        desired_hash = {}
        expect(last_request.session).to eq(desired_hash)
      end

      it 'redirects to interview page' do
        expect(last_response).to be_redirect
        expect(last_response.location).to include('/application/interview')
      end
    end

    context 'with nothing on medi-cal page selected' do
      before do
        @input_hash = {
        }
        post '/application/medical', @input_hash
      end

      it 'saves nothing in session' do
        desired_hash = {}
        expect(last_request.session).to eq(desired_hash)
      end

      it 'redirects to interview page' do
        expect(last_response).to be_redirect
        expect(last_response.location).to include('/application/interview')
      end
    end
  end

  describe 'GET /application/interview' do
    it 'responds successfully' do
      get '/application/interview'
      expect(last_response.status).to eq(200)
    end
  end

  describe 'POST /application/interview' do
    context 'with one time of day and one day selected' do
      before do
        @input_hash = {
          'early-morning' => 'on',
          'monday' => 'on'
        }
        post '/application/interview', @input_hash
      end

      it 'saves the selections in session' do
        desired_hash = {
          'interview_early_morning' => 'Yes',
          'interview_monday' => 'Yes'
        }
        expect(last_request.session).to eq(desired_hash)
      end

      it 'redirects to household_question page' do
        expect(last_response).to be_redirect
        expect(last_response.location).to include('/application/household_question')
      end
    end

    context 'with no selections' do
      before do
        @input_hash = {
        }
        post '/application/interview', @input_hash
      end

      it 'puts nothing in session' do
        desired_hash = {
        }
        expect(last_request.session).to eq(desired_hash)
      end

      it 'redirects to household_question page' do
        expect(last_response).to be_redirect
        expect(last_response.location).to include('/application/household_question')
      end
    end
  end
end
