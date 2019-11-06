module SalesNavigatorMethods
  def sales_nav_scrap_lead(config)
    ScrapIn::SalesNavigator::ScrapLead.new(config, @capybara)
  end

  def sales_nav_invite(sales_nav_profile_link, content)
    ScrapIn::SalesNavigator::Invite.new(sales_nav_profile_link, @capybara, content)
  end

  def sales_nav_send_inmail(profile_url, subject, message)
    ScrapIn::SalesNavigator::SendInmail.new(@capybara, profile_url, subject, message)
  end

  def sales_nav_scrap_threads
    ScrapIn::SalesNavigator::ScrapThreads.new(@capybara)
  end

  def sales_nav_scrap_messages(thread_link)
    ScrapIn::SalesNavigator::ScrapMessages.new(@capybara, thread_link)
  end
  
  def sales_nav_send_message(thread, message)
    ScrapIn::SalesNavigator::SendMessage.new(@capybara, thread, message)
  end

  def sales_nav_scrap_search_list(saved_search_link)
    ScrapIn::SalesNavigator::ScrapSearchList.new(@capybara, saved_search_link)
  end
end
