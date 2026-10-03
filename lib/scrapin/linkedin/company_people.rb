module ScrapIn
  module LinkedIn
    # The people working at a company (or studying at a school), optionally filtered by keywords ("gérant", "chef").
    # Uses the page's own "N employees" search when there is one, else its People tab.
    # Yields each profile url with the lines of its card.
    class CompanyPeople
      include Tools

      PEOPLE_CARD_CSS = 'main li'.freeze

      def initialize(session, company_url, keywords: nil)
        @session = session
        @company = ScrapCompany.new(session, company_url)
        @keywords = keywords
      end

      def execute(pages = 1, &block)
        company_id = @company.company_id
        return SearchPeople.new(@session, @keywords, current_company: company_id).execute(pages, &block) if company_id

        people_tab(&block)
      end

      private

      def people_tab
        query = @keywords ? "?#{URI.encode_www_form(keywords: @keywords)}" : ''
        @session.visit("#{@company.company_url}people/#{query}")
        return 0 unless try_until_true(3) { @session.has_selector?("#{PEOPLE_CARD_CSS} a[href*=\"/in/\"]", wait: 5) }

        parser = SearchPeople.new(@session, 'unused')
        seen = {}
        @session.all(PEOPLE_CARD_CSS, wait: 0).each do |card|
          link = card.first('a[href*="/in/"]', minimum: 0, wait: 0)
          url = link && parser.result_url(link[:href])
          next if url.nil? || seen[url]

          seen[url] = true
          yield url, parser.card_lines(card.text)
        end
        seen.size
      end
    end
  end
end
