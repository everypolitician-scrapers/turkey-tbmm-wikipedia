class TermFourColumnPage < Scraped::HTML
  class Member < Scraped::HTML
    field :name do
      tds[namecol].css('a').first.text.tidy
    end

    field :wikipedia__tr do
      tds[namecol].xpath('a[not(@class="new")]/@title').text.strip
    end

    field :area do
      if tds.count == 4
        tds[0].text.tidy
      else
        ''
      end
    end

    field :party do
      if tds.count == 4
        tds[3].text
      elsif tds.count == 3
        tds[2].text
      else
        ''
      end
    end

    private

    def tds
      @tds ||= noko.css('td')
    end

    def namecol
      if tds.count == 4
        1
      elsif tds.count == 3
        0
      elsif tds.count == 2
        0
      elsif tds.count == 1
        0
      end
    end
  end

  field :members do
    noko.xpath(".//table[.//th[contains(.,'Siyasi')]][1]/tr[td]").map do |tr|
      Member.new(response: response, noko: tr).to_h
    end
  end
end
