require 'digest/sha1'
class Topic < ApplicationRecord
  belongs_to :list
  has_many :messages, :dependent => :destroy
  
  before_create :generate_key
  
  private
  
  def generate_key
    self.key = Digest::SHA1.hexdigest([Time.now, rand].join).to(10)
  end
end
