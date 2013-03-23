class MailHandler < ActionMailer::Base
  include ActionView::Helpers::SanitizeHelper
  
  def self.receive(email)
    email.force_encoding('ASCII-8BIT') if email.respond_to?(:force_encoding)
    super(email)
  end

  # Processes incoming emails
  # Returns true or false
  def receive(email)
    from = email.from.to_a.first.to_s.strip
    user = Subscriber.find_by_email(from) if from.present?
    # validate user
    if user && user.disabled?
      if logger && logger.info
        logger.info  "MailHandler: ignoring email from disabled user [#{from}]"
      end
      return false
    elsif user.nil?
      # Default behaviour, emails from unknown users are ignored
      if logger && logger.info
        logger.info  "MailHandler: ignoring email from unknown user [#{from}]"
      end
      return false
    end
    # validate if user is subscriber
    subscriber = false
    mailbox = mailbox_address = nil
    addresses = [email.to, email.cc].flatten.compact
    addresses.each do |a|
      user.subscriptions.each do |s|
        mailbox_address = a
        mailbox = a.split('@')[0]
        if s.try(:list).try(:name) == mailbox
          subscriber = true
          break
        end
      end
      break if subscriber
    end
    if subscriber == false
      if logger && logger.info
        logger.info  "MailHandler: ignoring email from unsubscribed user [#{from}]"
      end
      return false
    end
    # split plain- and html-parts from email
    text_part = email.text_part || email
    html_part = email.html_part
    header = email.header
    # create hash
    hash = {}
    hash[:subject]      = email.subject.to_s
    hash[:to]           = mailbox_address
    hash[:from]         = from
    hash[:cc]           = email.cc.nil?  ? '' : email.cc.join(', ')
    hash[:headers]      = "" # header.nil? || header.to_s.nil? ? [] : header.to_s.split("\r\n")
    hash[:text]         = text_part.nil? ? '' : Zlist::Encoder.to_utf8(text_part.body.decoded, text_part.charset)
    hash[:html]         = html_part.nil? ? '' : Zlist::Encoder.to_utf8(html_part.body.decoded, html_part.charset)
    hash[:reply]        = email.reply_to
    hash[:message_id]   = email.message_id
    hash[:mailbox_hash] = '' #mailbox
    hash[:mailbox]      = mailbox
    # any attachements?
    if email.has_attachments?
    end
    # debug
    puts "hash= #{hash.inspect}"
    # process email
    Inbound::Email.new(hash).process
    #
    return true
  end
  
  private
  
  def logger
    Rails.logger
  end
end
