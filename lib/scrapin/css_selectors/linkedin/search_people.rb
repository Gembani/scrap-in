module CssSelectors
  module LinkedIn
    # Selectors of ScrapIn::LinkedIn::SearchPeople and SearchCompanies (checked on live LinkedIn, October 2026).
    # Each result's main link wraps its whole card (name, degree, headline, location), so results are read from
    # their links rather than from the hashed card classes.
    module SearchPeople
      # Free-text filters of ordinary LinkedIn's people search ("All filters"), by our name => LinkedIn's parameter
      TEXT_FILTERS = { title: :titleFreeText, first_name: :firstName, last_name: :lastName, company: :company,
                       school: :schoolFreetext }.freeze
      # Filters that take LinkedIn ids (geo urns, industry codes, company ids, language codes, F/S/O for 1st/2nd/3rd+)
      LIST_FILTERS = { geo: :geoUrn, industry: :industry, network: :network, current_company: :currentCompany,
                       past_company: :pastCompany, profile_language: :profileLanguage, school_ids: :schoolFilter }.freeze

      def search_url(keywords, page, current_company: nil, filters: {})
        params = { keywords: keywords, page: page }
        params[:currentCompany] = "[\"#{current_company}\"]" if current_company
        filters.each do |name, value|
          if TEXT_FILTERS.key?(name.to_sym)
            params[TEXT_FILTERS[name.to_sym]] = value.to_s.strip unless value.to_s.strip.empty?
          elsif LIST_FILTERS.key?(name.to_sym)
            ids = Array(value).map(&:to_s).reject(&:empty?)
            params[LIST_FILTERS[name.to_sym]] = "[#{ids.map { |id| "\"#{id}\"" }.join(',')}]" unless ids.empty?
          else
            raise ArgumentError, "Unknown people search filter #{name}"
          end
        end
        params[:origin] = 'FACETED_SEARCH' unless filters.empty?
        "https://www.linkedin.com/search/results/people/?#{URI.encode_www_form(params.compact)}"
      end

      # LinkedIn's place autocomplete (as on its public job search): JSON of { id, displayName } for a place name
      def geo_typeahead_url(query)
        params = { origin: 'jserp', typeaheadType: 'GEO', geoTypes: 'POPULATED_PLACE,ADMIN_DIVISION_2,MARKET_AREA,COUNTRY_REGION',
                   query: query }
        "https://www.linkedin.com/jobs-guest/api/typeaheadHits?#{URI.encode_www_form(params)}"
      end

      def results_container_css
        'main'
      end

      def profile_link_css
        'a[href*="/in/"]'
      end

      # Words of the card that are buttons, not information
      def card_noise
        %w[Follow Message Connect Following Pending]
      end
    end
  end
end
