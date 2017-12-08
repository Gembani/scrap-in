module Salesnavot
class Invite
  attr_reader :error
  def initialize(sales_nav_url,session, content)
      @sales_nav_url = sales_nav_url
      @session = session
      @error = ""
      @content = content
  end
  def  is_friend
       '1st' ==  @session.find('.profile-info .degree-icon').text

  end
  def execute

    @session.visit @sales_nav_url
    sleep(5)

    if is_friend
      @error = "already friends"
      return false
    end

    if @session.all('.connect-button').count > 0
      @session.all('.connect-button').first.click
    else
      @session.find('.more-options').hover
      @session.click_on('Connect')

    end
    @session.fill_in('connect-message-content', with: @content)
    @session.click_button('Send Invitation')
    while (@session.all(".alert").count == 0)
      sleep(0.1)
    end
    if (@session.all(".alert.success").count == 1)
      return true
    else
      if (@session.all(".alert.error").count > 0)
        @error = @session.all(".alert.error").first.text
      end
      return false
    end
  end
end

end
