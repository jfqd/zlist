class MailHandler < ActionMailer::Base
  include ActionView::Helpers::SanitizeHelper
  
  def self.receive(email)
    email.force_encoding('ASCII-8BIT') if email.respond_to?(:force_encoding)
    super(email)
  end
  
  # Processes incoming emails
  # Returns true or false
  def receive(email)
    @email = email
    return false if !subscriber? && !subscribe_request?
    Inbound::Email.new(hash).process
    return true
  end
  
  private
  
  TOPIC_RE = %r{\[[^\]]*#(\d+)\]}
  
  def from
    @from ||= @email.from.to_a.first.to_s.strip
  end
  
  def to
    @to
  end
  
  def cc
    @email.cc.nil?  ? '' : @email.cc.join(', ')
  end
  
  def subject
    @subject ||= @email.subject.to_s
  end
  
  def subscriber
    @subscriber ||= (from.present? ? Subscriber.find_by_email(from) : nil)
  rescue
    nil
  end
  
  def subscriber?
    if subscriber.nil?
      log "MailHandler: ignoring email from unknown user [#{from}]"
      return false
    elsif subscriber.disabled?
      log "MailHandler: ignoring email from disabled user [#{from}]"
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
      log "MailHandler: ignoring email from unsubscribed user [#{from}]"
      return false
    end
    return true
  end
  
  def subscribe_request?
    subject.downcase == "subscribe"
  end
  
  def text_part
    @text_part ||= @email.html_part || @email
  end
  
  def html_part
    @html_part ||= @email.html_part
  end
  
  def encode(part)
    Zlist::Encoder.to_utf8(part.body.decoded, part.charset)
  end
  
  def header
    @header ||= (@email.header.nil? || @email.header.to_s.nil? ? [] : @email.header.to_s.split("\r\n"))
  rescue
    []
  end
  
  def mailbox_hash
    m = subject.match(TOPIC_RE)
    m[1] || ''
  rescue
    ''
  end
  
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
    hash[:mailbox]      = @mailbox
    # puts hash.inspect
    hash
  end
  
  def attachements?
    @email.has_attachments?
  end
  
  def log(message)
    logger.info(message) if logger && logger.info
  end
  
  def logger
    Rails.logger
  end
end
