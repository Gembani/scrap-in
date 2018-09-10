module Salesnavot
  # Goes to 'profile views' page and get all persons who viewed our profile
  class ProfileViews
    include Tools
    attr_reader :profile_viewed_by
    def initialize(session)
      @session = session
      @profile_viewed_by = []
    end

    def css(count)
      'section.me-wvmp-viewers-list '\
      "article[data-control-name=\"profileview_single\"]:nth-child(#{count})"
    end

    def last_element_css(count)
      'section.me-wvmp-viewers-list '\
       "article[data-control-name=\"profileview_private\"]:nth-child(#{count})"
    end

    def find_name_and_time_ago(number)
      item = @session.find(css(number))
      scroll_to(item)
      name = item.find('.me-wvmp-viewer-card__name-text').text
      time_ago = item.find('.me-wvmp-viewer-card__time-ago').text
      unless name.empty?
        yield name, time_ago
        @profile_viewed_by.push name
      end
    end

    def execute(num_times = 50)
      return unless init_list(target_page)

      count = 1
      i = 1
      not_a_lead = 0
      while count <= num_times
        i = not_a_lead + count
        if @session.has_selector?(css(i), wait: 1)
          find_name_and_time_ago(i) { |name, time_ago| yield name, time_ago }
          count += 1
        else
          break if @session.all(last_element_css(i)).count == 1
          not_a_lead += 1
        end
      end
    end

    def target_page
      'https://www.linkedin.com/me/profile-views/'
    end

    def init_list(link)
      @session.visit(link)
      return false unless @session.has_selector?('section.me-wvmp-viewers-list')
      true
    end
  end
end
