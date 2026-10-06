module ScrapIn
  module LinkedIn
    # The LinkedIn ids of a place ("Paris" => [{ id: '106383538', name: 'Paris, Île-de-France, France' }, ...]), for
    # SearchPeople's geo filter. Read in the browser from LinkedIn's own place autocomplete.
    class GeoLookup
      include Tools
      include CssSelectors::LinkedIn::SearchPeople

      def initialize(session, query)
        raise ArgumentError, 'A place is required' if query.to_s.strip.empty?

        @session = session
        @query = query.to_s.strip
      end

      def execute
        @session.visit(geo_typeahead_url(@query))
        hits = JSON.parse(@session.find('body').text)
        Array(hits).filter_map do |hit|
          next unless hit.is_a?(Hash) && hit['id'].to_s.match?(/\A\d+\z/)

          { id: hit['id'].to_s, name: hit['displayName'].to_s }
        end
      rescue JSON::ParserError
        []
      end
    end
  end
end
