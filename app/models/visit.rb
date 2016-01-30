class Visit < ActiveRecord::Base
  belongs_to :user
  scope :for, -> (user) { where :user => user }
  scope :not_closed, -> { where :close_time => nil }
end
