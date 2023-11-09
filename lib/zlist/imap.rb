require 'net/imap'

module Zlist
  module Imap
    class << self
      def check(imap_options={})
        host = imap_options[:host] || '127.0.0.1'
        port = imap_options[:port] || '143'
        ssl = !imap_options[:ssl].nil?
        folder   = imap_options[:folder] || 'INBOX'
        move_on_failure = imap_options[:move_on_failure] || 'failure'
        move_on_success = imap_options[:move_on_success] || 'success'
        
        imap = Net::IMAP.new(host, port: port, ssl: ssl)
        imap.login(imap_options[:username], imap_options[:password]) unless imap_options[:username].nil?
        imap.select(folder)
        imap.search(['NOT', 'SEEN']).each do |message_id|
          msg = imap.fetch(message_id,'RFC822')[0].attr['RFC822']
          logger.debug "Receiving message #{message_id}" if logger && logger.debug?
          if MailHandler.receive(msg)
            logger.debug "Message #{message_id} successfully received" if logger && logger.debug?
            imap.copy(message_id, move_on_success) if move_on_success
            imap.store(message_id, "+FLAGS", [:Seen, :Deleted])
          else
            logger.debug "Message #{message_id} can not be processed" if logger && logger.debug?
            imap.store(message_id, "+FLAGS", [:Seen])
            if move_on_failure
              imap.copy(message_id, move_on_failure)
              imap.store(message_id, "+FLAGS", [:Deleted])
            end
          end
        end
        imap.expunge
        imap.logout
        imap.disconnect
      end
      
      private
      
      def logger
        ::Rails.logger
      end
    end
  end
end
