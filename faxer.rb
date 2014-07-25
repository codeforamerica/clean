require 'phaxio'

Phaxio.config do |config|
  config.api_key = ENV['PHAXIO_API_KEY']
  config.api_secret = ENV['PHAXIO_API_SECRET']
end

module Faxer
  extend self

  def send_fax(phone_number, file_or_files)
    if configured_for_sending?
      FaxResult.new(Phaxio.send_fax(to: phone_number, filename: file_or_files, batch: true, batch_delay: 30))
    else
      FaxResult.new({"success" => false, "message" => "Faxer not configured." })
    end
  end

  def configured_for_sending?
    configured = true
    ['FAX_DESTINATION_NUMBER', 'PHAXIO_API_KEY', 'PHAXIO_API_SECRET'].each do |env_var|
      configured = false unless ENV.has_key?(env_var) && ENV[env_var] != ""
    end
    configured
  end

  class FaxResult
    attr_reader :full_result, :success, :message

    def initialize(hash_result)
      @full_result = hash_result
      @success = hash_result['success']
      @message = hash_result['message']
    end

    def successful?
      @success
    end
  end
end
