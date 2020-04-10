module ScrapIn
  module SalesNavigator
    # Goes on list page and get profile and image links of all leads
    class ScrapSearchList
      include Tools
      include CssSelectors::SalesNavigator::ScrapSearchList

      def initialize(session, saved_search_link)
        @session = session
        @saved_search_link = saved_search_link
        @links = []
        @error = nil
        @homepage = 'https://www.linkedin.com/sales'
      end

      def execute(page = 1)
        @session.visit(@saved_search_link)
        visit_page(page)
        find_page_leads(page) do |link|
          yield link
        end
      end

      def click_on_page(page)
        # sometimes the click on page two fails... not sure why.
        raise "Did not successfully click on #{page}" unless check_until(5) do 
          puts "clicking on page #{page}"
          page_button = check_and_find(@session, page_css(page))
          page_button.click
          @session.current_url.include?("page=#{page}")
        end
        
        
        check_results_loaded
      end

      def check_results_loaded
        raise CssNotFound, results_loaded_css unless check_until(10) do
          @session.has_selector?(results_loaded_css)
        end
      end

      # if page 2 empty results fails - don't use this with a too small search!
      def visit_page(page)
        return if page == 1

        # While "clicking" on page 2, url changes in the way we can substitue "page=x"
        click_on_page(2)
        return if page == 2

        url = @session.current_url.sub('page=2', "page=#{page}")
        puts "Going to page #{page}"
        @session.visit(url)
        
        check_results_loaded
      end

      def find_page_leads(page)
        ensure_leads_are_loaded
       
        count = 0
        raise CssNotFound, nth_result_css(count) unless check_until(5) do
          @session.has_selector?(nth_result_css(count))
        end

        loop do 
          break unless @session.has_selector?(nth_result_css(count), wait: 5)

          element = @session.find(nth_result_css(count))
          link = element[:href]
          yield link
          count += 1
          scroll_to(element)
        end
        last_page = check_and_find(@session, last_page_css).text.to_i
        
        if page == last_page 
          1
        else
          page + 1
        end
      end

      def ensure_leads_are_loaded
        raise CssNotFound, '.result-lockup__icon-link' unless check_until(5) do
          @session.has_selector?('.result-lockup__icon-link')
        end
      end
    end
  end
end
