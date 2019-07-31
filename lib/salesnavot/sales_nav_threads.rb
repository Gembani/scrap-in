module Salesnavot
  class SalesNavThreads
    include Tools
    def initialize(session)
      @session = session
    end

    def css(count)
      ".msg-conversations-container__conversations-list li:nth-child(#{count + 2})"
    end

    def execute(num_times = 500)
      
      # byebug
      visit_messages_link
      count = 0

      num_times.times.each do
        sleep(2)
        item = @session.find('.infinite-scroller').all('.list-style-none .conversation-list-item').first
        item_limit = @session.find('.infinite-scroller').all('.list-style-none .conversation-list-item').count
        if count >= item_limit
          puts 'item = nil'
          # count = 0
          break
        else
          name = @session.find('.infinite-scroller ul').all('li')[count].find('artdeco-entity-lockup-title').text
          name_click = @session.find('.infinite-scroller ul').all('li')[count].find('artdeco-entity-lockup-title').click
          thread_link = @session.current_url
          yield name, thread_link
          count += 1
        end
        sleep(0.5)
      end
      puts "/!\\ #{count} /!\\".colorize(:blue)
    end

    def visit_messages_link
      @session.all('.nav-item__icon')[0].click
      # wait_messages_page_to_load
      puts 'Messages have been visited.'
    end

    def wait_messages_page_to_load
      time = 0
      # Linkedin display first a first li with a text inside and the last perso we have talked to. The other conversation are loaded a the same time, or nearly almost.
      while @session.all('.msg-conversations-container__conversations-list li').count < 2
        puts 'waiting messages to appear'
        sleep(0.2)
        time += 0.2
        raise 'Cannot scrap conversation. Timeout !' if time > 60
      end
    end
  end
end

# @session.find('.infinite-scroller ul').all('li')[0].find('artdeco-entity-lockup-title').text get the name
# @session.current_url get url