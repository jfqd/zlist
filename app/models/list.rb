class List < ActiveRecord::Base
  has_many :subscriptions, :dependent => :destroy
  has_many :subscribers, :through => :subscriptions
  has_many :topics
  
  validates_presence_of :name, :short_name
  
  after_update :save_subscribers
  
  attr_accessible :name, :description, :short_name, :subscriber_ids
  
  def email
    short_name + "@" + APP_CONFIG[:email_domain]
  end
  
  #def short_name=(short_name)
    # This method needs to rewrite the user submitted short_name
    # to ensure that it's email address compatible.
    # All you, David.
  #end
  
  #def subscribers=(subscribers)
  #  
  #  # Handle new subscribers
  #  if subscribers[:new_subscribers].present?
  #    subscribers[:new_subscribers].each do |data|
  #      subscribers.build(data) if data[:email].present?
  #    end
  #  end
  #  
  #  # Handle existing subscribers
  #  subscribers.reject(&:new_record?).each do |data|
  #    attributes = subscribers[:existing_subscribers][data.id.to_s]
  #    if attributes && attributes[:email].present?
  #      data.attributes = attributes
  #    else
  #      subscribers.delete(data)
  #    end
  #  end 
  #end
  
  private
  
  def save_subscribers
    subscribers.each do |s|
      s.save(false)
    end
  end
end
