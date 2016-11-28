class TermByAreaPage < Scraped::HTML
  field :members do
    noko.xpath(".//table[.//th[2][contains(.,'Siyasi Parti')]]/tr[td]").map do |tr|
      tds = tr.css('td')
      data = {
        name: tds[0].css('a').first.text.tidy,
        wikipedia__tr: tds[0].xpath('a[not(@class="new")]/@title').text.strip,
        area: tr.xpath('preceding::h2/span[@class="mw-headline"]').last.text,
        party: tds[2].xpath('.//text()').first.text.tidy,
      }
    end
  end
end
