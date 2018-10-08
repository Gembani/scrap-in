module Salesnavot
  # Goes to "Sent invitations" page, and scrap all leads that were invited
  class ThreadFromName
    def initialize(session)
      @session = session
    end

    def target_page
      'https://www.linkedin.com/messaging/'
    end

    def seach_conversations_css
      '#search-conversations'
    end


    def title_matches_name(name)
      "//*[contains(@class,'msg-entity-lockup')]/dl/dt/h2[contains(.,'#{name}')]"
    end
    def search_list_name_xpath(name)
      "//*[contains(@class,'msg-conversation-card')]/div[2]/div[1]/h3[contains(.,'#{name}')]"
    end
    def execute(name)
      @session.visit(target_page)
      raise "Cannot find seach input" unless @session.has_selector?(seach_conversations_css)
      seach_input = @session.find(seach_conversations_css)
      seach_input.set(name)
      seach_input.send_keys(:enter)
      raise "Names not found" unless @session.has_selector?(:xpath, search_list_name_xpath(name))
      @session.all(:xpath, search_list_name_xpath(name)).first.click
      raise "Names does not match " unless @session.has_selector?(:xpath, title_matches_name(name))
      @session.current_url.chomp("/?searchTerm=#{URI::encode(name)}")
    end
  end
end

#ember6440
