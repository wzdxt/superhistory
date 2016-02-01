class Visit < ActiveRecord::Base
  belongs_to :user
  scope :for_user, -> (user) { where :user => user }
  scope :for_url, -> (url) { where :url => url }
  scope :not_closed, -> { where :close_time => nil }
end
