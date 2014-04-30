require 'sinatra'

class CalfreshWeb < Sinatra::Base
  get '/' do
    erb :index
  end

  post '/applications' do
    erb :application_sent
  end
end
