class Mailman < ActionMailer::Base
  default :from => "#{ ENV['EMAIL_DOMAIN'] } <mailer@#{ ENV['EMAIL_DOMAIN'] }>"

  # Send a test to the list
  def list_test_dispatch(list)
    list.subscribers.each do |subscriber|
      mail(
        :to      =>  "#{subscriber.name} <#{subscriber.email}>",
        :subject => "[#{list.name}] Test Mailing",
        :date     => Time.zone.now
      )
    end
  end

  # Response to a message posted to a list that doesn't exist
  def no_such_list(email)
    @address = email.to
    mail(
      :to      =>  email.from,
      :subject =>  "Mailinglist '#{@address}' does not exist",
      :date    => Time.zone.now
    )
  end

  # Response to a message posted in reply to a topic that doesn't exist
  def no_such_topic(list, email)
    @list = list.name
    mail(
      :to      => email.from,
      :subject => "[#{list.name}] Topic no longer exists: #{email.subject}",
      :date     => Time.zone.now
    )
  end

  # Response to a message sent to a noreply address
  def no_reply_address(email)
    mail(
      :to      => email.from,
      :subject => "Replies to this email-address are not monitored.",
      :body    => "We're sorry, but this email-address is not monitored
                   for replies. Your message has been discarded.",
      :date    => Time.zone.now
    )
  end

  # Reponse to a message posted to a list by a non-member
  def cannot_post(list, email)
    @list = list.name
    mail(
      :to      => email.from,
      :subject => "[#{list.name}] You're not allowed to post to this list",
      :date    => Time.zone.now
    )
  end
  
  def to_list_admin(list, admin, email, reason="Subscribe")
    mail(
      :to      => admin.email,
      :subject => "[#{list.name}] #{reason} request from #{email.from}",
      :body    => "#{reason} request from #{email.from} to the list '#{list.name}'",
      :date    => Time.zone.now
    )
  end

  def author_is_subscriber(list, email)
    mail(
      :to      => email.from,
      :subject => "[#{list.name}] You are already a subscriber of this list",
      :date    => Time.zone.now
    )
  end

  # Send an e-mail out to a list
  def to_mailing_list(topic, email, subscriber, message)
    @email = email
    
    # Set additional headers
    headers['List-ID']          = topic.list.email
    headers['List-Post']        = topic.list.email
    # headers['List-Unsubscribe'] = "#{ENV['PROTOCOL'] || "http"}://#{topic.list.domain}/lists/#{ topic.list.id }/unsubscribe"
    headers['Reply-To']         = reply_to_address(topic, message)

    mail(
      :to       => "#{subscriber.name} <#{subscriber.email}>",
      :from     => "#{message.author.name} via #{topic.list.name} <#{topic.list.email}>",
      # :from     => "#{message.author.name} <#{message.author.email}>",
      :subject  => subject(topic),
      :date     => Time.zone.now
    )
  end

  def to_mailing_list_as_plaintext(topic, email, subscriber, message)
    @email = email
    
    # Set additional headers
    headers['List-ID']          = topic.list.email
    headers['List-Post']        = topic.list.email
    # headers['List-Unsubscribe'] = "#{ENV['PROTOCOL'] || "http"}://#{topic.list.domain}/lists/#{ topic.list.id }/unsubscribe"
    headers['Reply-To']         = reply_to_address(topic, message)
    
    mail(
      :to       => "#{subscriber.name} <#{subscriber.email}>",
      :from     => "#{message.author.name} via #{topic.list.name} <#{topic.list.email}>",
      # :from     => "#{message.author.name} <#{message.author.email}>",
      :subject  => subject(topic),
      :body     => @email.text_body,
      :date     => Time.zone.now
    )
  end
  
  private
  
  def reply_to_address(topic, message)
    case topic.list.send_replies_to
    when "Subscribers"
      if Server.smtp?
        topic.list.email
      else
        "#{topic.list.name}+#{topic.key}@#{ENV['EMAIL_DOMAIN']}"
      end
    when "Author"
      "#{message.author.name} <#{message.author.email}>"
    else
      "#{message.author.name} <#{message.author.email}>"
    end
  end
  
  def subject(topic)
    if topic.list.subject_prefix.present?
      if Server.smtp?
        s = "[#{topic.list.subject_prefix}##{topic.id}] #{@email.subject}"
        s = "Re: #{s}" if topic.messages && topic.messages.size > 1
        s
      else
        "[#{topic.list.subject_prefix}] #{@email.subject}"
      end
    else
      @email.subject
    end
  end
  
end
