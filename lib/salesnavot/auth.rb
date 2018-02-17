module Salesnavot
  class Auth
    def initialize(session)
      @session = session
    end

    def login!(username, password)
      puts "visiting login screen"
      @session.visit("https://www.linkedin.com/sales")

      puts "adding email & password"
      @session.fill_in "Email", with: username
      @session.fill_in "Password", with: password

      puts "click login"
      @session.find('.btn-primary').click

      #We wait until de navbar appears
      count = 0
      while @session.all('#stream-container').count == 0
        puts "waiting for login"
        count = count + 1
        raise "Failed on login" if count > 30
        sleep(1)
      end
    end

  end
end
