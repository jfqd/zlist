class List < ApplicationRecord

  has_many :subscriptions, dependent: :destroy
  has_many :subscribers, -> { distinct.order(:name) }, through: :subscriptions
  has_many :topics, dependent: :destroy

  default_scope { order(:name) }

  scope :is_public,  ->{ where(private: false) }
  scope :is_private, ->{ where(private: true) }

  validates_presence_of :name, :mailbox

  before_validation :set_defaults, on: :create

  def email
    if mailbox.include?('@')
      mailbox
    else
      mailbox + "@" + ENV['EMAIL_DOMAIN']
    end
  end

  def domain
    if ENV['SUBDOMAIN'].present?
      ENV['SUBDOMAIN'] + "." + ENV['EMAIL_DOMAIN']
    else
      ENV['EMAIL_DOMAIN']
    end
  end

  private

  def set_defaults
    self.subject_prefix    ||= name
    self.send_replies_to   ||= "Subscribers"
    self.message_footer    ||= "None"
    self.permitted_to_post ||= "Subscribers"
  end

end
