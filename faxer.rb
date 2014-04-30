require 'phaxio'

Phaxio.config do |config|
  config.api_key = ENV['PHAXIO_API_KEY']
  config.api_secret = ENV['PHAXIO_API_SECRET']
end

module Faxer
  extend self

  def send_fax(phone_number, file_or_files)
    result = Phaxio.send_fax(to: phone_number, filename: file_or_files)
    result
  end
end
