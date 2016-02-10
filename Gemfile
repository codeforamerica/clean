source 'https://rubygems.org'
ruby '2.1.5'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.2.0'
# Use postgresql as the database for Active Record
gem 'pg'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.1.0'

# Use jquery as the JavaScript library
gem 'jquery-rails'
gem 'jquery-fileupload-rails', '0.4.1'
gem 'jquery-ui-rails'
gem 'paperclip', '~> 4.2'
gem 'aws-sdk', '< 2.0'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc

gem 'pdf-forms'
gem 'sendgrid-ruby'
gem 'zipruby'

gem 'prawn'

gem 'chronic'
gem 'airbrake', '~> 4.0'

gem 'mini_magick'

group :development do
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'
end

group :test do
  gem 'rspec-rails', '~> 3.0'

  gem 'capybara'
  gem 'capybara-webkit'
end

group :development, :test do
  gem 'spring'
  gem 'pry'

  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'

  gem 'climate_control'
end

group :production do
  gem 'rails_12factor'
end
