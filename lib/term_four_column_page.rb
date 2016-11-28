class TermFourColumnPage < Scraped::HTML
  field :members do
    area = party = ''
    noko.xpath(".//table[.//th[4][contains(.,'Değişim')]]").remove
    rows = noko.xpath(".//table[.//th[contains(.,'Siyasi')]][1]/tr[td]")
    raise "No rows" if rows.count.zero?
    rows.map do |tr|
      next if tr.text.to_s.empty?
      tds = tr.css('td')
      if tds.count == 4
        area = tds[0].text
        namecol = 1
        party = tds[3].text
      elsif tds.count == 3
        namecol = 0
        party = tds[2].text
      elsif tds.count == 2
        namecol = 0
      elsif tds.count == 1
        namecol = 0
      end
      name  = ->(col) { tds[col].css('a').first.text.tidy rescue binding.pry }
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
