require 'rails_helper'

RSpec.describe ApplicationController, :type => :controller do
  describe 'get /' do
    it 'redirects to basic info' do
      get :index
      expect(response).to be_redirect
      expect(response.location).to include('/application/basic_info')
    end

    pending
    it 'clears the session' do
    end
  end

  describe 'get /application/basic_info' do
    it 'responds successfully' do
      get :basic_info
      expect(response.status).to eq(200)
    end

    pending
    it 'clears the session' do
    end
  end

  describe 'POST /application/basic_info' do
    before do
      @input_hash = { name: 'dave', date_of_birth: '06/01/75' }
      post :basic_info_submit, @input_hash
    end

    it 'saves basic_info to the session' do
      expect(@request.session[:name]).to eq('dave')
      expect(@request.session[:date_of_birth]).to eq('06/01/75')
    end

    it 'redirects to contact_info' do
      expect(@response).to be_redirect
      expect(@response.location).to include('/application/contact_info')
    end
  end

  describe 'GET /application/contact_info' do
    it 'responds successfully' do
      get :contact_info
      expect(@response.status).to eq(200)
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
      post :contact_info_submit, @input_hash
    end

    it 'saves contact info into the session' do
      @input_hash.each_pair do |key, value|
        expect(@request.session[key]).to eq(value)
      end
    end

    it 'redirects to sex_and_ssn page' do
      expect(@response).to be_redirect
      expect(@response.location).to include('/application/sex_and_ssn')
    end
  end

  describe 'GET /application/sex_and_ssn' do
    it 'responds successfully' do
      get :sex_and_ssn
      expect(@response.status).to eq(200)
    end
  end

  describe 'POST /application/sex_and_ssn' do
    context 'with ssn and sex selected' do
      before do
        @input_hash = {
          "ssn" => '1112223333',
          "Male" => 'on'
        }
        post :sex_and_ssn_submit, @input_hash
      end

      it 'saves contact info into the session' do
        desired_hash = {
          ssn: '1112223333',
          sex: 'M'
        }
        desired_hash.each_pair do |key, value|
          expect(@request.session[key]).to eq(value)
        end
      end

      it 'redirects to medi-cal page' do
        expect(@response).to be_redirect
        expect(@response.location).to include('/application/medical')
      end
    end

    context 'missing sex' do
      before do
        @input_hash = {
          ssn: '1112223333',
        }
        post :sex_and_ssn_submit, @input_hash
      end

      it 'saves contact info into the session' do
        desired_hash = {
          ssn: '1112223333',
          sex: ''
        }
        desired_hash.each_pair do |key, value|
          expect(@request.session[key]).to eq(value)
        end
      end

      it 'redirects to medi-cal page' do
        expect(@response).to be_redirect
        expect(@response.location).to include('/application/medical')
      end
    end
  end

  describe 'GET /application/medical' do
    it 'responds successfully' do
      get :medical
      expect(@response.status).to eq(200)
    end
  end

  describe 'POST /application/medical' do
    context 'with medi-cal yes selected' do
      before do
        @input_hash = {
          yes: 'on'
        }
        post :medical_submit, @input_hash
      end

      it 'marks medi_cal_interest as on in session' do
        desired_hash = {
          medi_cal_interest: 'on'
        }
        desired_hash.each_pair do |key, value|
          expect(@request.session[key]).to eq(value)
        end
      end

      it 'redirects to interview page' do
        expect(@response).to be_redirect
        expect(@response.location).to include('/application/interview')
      end
    end

    context 'with medi-cal no selected' do
      before do
        @input_hash = {
          no: 'on'
        }
        post :medical_submit, @input_hash
      end

      it 'saves nothing in session' do
        expect(@request.session).to be_empty
      end
    end

    context 'with nothing on medi-cal page selected' do
      before do
        @input_hash = {
        }
        post :medical_submit, @input_hash
      end

      it 'saves nothing in session' do
        expect(@request.session).to be_empty
      end
    end
  end

  describe 'GET /application/interview' do
    it 'responds successfully' do
      get :interview
      expect(@response.status).to eq(200)
    end
  end

  describe 'POST /application/interview' do
    context 'with one time of day and one day selected' do
      before do
        @input_hash = {
          'early-morning' => 'on',
          'monday' => 'on'
        }
        post :interview_submit, @input_hash
      end

      it 'saves the selections in session' do
        desired_hash = {
          'interview_early_morning' => 'Yes',
          'interview_monday' => 'Yes'
        }
        desired_hash.each_pair do |key, value|
          expect(@request.session[key]).to eq(value)
        end
      end

      it 'redirects to household_question page' do
        expect(@response).to be_redirect
        expect(@response.location).to include('/application/household_question')
      end
    end

    context 'with no selections' do
      before do
        @input_hash = {
        }
        post :interview_submit, @input_hash
      end

      it 'puts nothing in session' do
        expect(@request.session).to be_empty
      end

      it 'redirects to household_question page' do
        expect(@response).to be_redirect
        expect(@response.location).to include('/application/household_question')
      end
    end
  end

  describe 'GET /application/household_question' do
    it 'responds successfully' do
      get :household_question
      expect(@response.status).to eq(200)
    end
  end

  describe 'GET /application/additional_household_member' do
    it 'responds successfully' do
      get :additional_household_member
      expect(@response.status).to eq(200)
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
        post :additional_household_member_submit, @input_hash
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
        desired_hash.each do |key, value|
          expect(@request.session[key]).to eq(value)
        end
      end

      # To be changed to next_addl_household_member in future
      it 'redirects back to household_question' do
        expect(@response).to be_redirect
        expect(@response.location).to include('/application/household_question')
      end
    end

    context 'with 4-digit year in DOB' do
      before do
        @input_hash = {
          "their_date_of_birth" => "12/23/1985",
        }
        post :additional_household_member_submit, @input_hash
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
        desired_hash.each do |key, value|
          expect(@request.session[key]).to eq(value)
        end
      end
    end
  end

  # Will want to test limit of N household members

  describe 'GET /application/review_and_submit' do
    it 'responds successfully' do
      get :review_and_submit
      expect(@response.status).to eq(200)
    end
  end

=begin
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

  describe 'POST /documents/USERTOKEN/DOCNUMBER/create' do
    let(:fake_redis) { double("Redis", :set => nil, :expire => nil) }
    let(:fake_verification_doc) { double("Calfresh::VerificationDoc", :original_file_path => '/tmp/fakepath') }

    before do
      allow(Redis).to receive(:new).and_return(fake_redis)
      allow(IO).to receive(:binread).and_return("fakebinaryimage")
      allow(Calfresh::VerificationDoc).to receive(:new).and_return(fake_verification_doc)
      post '/documents/fakeusertoken/0/create', { "identification" => { :filename => "lol space.jpeg" } }
    end

    it 'instantiates a redis client' do
      expect(Redis).to have_received(:new)
    end

    it 'saves binary to redis' do
      expect(fake_redis).to have_received(:set).with("fakeusertoken_0_binary", "fakebinaryimage")
    end

    it 'expires the binary' do
      expect(fake_redis).to have_received(:expire).with("fakeusertoken_0_binary", 1800)
    end

    it 'saves filename to redis (and removes spaces from it)' do
      expect(fake_redis).to have_received(:set).with("fakeusertoken_0_filename", "lolspace.jpeg")
    end

    it 'expires the filename' do
      expect(fake_redis).to have_received(:expire).with("fakeusertoken_0_filename", 1800)
    end

    it 'redirects with new number of docs' do
      expect(@response).to be_redirect
      expect(@response.location).to include('/documents/fakeusertoken/1')
    end
  end
=end
end
