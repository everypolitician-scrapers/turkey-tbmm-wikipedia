class TermThreeColumnPage < Scraped::HTML
  field :members do
    area = party = ''
    noko.xpath(".//table[.//th[3][contains(.,'Siyasi parti')]][1]/tr[td]").map do |tr|
      tds = tr.css('td')
      if tds.count == 3
        area = tds[0].text
        namecol = 1
        party = tds[2].xpath('.//text()').first.text.tidy
      elsif tds.count == 2
        namecol = 0
        party = tds[1].xpath('.//text()').first.text.tidy
      end
      name  = ->(col) { tds[col].css('a').first.text.tidy }
      title = ->(col) { tds[col].xpath('a[not(@class="new")]/@title').text.strip }
      {
        name: name.(namecol),
        wikipedia__tr: title.(namecol),
        area: area,
        party: party,
      }
    end
  end
end
