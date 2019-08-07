module ScrapIn
  # Goes to 'profile views' page and get all persons who viewed our profile
  class ProfileViews
    include Tools
    include CssSelectors::ProfileViews

    attr_reader :profile_viewed_by

    def initialize(session)
      @session = session
      @profile_viewed_by = []
    end

    def execute(num_times = 50)
      visit_target_page(target_page)
      search_for_leads(num_times) { |name, time_ago| yield name, time_ago }
    end

    def search_for_leads(num_times, count = 1, not_a_lead = 0) 
      while count <= num_times
        i = not_a_lead + count
        if @session.has_selector?(profile_view_css(i), wait: 1)
          find_name_and_time_ago(i) { |name, time_ago| yield name, time_ago }
          count += 1
        elsif @session.has_selector?(semi_private_css(i), wait: 1)
          not_a_lead += 1
        else
          break if @session.all(last_element_css(i)).count == 1
          not_a_lead += 1
        end
      end
    end

    def visit_target_page(link)
      @session.visit(link)
      raise css_error(viewers_list_css) unless @session.has_selector?(viewers_list_css)
    end

    def find_name_and_time_ago(number)
      item = @session.find(profile_view_css(number))
      scroll_to(item)
      name = item.find(name_css).text
      time_ago = item.find(time_ago_css).text
      return if name.empty?
      yield name, time_ago
      @profile_viewed_by.push name
    end

    def target_page
      'https://www.linkedin.com/me/profile-views/'
    end
  end
end
