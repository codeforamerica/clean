require 'spec_helper'
require File.expand_path("../../calfresh_web", __FILE__)

describe CalfreshWeb do
  describe 'get /' do
    it 'redirects to basic info' do
      get '/'
      expect(last_response).to be_redirect
      expect(last_response.location).to include('/application/basic_info')
    end
  end

  describe 'get /application/basic_info' do
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
          "ssn" => '1112223333',
          "Male" => 'on'
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

  describe 'POST /application/additional_household_member' do
    context 'first addl household member' do
      before do
        @input_hash = {
          "their_name" => "Joe Blow",
          "their_date_of_birth" => "12/23/85",
          "their_ssn" => "0001112222",
          "Male" => "on"
        }
        post '/application/additional_household_member', @input_hash
      end

      it 'saves the info to session' do
        desired_hash = {
          additional_household_members: [{
            :name => "Joe Blow",
            :date_of_birth => "12/23/85",
            :sex => "M",
            :ssn => "0001112222"
          }]
        }
        expect(last_request.session).to eq(desired_hash)
      end

      # To be changed to next_addl_household_member in future
      it 'redirects back to household_question' do
        expect(last_response).to be_redirect
        expect(last_response.location).to include('/application/household_question')
      end
    end

    context 'with 4-digit year in DOB' do
      before do
        @input_hash = {
          "their_date_of_birth" => "12/23/1985",
        }
        post '/application/additional_household_member', @input_hash
      end

      it 'trims the year to 2 digits and saves in session' do
        desired_hash = {
          additional_household_members: [{
            :date_of_birth => "12/23/85",
            :name => "",
            :sex => "",
            :ssn => ""
          }]
        }
        expect(last_request.session).to eq(desired_hash)
      end
    end
  end

  # Will want to test limit of N household members

  describe 'GET /application/review_and_submit' do
    it 'responds successfully' do
      get '/application/review_and_submit'
      expect(last_response.status).to eq(200)
    end
  end

  describe 'POST /application/review_and_submit' do
    let(:fake_app) { double("FakeApp", :has_pngs? => true, :final_pdf_path => '/tmp/fakefinal.pdf') }
    let(:fake_app_writer) { double("AppWriter", :fill_out_form => fake_app) }
    let(:fake_sendgrid_client) { double("SendGrid::Client", :send => { "message" => "success" } ) }
    let(:fake_sendgrid_mail) { double("SendGrid::Mail", :add_attachment => 'cool') }

    before do
      allow(Calfresh::ApplicationWriter).to receive(:new).and_return(fake_app_writer)
      allow(SendGrid::Client).to receive(:new).and_return(fake_sendgrid_client)
      allow(SendGrid::Mail).to receive(:new).and_return(fake_sendgrid_mail)
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

    it 'instantiates a sendgrid client with the correct credentials' do
      expect(SendGrid::Client).to have_received(:new).with(
        api_user: 'fakesendgridusername',
        api_key: 'fakesendgridpassword'
      )
    end

    it 'puts content into a new mail object' do
      expect(SendGrid::Mail).to have_received(:new).with(
        to: 'fakeemailaddress',
        from: 'ted@cleanassist.org',
        subject: 'New Clean CalFresh application!',
        text: <<EOF
Hi there!

An application for Calfresh benefits was just submitted!

You can find a completed CF-285 in the attached .zip file. You will probably receive another e-mail shortly containing photos of their verification documents.

The .zip file attached is encrypted because it contains sensitive personal information. If you don't have a key to access it, please get in touch with Jake Soloman at jacob@codeforamerica.org

Thanks for your time!

Suzanne, your friendly neighborhood CalFresh robot
EOF
      )
    end

    it 'adds application as attachment' do
      expect(fake_sendgrid_mail).to have_received(:add_attachment).with('/tmp/fakefinal.pdf')
    end

    it 'sends an email' do
      expect(fake_sendgrid_client).to have_received(:send).with(fake_sendgrid_mail)
    end
  end
end
