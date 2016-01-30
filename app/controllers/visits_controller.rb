class VisitsController < ApplicationController
  before_action :filter_local
  layout false
  def create
    visit = Visit.create! :user => current_user, :url => request.referer, :open_time => Time.now
    render :text => visit.id
  end

  def close
    Visit.for(current_user).find(params[:id]).update :close_time => Time.now
  end

  private
  def visit_params
    params.require(:visit).permit!
  end

  def filter_local
    render if %w(localhost 127.0.0.1).include? request.referer.match(/http[s]?:\/\/([\w|\.]+)[:|\/]/)[1]
  end
end
