class VisitsController < ApplicationController
  before_action :filter_invalid, :only => [:create, :close]
  after_action :trigger_service
  layout false

  def debug
    # Visit.for_user 1
    # Visit.split_tables
    # Visit.all
    # Visit.where(:user_id => 1)
    # res = Visit.all.for_user(1).each {|a|p a}
    # Visit::Visit2.all
    # User.find 1,2
    res = Visit.all.find_by :id => 12
    render :text => res
  end

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
    host = URI.parse(url).host
    %w(localhost 127.0.0.1).include?(host) || host =~ /^(\d+\.){3}\d+$/
  end

  def host_excluded_url(url)
    uri = URI.parse url
    rule, included = HostRule.get_rule_by_host_port_path uri.host, uri.port, uri.path
    return true if included == false    # nil & true is ok
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
