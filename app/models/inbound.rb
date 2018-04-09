module Inbound

  class Email

    attr_accessor :subject, :to, :from, :cc, :headers, :html_body, :text_body, :attachments, :reply_to, :message_id, :mailbox_hash, :mailbox

    def initialize(email)
      @subject      = smtp? ? email.fetch(:subject)      : email.fetch("Subject")
      @to           = smtp? ? email.fetch(:to)           : email.fetch("ToFull").first.fetch("Email")
      @from         = smtp? ? email.fetch(:from)         : email.fetch("FromFull").fetch("Email")
      @cc           = smtp? ? email.fetch(:cc)           : email.fetch("Cc")
      @headers      = smtp? ? email.fetch(:headers)      : email.fetch("Headers").map{|h| Header.new(h)}
      @html_body    = smtp? ? email.fetch(:html)         : HTMLEntities.new.decode(email.fetch("HtmlBody"))
      @text_body    = smtp? ? email.fetch(:text)         : email.fetch("TextBody")
      @attachments  = smtp? ? nil                        : email.fetch("Attachments").map{|a| Attachment.new(a)}
      @reply_to     = smtp? ? email.fetch(:reply)        : email.fetch("ReplyTo")
      @message_id   = smtp? ? email.fetch(:message_id)   : email.fetch("MessageID")
      @mailbox_hash = smtp? ? email.fetch(:mailbox_hash) : email.fetch("MailboxHash")
      @mailbox      = smtp? ? email.fetch(:mailbox)      : @to.match(/^([\w\-]+)\+?([0-9a-f]*)\@([\w\.]+)$/).to_a[1..3].first
    end

    def process
      # Make sure the list exists
      list = List.find_by(mailbox: to)
      Mailman.no_such_list(self).deliver && return unless list

      # Make sure the sender is in the list (allowed to post)
      author = list.subscribers.find_by(email: from)
      if author.nil? || author.disabled?
        if subscribe_request?
          # Subscribe request
          admins = list.subscribers.admin rescue []
          admins.each do |admin|
            Mailman.to_list_admin(list, admin, self, "Subscribe").deliver
          end
        else
          # Not a valid mailinglist member
          Mailman.cannot_post(list, self).deliver
        end
        return
      elsif subscribe_request?
        # Author has already subscribed to this list
        Mailman.author_is_subscriber(list, self).deliver
        return
      elsif unsubscribe_request?
        # Unsubscribe request
        admins = list.subscribers.admin rescue []
        admins.each do |admin|
          Mailman.to_list_admin(list, admin, self, "Unsubscribe").deliver
        end
        return
      end
      
      # Check if this is a response to an existing topic or a new message
      if mailbox_hash.present?
        topic = (smtp? ? Topic.find_by(id:mailbox_hash.to_i) : Topic.find_by(key: mailbox_hash))

        # Notify the sender that the topic does not exist even though they provided a topic hash
        Mailman.no_such_topic(list, self).deliver && return unless topic

        # Reset the subject so it doesn't contain the prefix
        self.subject = topic.name

      else
        topic = list.topics.create(:name => subject)
      end

      # Store the message
      message = topic.messages.create(:subject => subject, :body => text_body, :author => author)

      # Deliver to subscribers
      Rails.logger.warn "Sending out emails for list '#{list.name}' with subject '#{self.subject}'."
      list.subscribers.each do |subscriber|
        begin
          unless subscriber.disabled?
            if self.html_body.present? && !subscriber.plain_text?
              Mailman.to_mailing_list(topic, self, subscriber, message).deliver
            else
              Mailman.to_mailing_list_as_plaintext(topic, self, subscriber, message).deliver
            end
          end
        rescue => e
          Rails.logger.warn "SEND ERROR: #{e}"
        end
      end # list.subscribers.each

    end
    
    private
    
    def subscribe_request?
      @subject.downcase == "subscribe"
    end
    
    def unsubscribe_request?
      @subject.downcase == "unsubscribe"
    end
    
    def smtp?
      Server.smtp?
    end

  end

  class Attachment

    attr_accessor :content, :content_length, :content_type, :name

    def initialize(attachment)
      @content        = attachment.fetch("Content")
      @content_length = attachment.fetch("ContentLength")
      @content_type   = attachment.fetch("ContentType")
      @name           = attachment.fetch("Name")
    end

  end

  class Header

    attr_accessor :name, :value

    def initialize(header)
      @name  = header.fetch("Name")
      @value = header.fetch("Value")
    end

  end

end
