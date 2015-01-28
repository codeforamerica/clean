class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def index
    redirect_to '/application/basic_info'
  end

  def basic_info
  end

  def basic_info_submit
    session[:name] = params[:name]
    session[:date_of_birth] = params[:date_of_birth]
    redirect_to '/application/contact_info'
  end
end
