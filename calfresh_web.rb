require 'sinatra'
require 'rack/ssl'
require './calfresh'
require './faxer'

class CalfreshWeb < Sinatra::Base
  use Rack::SSL unless settings.environment == :development

  get '/' do
    @language_options = %w(English Spanish Mandarin Cantonese Vietnamese Russian Tagalog)
    erb :index
  end

  post '/applications' do
    writer = Calfresh::ApplicationWriter.new
    input_for_writer = params
    input_for_writer[:sex] = case params[:sex]
      when "Male"
        "M"
      when "Female"
        "F"
      else
        ""
    end
    date_of_birth_array = params[:date_of_birth].split('/')
    birth_year = date_of_birth_array[2]
    if birth_year.length == 4
      input_for_writer[:date_of_birth] = date_of_birth_array[0..1].join('/') + "/#{birth_year[-2..-1]}"
    end
    input_for_writer[:name_page3] = params[:name]
    input_for_writer[:ssn_page3] = params[:ssn]
    input_for_writer[:language_preference_reading] = params[:primary_language]
    input_for_writer[:language_preference_writing] = params[:primary_language]
    @application = writer.fill_out_form(input_for_writer)
    if @application.has_pngs?
      @verification_docs = Calfresh::VerificationDocSet.new(params)
      images_to_send = @application.png_file_set + @verification_docs.file_array
      puts images_to_send
      @fax_result = Faxer.send_fax(ENV['FAX_DESTINATION_NUMBER'], images_to_send)
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
