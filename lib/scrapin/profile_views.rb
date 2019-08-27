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

      search_for_leads(num_times) do |name, time_ago|
        yield name, time_ago
      end
      true
    end

    def search_for_leads(num_times)
      count = 0
      bad_profile_count = 0 # semi private or last element (informative element)
      until count == num_times
        position = bad_profile_count + count + 1
        if profile_is_public(position)
          item = find_profile_view(position)
          yield name(item), time_ago(item)
          count += 1
        else
          bad_profile_count += 1
          break if current_profile_is_last_element(position)
        end
      end
    end

    def find_profile_view(position)
      item = check_and_find(@session, public_profile_css(position), wait: 1)
      scroll_to(item)
      item
    end

    def profile_is_public(position)
      @session.has_selector?(public_profile_css(position), wait: 1)
    end

    def current_profile_is_last_element(position)
      @session.has_selector?(last_element_css(position), wait: 1)
    end

    def visit_target_page(link)
      @session.visit(link)
      raise CssNotFound.new(viewers_list_css) unless @session.has_selector?(viewers_list_css)
    end

    def name(item)
      name = check_and_find(item, name_css).text
      @profile_viewed_by.push name
      name
    end

    def time_ago(item)
      check_and_find(item, time_ago_css).text
    end

    def target_page
      'https://www.linkedin.com/me/profile-views/'
    end
  end
end
