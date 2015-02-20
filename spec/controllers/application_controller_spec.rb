require 'rails_helper'

RSpec.describe ApplicationController, :type => :controller do
  describe 'get /' do
    it 'includes front page content' do
      get :index
      expect(@response).to render_template('index')
    end

    it 'clears the session' do
      get :index, {}, { name: 'Idontwantsession Data' }
      expect(session[:name]).to be_nil
    end
  end

  describe 'get /application/basic_info' do
    it 'responds successfully' do
      get :basic_info
      expect(@response.status).to eq(200)
    end

    it 'clears the session' do
      get :index, {}, { name: 'Idontwantsession Data' }
      expect(session[:name]).to be_nil
    end
  end

  describe 'POST /application/basic_info' do
    before do
      @input_hash = {
        name: 'dave',
        home_address: '1234 Fake St',
        home_zip_code: '94113',
        home_city: 'San Francisco',
        home_state: 'CA',
      }
      post :basic_info_submit, @input_hash
    end

    it 'saves basic_info to the session' do
      expect(@request.session[:name]).to eq('dave')
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
          date_of_birth: '06/01/75',
          "ssn" => '1112223333',
          "Male" => 'on'
        }
        post :sex_and_ssn_submit, @input_hash
      end

      it 'saves contact info into the session' do
        desired_hash = {
          date_of_birth: '06/01/75',
          ssn: '1112223333',
          sex: 'M'
        }
        desired_hash.each_pair do |key, value|
          expect(@request.session[key]).to eq(value)
        end
      end

      it 'redirects to household question page' do
        expect(@response).to be_redirect
        expect(@response.location).to include('/application/household_question')
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

      it 'redirects to the household question page' do
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

      # To be changed to next_addl_household_member in future - DONE
      # We should add a new test for routing additional_hh_q => interview, hh info
      it 'redirects to additional_household_question' do
        expect(@response).to be_redirect
        expect(@response.location).to include('/application/additional_household_question')
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

      it 'redirects to info_sharing / privacy page' do
        expect(@response).to be_redirect
        expect(@response.location).to include('/application/info_sharing')
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

      it 'redirects to info_sharing / privacy page' do
        expect(@response).to be_redirect
        expect(@response.location).to include('/application/info_sharing')
      end
    end
  end

  describe 'GET /application/info_sharing' do
    it 'responds successfully' do
      get :info_sharing
      expect(@response.status).to eq(200)
    end
  end

  describe 'POST /application/info_sharing' do
    it 'redirects to rights_and_regs' do
      expect(@response).to be_redirect
      expect(@response.location).to include('/application/rights_and_regs')
    end
  end

  describe 'GET /application/rights_and_regs' do
    it 'responds successfully' do
      get :rights_and_regs
      expect(@response.status).to eq(200)
    end
  end

  describe 'POST /application/rights_and_regs' do
    it 'redirects to review_and_submit' do
      expect(@response).to be_redirect
      expect(@response.location).to include('/application/review_and_submit')
    end
  end

  # Will want to test limit of N household members

  describe 'GET /application/review_and_submit' do
    it 'responds successfully' do
      get :review_and_submit
      expect(@response.status).to eq(200)
    end
  end

  describe 'POST /application/review_and_submit' do
    around do |example|
      ClimateControl.modify(ZIP_FILE_PASSWORD: 'fakezipfilepassword',
                            SENDGRID_USERNAME: 'fakesendgridusername',
                            SENDGRID_PASSWORD: 'fakesendgridpassword',
                            EMAIL_ADDRESS_TO_SEND_TO: 'emailto@sendto.com') do
        example.run
      end
    end

    let(:fake_app) { double("FakeApp", :has_pngs? => true, :final_pdf_path => '/tmp/fakefinal.pdf') }
    let(:fake_app_writer) { double("AppWriter", :fill_out_form => fake_app) }
    let(:fake_sendgrid_client) { double("SendGrid::Client", :send => { "message" => "success" } ) }
    let(:fake_sendgrid_mail) { double("SendGrid::Mail", :add_attachment => 'cool') }
    let(:fake_zip_archive_for_block) { double("", :add_file => true) }

    before do
      allow(Calfresh::ApplicationWriter).to receive(:new).and_return(fake_app_writer)
      allow(SecureRandom).to receive(:hex).and_return('fakehexvalue')
      allow(SendGrid::Client).to receive(:new).and_return(fake_sendgrid_client)
      allow(SendGrid::Mail).to receive(:new).and_return(fake_sendgrid_mail)
      allow(Zip::Archive).to receive(:open).and_yield(fake_zip_archive_for_block)
      allow(Zip::Archive).to receive(:encrypt)
    end

    context 'with a four-digit year (which needs reformatting)' do
      before do
        @session_hash = {
          date_of_birth: '06/09/1985'
        }
        @params_hash = {
          signature: 'fakesignatureblob'
        }

        post :review_and_submit_submit, @params_hash, @session_hash
      end

      it 'properly reformats the date of birth (and adds extraneous fields)' do
        expected_hash = Hash.new
        expected_hash[:date_of_birth] = '06/09/85'
        [:name_page3, :ssn_page3, :language_preference_reading, :language_preference_writing].each do |key|
          expected_hash[key] = nil
        end
        expected_hash[:signature] = 'fakesignatureblob'
        expect(fake_app_writer).to have_received(:fill_out_form).with(expected_hash)
      end

      it 'zips the combined-image file' do
        expect(Zip::Archive).to have_received(:open).with('/tmp/fakehexvalue.zip', Zip::CREATE)
        expect(fake_zip_archive_for_block).to have_received(:add_file).with(fake_app.final_pdf_path)
      end

      it 'encrypts the zip file' do
        expect(Zip::Archive).to have_received(:encrypt).with('/tmp/fakehexvalue.zip', 'fakezipfilepassword')
      end

      it 'instantiates a sendgrid client with the correct credentials' do
        expect(SendGrid::Client).to have_received(:new).with(
          api_user: 'fakesendgridusername',
          api_key: 'fakesendgridpassword'
        )
      end

      it 'puts content into a new mail object' do
        expect(SendGrid::Mail).to have_received(:new).with(
          to: 'emailto@sendto.com',
          from: 'suzanne@cleanassist.org',
          subject: 'New Clean CalFresh Application!',
          text: <<EOF
Hi there!

An application for Calfresh benefits was just submitted!

You can find a completed CF-285 in the attached .zip file. You will probably receive another e-mail shortly containing photos of their verification documents.

The .zip file attached is encrypted because it contains sensitive personal information. If you don't have a password to access it, please get in touch with Jake Solomon at jacob@codeforamerica.org

When you finish clearing the case, please help us track the case by filling out a bit of info here: http://c4a.me/cleancases

Thanks for your time!

Suzanne, your friendly neighborhood CalFresh robot
EOF
        )
      end

      # Pending more mocking
      it 'adds application as attachment' do
        expect(fake_sendgrid_mail).to have_received(:add_attachment).with('/tmp/fakehexvalue.zip')
      end

      # Pending more mocking
      it 'sends an email' do
        expect(fake_sendgrid_client).to have_received(:send).with(fake_sendgrid_mail)
      end
    end

    context 'with a two-digit year (no reformatting needed)' do
      before do
        @session_hash = {
          date_of_birth: '06/09/85'
        }
        @params_hash = {
          signature: 'fakesignatureblob'
        }

        post :review_and_submit_submit, @params_hash, @session_hash
      end

      it 'properly reformats the date of birth (and adds extraneous fields)' do
        expected_hash = Hash.new
        expected_hash[:date_of_birth] = '06/09/85'
        [:name_page3, :ssn_page3, :language_preference_reading, :language_preference_writing].each do |key|
          expected_hash[key] = nil
        end
        expected_hash[:signature] = 'fakesignatureblob'
        expect(fake_app_writer).to have_received(:fill_out_form).with(expected_hash)
      end
    end
  end

# Commented out below while document upload removed
=begin
  describe 'GET /application/document_question' do
    it 'responds successfully' do
      allow(SecureRandom).to receive(:hex).and_return("notsorandom")
      get :document_question
      expect(@assigns['user_token']).to eq("notsorandom")
      expect(@response.status).to eq(200)
    end
  end
=end

  describe 'GET /complete' do
    it 'responds successfully' do
      get :complete
      expect(@response.status).to eq(200)
    end
  end
end
