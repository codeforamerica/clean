require 'sinatra'
require './lib/calfresh'

class CalfreshWeb < Sinatra::Base
  get '/' do
    erb :index
  end

  post '/applications' do
    writer = Calfresh::ApplicationWriter.new
    application = writer.fill_out_form(params)
    send_file application.signed_png_path
    erb :application_sent
  end
end
