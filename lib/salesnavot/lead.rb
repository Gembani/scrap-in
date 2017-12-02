module Salesnavot
  class Lead
    attr_reader :name, :emails,
      :phone_number, :url, :linkedin_url,
      :sales_nav_url, :links, :phones
    def initialize(config, session)
      @sales_nav_url = config[:sales_nav_url] || ""
      @emails = config[:emails] || []
      @phones = config[:phones] || []
      @first_degree = config[:first_degree] || false
      @links = config[:links] || []
      @linkedin_url = config[:linkedin_url] || ""
      @name = config[:name] || ""
      @session = session
    end

    def to_hash
      {name: @name, linkedin_url: @linkedin_url, phones: @phones, first_degree: @first_degree, emails: @emails, links: @links, sales_nav_url: @sales_nav_url}
    end

    def to_json
      to_hash.to_json
    end

    def scrap
      @session.visit @sales_nav_url
      sleep(4)
      @name = @session.find(".member-name").text
      @first_degree = ('1st' ==  @session.find('.profile-info .degree-icon').text)
      if @session.all(".contact-info-button").count == 0
        puts "No contact info button"
        return
      end
      @session.all(".contact-info-button").first.click
      sleep(1)

      @session.all("div.more-info-tray table").each do |table|
        if (table.all("th").count == 1 && table.find("th").text == "Phone")
            table.all("td ul li").each do |item|
              @phones << item.text
            end
        else
          table.all("a").each do |link|
            if link.native.attribute(:href).include?("mailto:")
              @emails << link.native.attribute(:href).gsub("mailto:", "")
            elsif link.native.attribute(:href) == link.native.text
              @linkedin_url = link.native.text
            else
              @links << {name: link.native.text, url: link.native.attribute(:href)}
            end
          end
        end # if (table.find("th").text == "Phone")
      end
    end
  end
end
