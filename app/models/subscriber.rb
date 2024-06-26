require 'digest/sha1'
class Subscriber < ApplicationRecord
  has_many :subscriptions, dependent: :destroy
  has_many :lists, through: :subscriptions #, uniq: true

  has_many :writings, :class_name => 'Message', :foreign_key => 'subscriber_id', :dependent => :destroy
  
  validates_uniqueness_of :email
  validates_format_of :email, :with => /\A[-a-z0-9_+\.]+\@([-a-z0-9]+\.)+[a-z0-9]{2,8}\z/i
  validates_presence_of :password, :if => :saving_password?
  validates_presence_of :name
  validates_confirmation_of :password
  
  before_save   :prepare_password, :if => :saving_password?
  before_create :generate_public_key
  
  default_scope ->{ order(:name) }
  
  attr_accessor :password, :saving_password
  
  scope :active,   ->{ where(disabled: false).order(:name) }
  scope :disabled, ->{ where(disabled: true).order(:name) }
  scope :admin,    ->{ where(admin true).order(:name) }
  
  # Search based on 'term' parameter
  scope :search, ->(term) { where("subscribers.name LIKE ? OR subscribers.email LIKE ?", "%" + term + "%", "%" + term + "%").order(:name) }
  
  def self.find_subscribers_not_in_list(list_id)
    find_by_sql ["SELECT * FROM subscribers WHERE id NOT IN 
                      (SELECT DISTINCT subscriber_id FROM subscriptions WHERE list_id = ?) ORDER BY subscribers.name", list_id ]
  end
  
  # Login with email address
  def self.authenticate(login, pass)
    user = Subscriber.find_by(email: login)
    return user if user && user.matching_password?(pass)
  end
  
  def matching_password?(pass)
    self.password_hash == encrypt_password(pass) && login_permitted?
  end
  
  def login_permitted?
    self.password_hash.present?
  end
  
  private
  
  def prepare_password
    self.password_salt = Digest::SHA1.hexdigest([Time.now, rand].join)
    self.password_hash = encrypt_password(password)
  end
  
  def encrypt_password(pass)
    self.class.password_digest(pass, password_salt)
  end
  
  # saving_password is set inside of the
  # SubscribersController#create request
  def saving_password?
    saving_password
  end
  
  def generate_public_key
    self.public_key = Digest::SHA1.hexdigest([Time.now, rand].join)
  end
  
  class << self
    def secure_digest(*args)
      Digest::SHA1.hexdigest(args.flatten.join('--'))
    end

    def password_digest(password, salt)
      digest = ENV['SECRET_TOKEN']
      15.times do
        digest = secure_digest(digest, salt, password, ENV['SECRET_TOKEN'])
      end
      digest
    end
  end
  
end
