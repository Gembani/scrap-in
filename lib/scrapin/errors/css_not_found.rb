module ScrapIn
  class CssNotFound < StandardError
    attr_reader :selector

    def initialize(selector = '', text = '')
      @selector = selector
      @message = "Css selector not found -> #{selector}"
      @message = "#{@message} with text: #{text}" unless text.empty?
      super(@message)
    end
  end
end
