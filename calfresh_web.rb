require 'sinatra'
require './calfresh'

class CalfreshWeb < Sinatra::Base
  get '/' do
    erb :index
  end

  post '/applications' do
    writer = Calfresh::ApplicationWriter.new
    @application = writer.fill_out_form(params)
    if ENV.has_key?('FAX_DESTINATION_NUMBER') && ENV['FAX_DESTINATION_NUMBER'] != ""
      if @application.has_pngs?
        puts "fax mock"
        # Faxer.send_fax(ENV['FAX_DESTINATION_NUMBER'], @application.png_file_set)
        erb :sent
      end
    else
      puts "no fax number!"
      erb :no_fax
    end
  end

  get '/applications/:id' do
    send_file Calfresh::Application.new(params[:id]).signed_png_path
  end
end
