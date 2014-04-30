require 'sinatra'

class Hello < Sinatra::Base
  get '/' do
    "sup"
  end
end
