module Salesnavot
class Invite
  attr_reader :error
  def initialize(sales_nav_url,session, content)
      @sales_nav_url = sales_nav_url
      @session = session
      @error = ""
      @content = content
  end

  def go_to(link)
    @session.visit(link)
    return false unless @session.has_selector?('.profile-topcard')
    true
  end

  def is_friend?
    if '1st' ==  @session.find('.m-type--degree').text
      return true
    else
      @error = "Already friends"
      return false
    end
  end

  def find_and_click(css)
    unless @session.has_selector?(css)
      @error = "Cannot find action button for css = #{css}"
      return false
    end
    @session.find(css).click
    return true
  end

  def action_button_css
    '.profile-topcard-actions__overflow-toggle'
  end

  def connect_button_css
    '.connect'
  end

  def send_button_css
    '.button-primary-medium'
  end

  def click_and_connect
    return false unless find_and_click(action_button_css)
    return false unless find_and_click(connect_button_css)
    @session.fill_in 'connect-cta-form__invitation', with: @content
    return false unless find_and_click(send_button_css)
    find_and_click(connect_button_css)
  end

  def lead_invited?
    @session.find('.profile-topcard-actions__overflow-toggle').click
    @session.has_selector?('.pending-connection')
  end

  def execute
    return false unless go_to(@sales_nav_url)
    return false if is_friend?
    return false unless click_and_connect
    lead_invited?
  end
end

end
