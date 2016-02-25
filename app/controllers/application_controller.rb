class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  # protect_from_forgery with: :exception
  before_action :handle_http_options
  before_action :authenticate_user!

  def current_user
    super
  end

  def handle_http_options
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Allow-Methods'] = 'POST, GET, OPTIONS'
    headers['Access-Control-Allow-Headers'] = %w{Origin Accept Content-Type X-Requested-With X-CSRF-Token}.join(',')
    headers['Access-Control-Max-Age'] = '1728000'
  end

  def authenticate_user!
    user = super
    unless cookies[:dist_session_id] and (dist_session = DistSession.find_by(:session_id => cookies[:dist_session_id])) and
        JSON.parse(dist_session.data, :symbolize_names => true)[:user_id] == user.id
      sign_out
      throw :warden, :scope => :user
    end
  end
end
