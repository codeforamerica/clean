# Be sure to restart your server when you modify this file.

# Your secret key is used for verifying the integrity of signed cookies.
# If you change this key, all old signed cookies will become invalid!

# Make sure the secret is at least 30 characters and all random,
# no regular words or you'll be exposed to dictionary attacks.
# You can use `rake secret` to generate a secure secret key.

# Make sure your secret_key_base is kept private
# if you're sharing your code publicly.
if Rails.env.production? && ENV['SECRET_TOKEN'].blank?
  raise 'The SECRET_TOKEN environment variable is not set. To generate it, run "rake secret", then set it on the production server. If you\'re using Heroku, you do this with "heroku config:set SECRET_TOKEN=the_token_you_generated"'
end

Rails.application.config.secret_key_base = ENV['SECRET_TOKEN'] || 'dfe54819729d1ea5ca55f659e62b6711f775e45433c7ea0a424174f6357a8bff8e4c1728e937f011b4788417c317a79db6eb647a66d53f3aa75f68ed811812ad'
