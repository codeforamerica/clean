require 'feature_spec_helper'

feature 'User goes to root URL' do
  scenario 'they see the button for starting an application' do
    visit '/'

    expect(page).to have_button("Got it! Start My CalFresh Application")
  end
end

feature 'User leaves required fields empty' do
  pending
  scenario 'the error message is shown to the user to fill in those fields before continuing' do
  end
end

feature 'User goes through full application (up to review and submit)' do
  pending
  scenario 'it all works!' do
  end
end
