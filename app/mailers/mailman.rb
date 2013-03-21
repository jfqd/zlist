class Mailman < ActionMailer::Base
  default :from => "#{ ENV['EMAIL_DOMAIN'] } <mailer@#{ ENV['EMAIL_DOMAIN'] }>"

  # Send a test to the list
  def list_test_dispatch(list)
    list.subscribers.each do |subscriber|
      mail(
        :to      =>  "#{subscriber.name} <#{subscriber.email}>",
        :subject => "[#{list.short_name}] Test Mailing"
      )
    end
  end

  # Response to a message posted to a list that doesn't exist
  def no_such_list(email)
    @address = email.to
    mail(
      :to      =>  email.from,
      :subject =>  "Mailinglist '#{@address}' does not exist"
    )
  end

  # Response to a message posted in reply to a topic that doesn't exist
  def no_such_topic(list, email)
    @list = list.name
    mail(
      :to      => email.from,
      :subject => "[#{list.name}] Topic no longer exists: #{email.subject}"
    )
  end

  # Response to a message sent to a noreply address
  def no_reply_address(email)
    mail(
      :to      => email.from,
      :subject => "Replies to this address are not monitored.",
      :body    => "We're sorry, but the mailer@#{ ENV['EMAIL_DOMAIN'] } address
                   is not monitored for replies. Your message has been discarded."
    )
  end

  # Reponse to a message posted to a list by a non-member
  def cannot_post(list, email)
    @list = list.name
    mail(
      :to      => email.from,
      :subject => "[#{list.name}] You're not allowed to post to this list"
    )
  end

  # Send an e-mail out to a list
  def to_mailing_list(topic, email, subscriber, message)
    @email = email

    # Determine the reply-to address
    reply_to_address = case topic.list.send_replies_to
    when "Subscribers"
      if ActionMailer::Base.delivery_method == :smtp
        "#{topic.list.short_name}@#{ENV['EMAIL_DOMAIN']}"
      else
        "#{topic.list.short_name}+#{topic.key}@#{ENV['EMAIL_DOMAIN']}"
      end
    when "Author"
      "#{message.author.name} <#{message.author.email}>"
    else
      "#{message.author.name} <#{message.author.email}>"
    end

    # Determine the subject
    if topic.list.subject_prefix.present?
      subject = [topic.list.subject_prefix, email.subject].join(" ")
    else
      subject = email.subject
    end

    # Set additional headers
    headers['List-ID']          = topic.list.email
    headers['List-Post']        = topic.list.email
    headers['List-Unsubscribe'] = "http://#{topic.list.domain}/lists/#{ topic.list.id }/unsubscribe"
    headers['Reply-To']         = reply_to_address
    
    headers['Topic'] = topic.name if ActionMailer::Base.delivery_method == :smtp

    mail(
      :to       => "#{subscriber.name} <#{subscriber.email}>",
      :from     => "#{message.author.name} <mailer@#{ENV['EMAIL_DOMAIN']}>",
      :subject  => subject
    )
  end

end
