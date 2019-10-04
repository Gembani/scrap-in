module LinkedInMethods
  def linkedin_scrap_lead(config)
    ScrapIn::LinkedIn::ScrapLead.new(config, @capybara)
  end

  def linkedin_invite(lead_url, *note)
    ScrapIn::LinkedIn::Invite.new(@capybara, lead_url)
  end

  def linkedin_scrap_sent_invites
    ScrapIn::LinkedIn::ScrapSentInvites.new(@capybara)
  end

  def linkedin_send_message(profile, message)
    ScrapIn::LinkedIn::SendMessage.new(@capybara, profile, message)
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
end
