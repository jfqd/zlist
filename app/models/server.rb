class Server < ActiveRecord::Base
  
  before_create :generate_public_key
  
  validates_presence_of :name, :ip
  
  private
  
  def generate_public_key
    self.key = Digest::SHA1.hexdigest([Time.now, rand].join)
  end
end
