require 'phaxio'
require 'pry'

Phaxio.config do |config|
  config.api_key = ENV['PHAXIO_API_KEY']
  config.api_secret = ENV['PHAXIO_API_SECRET']
end

file1 = File.new('/tmp/application_2bedc7f5a4bcfa8dbb32afac6fccd499-6-signed.png')
file2 = File.new('/tmp/application_2bedc7f5a4bcfa8dbb32afac6fccd499-7.png')
result = Phaxio.send_fax(to: ENV['FAX_DESTINATION_NUMBER'], filename: [file1, file2])

binding.pry
