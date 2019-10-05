module ScrapIn
  class LeadIsFriend < StandardError
    attr_reader :selector

    def initialize(profile_url: '')
      message = "The current lead is friended. Profile url: #{profile_url}"
      @message = message
      @profile_url = profile_url
      super(@message)
    end
  end
end
