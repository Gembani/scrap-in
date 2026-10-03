module ScrapIn
  module LinkedIn
    # Ordinary LinkedIn people search (no Sales Navigator), optionally among a company's employees.
    # Yields each result's profile url and the visible lines of its card (name, degree, headline, location...),
    # left as text for the caller to interpret.
    class SearchPeople
      include Tools
      include CssSelectors::LinkedIn::SearchPeople

      def initialize(session, keywords, current_company: nil)
        raise ArgumentError, 'Keywords or a company are required' if keywords.to_s.strip.empty? && current_company.nil?

        @session = session
        @keywords = keywords.to_s.strip.empty? ? nil : keywords
        @current_company = current_company
      end

      def execute(pages = 1)
        seen = {}
        (1..pages).each do |page|
          @session.visit(search_url(@keywords, page, current_company: @current_company))
          break unless results_appear?

          new_results = 0
          results.each do |url, lines|
            next if seen[url]

            seen[url] = true
            new_results += 1
            yield url, lines
          end
          break if new_results.zero?
        end
        seen.size
      end

      def results_appear?
        try_until_true(3) { @session.has_selector?(link_css, wait: 5) }
      end

      # Several links point to one result (photo, name, card): a result's main link wraps its whole card.
      # Links holding a name alone are people mentioned in another card ("X and Y are mutual connections"), not results.
      def results
        container = check_and_find_first(@session, results_container_css)
        cards = container.all(link_css, wait: 0).each_with_object({}) do |link, found|
          url = result_url(link[:href])
          next if url.nil?

          lines = card_lines(link.text)
          found[url] = lines if lines.size > found.fetch(url, []).size
        end
        cards.select { |_url, lines| lines.size > 1 }
      end

      def link_css
        profile_link_css
      end

      def result_url(href)
        match = href.to_s.match(%r{(https?://(?:www\.)?linkedin\.com/in/[^/?#]+)})
        match && "#{match[1].sub(%r{\Ahttps?://(www\.)?}, 'https://www.')}/"
      end

      # "Jérémy Arriat • 2nd" -> "Jérémy Arriat", "2nd"
      def card_lines(text)
        text.to_s.split(/\n|\s•\s/).map { |line| line.strip.delete_prefix('•').strip }
            .reject { |line| line.empty? || card_noise.include?(line) }.uniq
      end
    end
  end
end
