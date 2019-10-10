# captcha error
module ScrapIn
  class OutOfNetworkError < StandardError
    def initialize(url = '')
      super("Out of network error at url: #{url}")
    end
  end
end
