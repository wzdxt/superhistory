class VisitsController < ApplicationController
  before_action :filter_invalid, :only => [:create, :close]
  after_action :trigger_service
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

  def filter_invalid
    # Visit.filter_existed_local
    render if local_or_ip_url(referer) or host_excluded_url(referer)
  end

  def local_or_ip_url(url)
    host = url.match(/http[s]?:\/\/([^\/|\s|:]+)[:|\/]/)[1]
    %w(localhost 127.0.0.1).include?(host) || host =~ /^(\d+\.){3}\d+$/
  end

  def host_excluded_url(url)
    uri = URI.parse url
    HostRule.matched_rules(uri.host, uri.port).each do |host_rule|
      return true if host_rule.excluded?
    end
    false
  end

  def referer
    params[:referer]
  end

  def trigger_service
    %w(page content visithistory).each do |serv|
      begin
        client = HTTPClient.new
        client.receive_timeout = 0.0001
        client.get Settings.http_triggers[serv]
      rescue HTTPClient::ReceiveTimeoutError
# ignored
      end
    end
  end
end
