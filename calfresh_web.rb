require 'sinatra'
require './calfresh'
require './faxer'

class CalfreshWeb < Sinatra::Base
  get '/' do
    erb :index
  end

  post '/applications' do
    writer = Calfresh::ApplicationWriter.new
    @application = writer.fill_out_form(params)
    if @application.has_pngs?
      @fax_result = Faxer.send_fax(ENV['FAX_DESTINATION_NUMBER'], @application.png_file_set)
      erb :after_fax
    else
      puts "No PNGs! WTF!?!"
      redirect to('/')
    end
  end

  get '/applications/:id' do
    send_file Calfresh::Application.new(params[:id]).signed_png_path
  end
end
