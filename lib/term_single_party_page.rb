class TermSinglePartyPage < Scraped::HTML
  field :members do
    area = ''
    party = 'Cumhuriyet Halk Partisi'
    noko.xpath(".//table[.//th[1][contains(.,'Seçim Bölgesi')]][1]/tr[td]").map do |tr|
      tds = tr.css('td')
      if tds.count == 2
        area = tds[0].text
        namecol = 1
      else
        namecol = 0
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
