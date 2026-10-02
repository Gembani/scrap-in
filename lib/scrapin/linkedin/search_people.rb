module ScrapIn
  module LinkedIn
    # Ordinary LinkedIn people search (no Sales Navigator).
    # Yields each result's profile url and the visible lines of its card (name, headline, location...),
    # left as text for the caller to interpret.
    class SearchPeople
      include Tools
      include CssSelectors::LinkedIn::SearchPeople

      def initialize(session, keywords)
        raise ArgumentError, 'Keywords are required' if keywords.to_s.strip.empty?

        @session = session
        @keywords = keywords
      end

      def execute(pages = 1)
        seen = {}
        (1..pages).each do |page|
          @session.visit(search_url(@keywords, page))
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
        try_until_true(3) { @session.has_selector?(profile_link_css, wait: 5) }
      end

      # Several links point to the same profile in one card (photo, name), keep one result per profile
      def results
        container = check_and_find_first(@session, results_container_css)
        container.all(profile_link_css, wait: 0).each_with_object({}) do |link, found|
          url = profile_url(link[:href])
          next if url.nil? || found.key?(url)

          found[url] = card_lines(link)
        end
      end

      def profile_url(href)
        match = href.to_s.match(%r{(https://www\.linkedin\.com/in/[^/?#]+)})
        match && "#{match[1]}/"
      end

      def card_lines(link)
        card = link.ancestor(result_card_selector)
        card.text.split("\n").map(&:strip).reject(&:empty?).uniq
      rescue Capybara::ElementNotFound
        [link.text.strip]
      end
    end
  end
end
