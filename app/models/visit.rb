class Visit < ActiveRecord::Base
  visit = Visit.arel_table
  belongs_to :user
  scope :for_user, -> (user) { where :user => user }
  scope :for_url, -> (url) { where :url => url }
  scope :not_closed, -> { where :close_time => nil }
  scope :contains_localhost, -> {where visit[:url].matches('%://localhost/%').or visit[:url].matches('%://localhost:%')}

  def self.filter_existed_local
    self.contains_localhost.delete_all
  end
end
