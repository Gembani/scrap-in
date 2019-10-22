require 'forwardable'

module ScrapIn
  module SalesNavigator
    class SendMessage
      PROFILE_MATCHER =   /https:\/\/(www\.|)linkedin\.com\/sales\/(people|profile)\/.*/
      THREAD_MATCHER  =   /https:\/\/(www\.|)linkedin\.com\/sales\/inbox\/.*/
    
      include Tools
      extend Forwardable
      def_delegators :@thread_or_profile, :message_sent?, :visit, :write_message, :send_message
      
      def initialize(session, thread_or_profile, message)
        if thread_or_profile.match(PROFILE_MATCHER)
          @thread_or_profile = SendMessageProfile.new(session, thread_or_profile)
        elsif thread_or_profile.match(THREAD_MATCHER)
          @thread_or_profile = SendMessageThread.new(session, thread_or_profile)
        else 
          raise ArgumentError.new("This url is not a sales nav thread or profile url")
        end
        @session = session
        @message = message
      end
      def execute(send = true)
        return false unless visit
        write_message(@message)
        send_message(send)
        message_sent?(@message)
      end
    end
  end
end
