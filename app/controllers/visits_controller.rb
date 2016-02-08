class VisitsController < ApplicationController
  before_action :filter_local, :only => [:create, :close]
  after_action :trigger_page
  layout false

  def create
    visit = Visit.create! :user => current_user, :url => referer, :open_time => Time.now
    render :text => visit.id
  end

  def close
    Visit.for_user(current_user).for_url(referer).find(params[:id]).update :close_time => Time.now
  end

  private
  def visit_params
    params.require(:visit).permit!
  end

  def filter_local
    Visit.filter_existed_local
    render if local_url referer
  end

  def local_url(url)
    host = url.match(/http[s]?:\/\/([^\/|\s|:]+)[:|\/]/)[1]
    %w(localhost 127.0.0.1).include? host
  end

  def referer
    params[:referer]
  end

  def trigger_page
    begin
      client = HTTPClient.new
      client.receive_timeout = 0.0001
      client.get Settings.http_triggers.page
    rescue HTTPClient::ReceiveTimeoutError
# ignored
    end
  end
end
