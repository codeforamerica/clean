require 'sinatra'
require 'rack/ssl'
require './calfresh'
require './faxer'

class CalfreshWeb < Sinatra::Base
  use Rack::SSL unless settings.environment == :development

  get '/' do
    @language_options = %w(English Spanish Mandarin Cantonese Vietnamese Russian Tagalog Other)
    erb :index
  end

  get '/application/basic_info' do
    erb :basic_info, layout: :v4_layout
  end

  get '/application/contact_info' do
    @language_options = %w(English Spanish Mandarin Cantonese Vietnamese Russian Tagalog Other)
    erb :contact_info, layout: :v4_layout
  end

  get '/application/sex_and_ssn' do
    erb :sex_and_ssn, layout: :v4_layout
  end

  get '/application/medical' do
    erb :medical, layout: :v4_layout
  end

  get '/application/interview' do
    erb :interview, layout: :v4_layout
  end

  get '/application/household_question' do
    erb :household_question, layout: :v4_layout
  end

  get '/application/additional_household_member' do
    erb :additional_household_member, layout: :v4_layout
  end

  get '/application/review_and_submit' do
    erb :review_and_submit, layout: :v4_layout
  end

  get '/application/confirmation' do
    erb :confirmation, layout: :v4_layout
  end

  get '/verification_doc' do
    erb :verification_doc, layout: false
  end

  post '/applications' do
    writer = Calfresh::ApplicationWriter.new
    input_for_writer = params
    input_for_writer["sex"] = case params["sex"]
      when "Male"
        "M"
      when "Female"
        "F"
      else
        ""
    end
    if params["date_of_birth"] != ""
      date_of_birth_array = params["date_of_birth"].split('/')
      birth_year = date_of_birth_array[2]
      if birth_year.length == 4
        input_for_writer["date_of_birth"] = date_of_birth_array[0..1].join('/') + "/#{birth_year[-2..-1]}"
      end
    end
    input_for_writer[:name_page3] = params[:name]
    input_for_writer[:ssn_page3] = params[:ssn]
    input_for_writer[:language_preference_reading] = params[:primary_language]
    input_for_writer[:language_preference_writing] = params[:primary_language]
    @application = writer.fill_out_form(input_for_writer)
    if @application.has_pngs?
      @verification_docs = Calfresh::VerificationDocSet.new(params)
      @fax_result_application = Faxer.send_fax(ENV['FAX_DESTINATION_NUMBER'], @application.png_file_set)
      @fax_result_verification_docs = Faxer.send_fax(ENV['FAX_DESTINATION_NUMBER'], @verification_docs.file_array)
      puts @fax_result_application
      puts @fax_result_verification_docs
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
