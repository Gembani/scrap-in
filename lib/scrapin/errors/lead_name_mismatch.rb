module ScrapIn
  class LeadNameMismatch < StandardError
    def initialize(lead_name_in_thread, lead_name)
      @message = "Lead name mismatch. Lead in thread = #{lead_name_in_thread} / Lead name given = #{lead_name}"
      super(@message)
    end
  end
end
