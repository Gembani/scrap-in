require_relative 'search_people'

module ScrapIn
  module LinkedIn
    # LinkedIn company search: yields each company page url with the lines of its card
    # (name, industry, location, followers), left for the caller to judge
    class SearchCompanies < SearchPeople
      def initialize(session, keywords)
        super(session, keywords)
      end

      def search_url(keywords, page, **)
        "https://www.linkedin.com/search/results/companies/?#{URI.encode_www_form(keywords: keywords, page: page)}"
      end

      def link_css
        'a[href*="/company/"], a[href*="/school/"]'
      end

      def result_url(href)
        match = href.to_s.match(%r{linkedin\.com/(company|school)/([^/?#]+)})
        match && "https://www.linkedin.com/#{match[1]}/#{match[2]}/"
      end
    end
  end
end
