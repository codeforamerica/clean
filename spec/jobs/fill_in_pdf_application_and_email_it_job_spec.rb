require 'rails_helper'

RSpec.describe FillInPdfApplicationAndEmailItJob, :type => :job do
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

  before do
    @input_hash = {
      date_of_birth: '06/09/85',
      signature: 'fakesignatureblob'
    }
    [:name_page3, :ssn_page3, :language_preference_reading, :language_preference_writing].each do |key|
      @input_hash[key] = nil
    end

    FillInPdfApplicationAndEmailItJob.new.perform(@input_hash)
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

  it 'adds application as attachment' do
    expect(fake_sendgrid_mail).to have_received(:add_attachment).with('/tmp/fakehexvalue.zip')
  end

  it 'sends an email' do
    expect(fake_sendgrid_client).to have_received(:send).with(fake_sendgrid_mail)
  end
end
