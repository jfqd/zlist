class MailHandler < ActionMailer::Base
  include ActionView::Helpers::SanitizeHelper
  
  def self.receive(email)
    email.force_encoding('ASCII-8BIT') if email.respond_to?(:force_encoding)
    super(email)
  end
  
  # Processes incoming emails
  # Returns true or false on any errors
  def receive(email)
    @email = email
    return false if !subscriber? && !subscribe_request?
    Inbound::Email.new(hash).process
    return true
  end
  
  private
  
  # Regex to extract the topic.id out of the subject
  TOPIC_RE = %r{\[[^\]]*#(\d+)\]}
  
  # Returns from which mail-address the email was send
  def from
    @from ||= @email.from.to_a.first.to_s.strip
  end
  
  # Returns the mail-address of the mailinglist. For
  # subscribe requests it is the first mail-address
  # in the array
  def to
    @to || @email.to.first
  end
  
  # Returns carbon copy-addresses as a comma separated string
  def cc
    @email.cc.nil? ? '' : @email.cc.join(', ')
  end
  
  # Returns the subject of the email
  def subject
    @subject ||= @email.subject.to_s
  end
  
  # Returns the subscribers of the requested mailinglist
  def subscriber
    @subscriber ||= (from.present? ? Subscriber.find_by_email(from) : nil)
  rescue
    nil
  end
  
  # Returns true if the sender is a subscriber of
  # the requested mailinglist
  def subscriber?
    if subscriber.nil?
      log "MailHandler: ignoring email from unknown user [#{from}]" unless subscribe_request?
      return false
    elsif subscriber.disabled?
      log "MailHandler: ignoring email from disabled user [#{from}]" unless subscribe_request?
      return false
    end
    _subscriber = false
    addresses = [@email.to, @email.cc].flatten.compact
    addresses.each do |a|
      subscriber.subscriptions.each do |s|
        @to = a
        @mailbox = a.split('@')[0]
        if s.try(:list).try(:name) == @mailbox
          _subscriber = true
          break
        end
      end
      break if _subscriber
    end
    if _subscriber == false
      log "MailHandler: ignoring email from unsubscribed user [#{from}]" unless subscribe_request?
      return false
    end
    return true
  end
  
  # Returns true if it is a subscribe request
  def subscribe_request?
    subject.downcase == "subscribe"
  end
  
  # Returns the text-part of the email. Falling
  # back to the email itself if it is plain-text
  def text_part
    @text_part ||= @email.text_part || @email
  end
  
  # Returns the html-part of the email if present.
  # If not nil is returned
  def html_part
    @html_part ||= @email.html_part
  end
  
  # Returns utf8 encoded parts
  def encode(part)
    Zlist::Encoder.to_utf8(part.body.decoded, part.charset)
  end
  
  # Returns an array of the email-headers
  def header
    @header ||= (@email.header.nil? || @email.header.to_s.nil? ? [] : @email.header.to_s.split("\r\n"))
  rescue
    []
  end
  
  # Name of the mailinglist, for subscribe
  # requests it is the name of the account
  # without the domain
  def mailbox
    @mailbox || to.split('@')[0]
  end
  
  # Returns the topic.id, present only for replies
  def mailbox_hash
    m = subject.match(TOPIC_RE)
    m[1] || ''
  rescue
    ''
  end
  
  # Returns a hash with a relevant information
  # for the next step in process
  def hash
    hash = {}
    hash[:subject]      = subject
    hash[:to]           = to
    hash[:from]         = from
    hash[:cc]           = cc
    hash[:headers]      = header
    hash[:text]         = text_part.present? ? encode(text_part) : ''
    hash[:html]         = html_part.present? ? encode(html_part) : ''
    hash[:reply]        = @email.reply_to
    hash[:message_id]   = @email.message_id
    hash[:mailbox_hash] = mailbox_hash
    hash[:mailbox]      = mailbox
    # puts hash.inspect
    hash
  end
  
  # Returns true if the email has attachements
  def attachements?
    @email.has_attachments?
  end
  
  # log a message to Rails.logger if present
  def log(message)
    logger.info(message) if logger && logger.info
  end
  
  def logger
    Rails.logger
  end
end
