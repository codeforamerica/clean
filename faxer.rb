require 'phaxio'

Phaxio.config do |config|
  config.api_key = ENV['PHAXIO_API_KEY']
  config.api_secret = ENV['PHAXIO_API_SECRET']
end

module Faxer
  extend self

  def fax_calfresh_pngs_from_tmp(unique_key)
    file_array = Array.new
    file_array << File.new("/tmp/application_#{unique_key}-6-signed.png")
    (7..15).each do |page_number|
      file_array << File.new("/tmp/application_#{unique_key}-#{page_number}.png")
    end
    result = Phaxio.send_fax(to: ENV['FAX_DESTINATION_NUMBER'], filename: file_array)
    result
  end
end
