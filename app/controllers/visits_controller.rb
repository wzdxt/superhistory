class VisitsController < ApplicationController
  before_action :filter_local, :only => [:create, :close]
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
    render if %w(localhost 127.0.0.1).include? referer.match(/http[s]?:\/\/([\w|\.]+)[:|\/]/)[1]
  end

  def referer
    params[:referer]
  end
end
