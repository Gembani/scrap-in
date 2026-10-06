module LinkedInMethods
  def linkedin_scrap_lead(config)
    ScrapIn::LinkedIn::ScrapLead.new(config, @capybara)
  end

  def linkedin_invite
    ScrapIn::LinkedIn::Invite.new(@capybara)
  end

  def linkedin_scrap_sent_invites
    ScrapIn::LinkedIn::ScrapSentInvites.new(@capybara)
  end

  def linkedin_send_message(profile, message, **options)
    ScrapIn::LinkedIn::SendMessage.new(@capybara, profile, message, **options)
  end

  def linkedin_scrap_threads
    ScrapIn::LinkedIn::ScrapThreads.new(@capybara)
  end

  def linkedin_scrap_messages(thread_link)
    ScrapIn::LinkedIn::ScrapMessages.new(@capybara, thread_link)
  end

  def linkedin_profile_views
    ScrapIn::LinkedIn::ProfileViews.new(@capybara)
  end

  def linkedin_scrap_friends
    ScrapIn::LinkedIn::ScrapFriends.new(@capybara)
  end

  def linkedin_search_people(keywords, filters: {})
    ScrapIn::LinkedIn::SearchPeople.new(@capybara, keywords, filters: filters)
  end

  def linkedin_geo_lookup(query)
    ScrapIn::LinkedIn::GeoLookup.new(@capybara, query)
  end

  def linkedin_scrap_company(company_url)
    ScrapIn::LinkedIn::ScrapCompany.new(@capybara, company_url)
  end

  def linkedin_search_companies(keywords)
    ScrapIn::LinkedIn::SearchCompanies.new(@capybara, keywords)
  end

  def linkedin_company_people(company_url, keywords: nil)
    ScrapIn::LinkedIn::CompanyPeople.new(@capybara, company_url, keywords: keywords)
  end
end
