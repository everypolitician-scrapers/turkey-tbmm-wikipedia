class TermByAreaTwocolPage < Scraped::HTML
  field :members do
    noko.xpath(".//table[.//th[2][contains(.,'Siyasi Parti')]]/tr[td]").map do |tr|
      tds = tr.css('td')
      party = tds[1].css('a').first.text.tidy rescue 'Bağımsız'
      data = {
        name: tds[0].css('a').first.text.tidy,
        wikipedia__tr: tds[0].xpath('a[not(@class="new")]/@title').text.strip,
        area: tr.xpath('preceding::h2/span[@class="mw-headline"]').last.text,
        party: party,
      }
    end
  end
end
