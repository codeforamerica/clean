require 'sinatra'
require 'rack/ssl'
require 'encrypted_cookie'
require './calfresh'
require './faxer'

class CalfreshWeb < Sinatra::Base
  use Rack::Session::EncryptedCookie, :secret => ENV['SECRET_TOKEN']
  use Rack::SSL unless settings.environment == :development

  get '/' do
    @language_options = %w(English Spanish Mandarin Cantonese Vietnamese Russian Tagalog Other)
    erb :index
  end

  get '/application/basic_info' do
    erb :basic_info, layout: :v4_layout
  end

  post '/application/basic_info' do
    session[:name] = params[:name]
    session[:date_of_birth] = params[:date_of_birth]
    redirect to('/application/contact_info'), 303
  end

  get '/application/contact_info' do
    @language_options = %w(English Spanish Mandarin Cantonese Vietnamese Russian Tagalog Other)
    erb :contact_info, layout: :v4_layout
  end

  post '/application/contact_info' do
    session[:home_phone_number] = params[:home_phone_number]
    session[:email] = params[:email]
    session[:home_address] = params[:home_address]
    session[:home_zip_code] = params[:home_zip_code]
    session[:home_city] = params[:home_city]
    session[:home_state] = params[:home_state]
    session[:primary_language] = params[:primary_language]
    redirect to('/application/sex_and_ssn'), 303
  end

  get '/application/sex_and_ssn' do
    erb :sex_and_ssn, layout: :v4_layout
  end

  post '/application/sex_and_ssn' do
    sex = params.select do |key, value|
      value == "on"
    end.keys.first.capitalize
    session[:ssn] = params[:ssn]
    session[:sex] = sex
    redirect to('/application/medical'), 303
  end

  get '/application/medical' do
    erb :medical, layout: :v4_layout
  end

  post '/application/medical' do
    medical = params.select do |key, value|
      value == "on"
    end.keys.first.capitalize
    session[:medical_interest] = medical
    redirect to('/application/interview'), 303
  end

  get '/application/interview' do
    erb :interview, layout: :v4_layout
  end

  post '/application/interview' do
    redirect to('/application/household_question'), 303
  end

  get '/application/household_question' do
    erb :household_question, layout: :v4_layout
  end

  get '/application/additional_household_member' do
    erb :additional_household_member, layout: :v4_layout
  end

  post '/application/additional_household_member' do
    session[:name] = params[:their_name]
    session[:date_of_birth] = params[:their_date_of_birth]
    session[:ssn] = params[:ssn]
    redirect to('/application/next_household_question'), 303
  end

  get '/application/next_household_question' do
    erb :next_household_question, layout: :v4_layout
  end

  get '/application/review_and_submit' do
    erb :review_and_submit, layout: :v4_layout
  end

  post '/applications/review_and_submit' do
    redirect to('/application/confirmation'), 303
  end

  get '/application/confirmation' do
    erb :confirmation, layout: :v4_layout
  end

  get '/document_question' do
    erb :document_question, layout: :verification_doc_layout
  end

  get '/first_id_doc' do
    erb :first_id_doc, layout: :v4_layout
  end

  post '/first_id_doc' do
    redirect to('/next_id_doc'), 303
  end

  get '/next_id_doc' do
    erb :next_id_doc, layout: :verification_doc_layout
  end

  post '/next_id_doc' do
    redirect to('/next_id_doc'), 303
  end

  get '/first_income_doc' do
    erb :first_income_doc, layout: :verification_doc_layout
  end

  post '/first_income_doc' do
    redirect to('/next_income_doc'), 303
  end

  get '/next_income_doc' do
    erb :next_income_doc, layout: :verification_doc_layout
  end

  post '/next_income_doc' do
    redirect to('/next_income_doc'), 303
  end

  get '/first_expense_doc' do
    erb :first_expense_doc, layout: :verification_doc_layout
  end

  post '/first_expense_doc' do
    redirect to('/next_expense_doc')
  end

  get '/next_expense_doc' do
    erb :next_expense_doc, layout: :verification_doc_layout
  end

  post '/next_expense_doc' do
    redirect to('/next_expense_doc')
  end

  get '/first_other_doc' do
    erb :first_other_doc, layout: :verification_doc_layout
  end

  post '/first_other_doc' do
    redirect to('/next_other_doc')
  end

  get '/next_other_doc' do
    erb :next_other_doc, layout: :verification_doc_layout
  end

  post '/next_other_doc' do
    redirect to('/next_other_doc')
  end

  get '/complete' do
    erb :complete, layout: :verification_doc_layout
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
