module Salesnavot
  class Auth
    def initialize(session)
      @session = session
    end
    def login!(username, password)
      @session.visit("https://www.linkedin.com/sales")
      @session.fill_in "Email", with: username
      @session.fill_in "Password", with: password
      @session.find("body").native.send_keys(:return)
      sleep(4)
    end

  end
end
