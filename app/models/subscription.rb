class Subscription < ApplicationRecord
  belongs_to :list
  belongs_to :subscriber
  
  validates_presence_of :list_id, :subscriber_id
end
