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

  describe 'GET /application/household_question' do
    it 'responds successfully' do
      get '/application/household_question'
      expect(last_response.status).to eq(200)
    end
  end

  describe 'GET /application/additional_household_member' do
    it 'responds successfully' do
      get '/application/additional_household_member'
      expect(last_response.status).to eq(200)
    end
  end

=begin
  describe 'POST /application/additional_household_member' do
    context '' do
      before do
        @input_hash = {
        }
        post '/application/additional_household_member', @input_hash
      end

      it '' do
        desired_hash = {
        }
        expect(last_request.session).to eq(desired_hash)
      end

      it '' do
        expect(last_response).to be_redirect
        expect(last_response.location).to include('/application/household_question')
      end
    end
  end

  # Will want to test limit of N household members
=end

  describe 'GET /application/review_and_submit' do
    it 'responds successfully' do
      get '/application/review_and_submit'
      expect(last_response.status).to eq(200)
    end
  end

  describe 'POST /application/review_and_submit' do
    let(:fake_app) { double("FakeApp", :has_pngs? => true, :png_file_set => 'pngfileset') }
    let(:fake_app_writer) { double("AppWriter", :fill_out_form => fake_app) }
    #let(:fake_faxer) { double("Faxer", :send_fax => "faxresult") }

    before do
      allow(Calfresh::ApplicationWriter).to receive(:new).and_return(fake_app_writer)
      allow(Faxer).to receive(:send_fax).and_return("faxresult")
      @data_hash = {
        date_of_birth: '06/09/1985'
      }
      post '/application/review_and_submit', {}, { "rack.session" => @data_hash }
    end

    it 'properly reformats the date of birth (and adds extraneous fields)' do
      expected_hash = @data_hash
      [:name_page3, :ssn_page3, :language_preference_reading, :language_preference_writing].each do |key|
        expected_hash[key] = nil
      end
      expect(fake_app_writer).to have_received(:fill_out_form).with(expected_hash)
    end

    it 'sends a fax' do
      expect(Faxer).to have_received(:send_fax).with("12223334444", 'pngfileset')
    end
  end
end
