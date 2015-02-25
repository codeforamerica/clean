require 'feature_spec_helper'

feature 'User goes to root URL' do
  scenario 'they see the button for starting an application' do
    visit '/'

    expect(page).to have_button("Start your application")
  end
end

feature 'User leaves required fields empty', :js => true do
  scenario 'the error message is shown to the user to fill in those fields before continuing' do
    visit '/application/basic_info?'
      expect(page.current_path).to eq('/application/basic_info')
      fill_in('name', with: '')
      click_on('Next Step')
      expect(page.current_path).to eq('/application/basic_info')
      expect(page).to have_content('Provide your full name to get started!')
  end
end

feature 'User goes through full application (up to review and submit)' do
  given(:fake_app) { double("FakeApp", :has_pngs? => true, :final_pdf_path => '/tmp/fakefinal.pdf') }
  given(:fake_app_writer) { double("AppWriter", :fill_out_form => fake_app) }
  given(:fake_sendgrid_client) { double("SendGrid::Client", :send => { "message" => "success" } ) }
  given(:fake_sendgrid_mail) { double("SendGrid::Mail", :add_attachment => 'cool') }
  given(:fake_zip_archive_for_block) { double("", :add_file => true) }

  allow(Calfresh::ApplicationWriter).to receive(:new).and_return(fake_app_writer)
  allow(SecureRandom).to receive(:hex).and_return('fakehexvalue')
  allow(SendGrid::Client).to receive(:new).and_return(fake_sendgrid_client)
  allow(SendGrid::Mail).to receive(:new).and_return(fake_sendgrid_mail)
  allow(Zip::Archive).to receive(:open).and_yield(fake_zip_archive_for_block)
  allow(Zip::Archive).to receive(:encrypt)

  scenario 'with basic interactions' do
    visit '/application/basic_info?'
      fill_in 'name', with: 'Hot Snakes'
      fill_in 'home_address', with: "2015 Market Street"
      fill_in 'home_zip_code', with: "94122"
      click_button 'Next Step'
      expect(page.current_path).to eq('/application/contact_info')
      fill_in 'home_phone_number', with: "5555555555"
      fill_in 'email', with: "hotsnakes@gmail.com"
      click_on('Next Step')
      expect(page.current_path).to eq('/application/sex_and_ssn')
      fill_in 'date_of_birth', with: "01/01/2000"
      fill_in 'ssn', with: "000000000"
      choose('no-answer')
      click_on('Next Step')

      expect(page.current_path).to eq('/application/household_question')
      click_link('Yes')
      expect(page.current_path).to eq('/application/additional_household_member')
      fill_in 'their_name', with: 'Hot Snakes'
      fill_in 'their_date_of_birth', with: "01/01/2000"
      fill_in 'their_ssn', with: "000000000"
      choose('male')
      click_on('Next Step')
      expect(page.current_path).to eq('/application/additional_household_question')
      click_link('No')
      expect(page.current_path).to eq('/application/interview')
      check('monday')
      check('friday')
      check('mid-morning')
      check('late-afternoon')
      click_on('Next Step')
      expect(page.current_path).to eq('/application/info_sharing')
      click_on("I agree")
      expect(page.current_path).to eq('/application/rights_and_regs')
      click_on("I understand")
      expect(page.current_path).to eq('/application/review_and_submit')
      click_on("Submit Application")
      # TODO - Check the mock objects received the correct input
      expect(page.current_path).to eq('/application/document_instructions')
  end
end
