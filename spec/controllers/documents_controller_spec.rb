require 'rails_helper'

=begin
RSpec.describe DocumentsController, :type => :controller do
  around do |example|
    ClimateControl.modify(REDISTOGO_URL: 'fakeredisurl',
                          ZIP_FILE_PASSWORD: 'fakezipfilepassword',
                          SENDGRID_USERNAME: 'fakesendgridusername',
                          SENDGRID_PASSWORD: 'fakesendgridpassword',
                          EMAIL_ADDRESS_TO_SEND_TO: 'emailto@sendto.com') do
      example.run
    end
  end

  describe 'GET new' do
    it 'is successful' do
      get :new, { :user_token => 'faketoken', :number_of_docs => '0' }
      expect(@response.status).to eq(200)
    end
  end

  describe 'POST /documents/USERTOKEN/DOCNUMBER/create' do
    let(:fake_redis) { double("Redis", :set => nil, :expire => nil) }
    let(:fake_verification_doc) { double("Calfresh::VerificationDoc", :original_file_path => '/tmp/fakepath') }

    before do
      allow(Redis).to receive(:new).and_return(fake_redis)
      allow(IO).to receive(:binread).and_return("fakebinaryimage")
      allow(Calfresh::VerificationDoc).to receive(:new).and_return(fake_verification_doc)
      post :create, { 'user_token' => 'fakeusertoken', 'doc_number' => '0', 'identification' => fixture_file_upload('files/spak with space.jpeg', 'image/jpeg') }
    end

    it 'instantiates a redis client' do
      expect(Redis).to have_received(:new)
    end

    it 'saves binary to redis' do
      expect(fake_redis).to have_received(:set).with("fakeusertoken_0_binary", "fakebinaryimage")
    end

    it 'expires the binary' do
      expect(fake_redis).to have_received(:expire).with("fakeusertoken_0_binary", 3600)
    end

    it 'redirects with new number of docs' do
      expect(@response).to be_redirect
      expect(@response.location).to include('/documents/fakeusertoken/1')
    end
  end

  describe 'POST /documents/USERTOKEN/DOCNUMBER/submit' do
    let(:fake_redis) { double("Redis") }
    let(:fake_sendgrid_client) { double("SendGrid::Client", :send => "message: success") }
    let(:fake_sendgrid_mail) { double("SendGrid::Mail", :add_attachment => true) }
    let(:fake_file_for_block) { double("", :write => true) }
    let(:fake_zip_archive_for_block) { double("", :add_file => true) }

    before do
      allow(Redis).to receive(:new).and_return(fake_redis)
      allow(fake_redis).to receive(:get).with("fakeusertoken_0_binary").and_return("fakebinary0")
      allow(fake_redis).to receive(:get).with("fakeusertoken_1_binary").and_return("fakebinary1")
      allow(fake_redis).to receive(:del).with("fakeusertoken_0_binary")
      allow(fake_redis).to receive(:del).with("fakeusertoken_1_binary")
      allow(SecureRandom).to receive(:hex).and_return('firsthex', 'secondhex')
      allow(SendGrid::Client).to receive(:new).and_return(fake_sendgrid_client)
      allow(SendGrid::Mail).to receive(:new).and_return(fake_sendgrid_mail)
      allow(File).to receive(:open).and_yield(fake_file_for_block)
      allow(Kernel).to receive(:system)
      allow(Zip::Archive).to receive(:open).and_yield(fake_zip_archive_for_block)
      allow(Zip::Archive).to receive(:encrypt)
      post :submit, { 'user_token' => 'fakeusertoken', 'doc_number' => '2' }
    end

    context 'with two verification documents' do
      it 'instantiates a redis client' do
        expect(Redis).to have_received(:new)
      end

      it 'stubs the ENV correctly' do
        expect(ENV['REDISTOGO_URL']).to eq('fakeredisurl')
        expect(ENV['ZIP_FILE_PASSWORD']).to eq('fakezipfilepassword')
      end

      it 'sends the correct :get arguments to the Redis client' do
        expect(fake_redis).to have_received(:get).with("fakeusertoken_0_binary")
        expect(fake_redis).to have_received(:get).with("fakeusertoken_1_binary")
      end

      it 'sends the correct :del arguments to the Redis client' do
        expect(fake_redis).to have_received(:del).with("fakeusertoken_0_binary")
        expect(fake_redis).to have_received(:del).with("fakeusertoken_1_binary")
      end

      it 'writes files with the correct name' do
        expect(File).to have_received(:open).with('/tmp/firsthex', 'wb')
        expect(fake_file_for_block).to have_received(:write).with("fakebinary0")
        expect(File).to have_received(:open).with('/tmp/secondhex', 'wb')
        expect(fake_file_for_block).to have_received(:write).with("fakebinary1")
      end

      it 'shells out to convert with the correct arguments' do
        convert_statement = "convert /tmp/firsthex /tmp/secondhex /tmp/fakeusertoken_all_images.pdf"
        expect(Kernel).to have_received(:system).with(convert_statement)
      end

      it 'zips the combined-image file' do
        expect(Zip::Archive).to have_received(:open).with('/tmp/fakeusertoken_zipped.zip', Zip::CREATE)
        expect(fake_zip_archive_for_block).to have_received(:add_file).with('/tmp/fakeusertoken_all_images.pdf')
      end

      it 'encrypts the zip file' do
        expect(Zip::Archive).to have_received(:encrypt).with('/tmp/fakeusertoken_zipped.zip', 'fakezipfilepassword')
      end

      it 'creates a new SendGrid client with credentials from env' do
        expect(SendGrid::Client).to have_received(:new).with({ api_user: 'fakesendgridusername', api_key: 'fakesendgridpassword' })
      end

      it 'prepares an email with correct inputs' do
        email_body = <<EOF
Hi there!

Verification docs were just submitted for a CalFresh application!

You can find the docs in the attached .zip file.

The .zip file attached is encrypted because it contains sensitive personal information. If you don't have a key to access it, please get in touch with Jake Soloman at jacob@codeforamerica.org

Thanks for your time!

Suzanne, your friendly neighborhood CalFresh robot
EOF
        expect(SendGrid::Mail).to have_received(:new).with(
          to: 'emailto@sendto.com',
          from: 'suzanne@cleanassist.org',
          subject: 'New Clean CalFresh Verification Docs!',
          text: email_body
        )
      end

      it 'adds attachment with correct path to the mail' do
        expect(fake_sendgrid_mail).to have_received(:add_attachment).with('/tmp/fakeusertoken_zipped.zip')
      end

      it 'sends the mail' do
        expect(fake_sendgrid_client).to have_received(:send).with(fake_sendgrid_mail)
      end

      it 'redirects to /complete' do
        expect(@response).to be_redirect
        expect(@response.location).to include('/complete')
      end
    end
  end
end
=end
