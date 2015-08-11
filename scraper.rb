#!/bin/env ruby
# encoding: utf-8

require 'colorize'
require 'mediawiki_api'
require 'nokogiri'
require 'open-uri'
require 'scraperwiki'

require 'pry'
require 'open-uri/cached'
OpenURI::Cache.cache_path = '.cache'

class String
  def tidy
    self.gsub(/[[:space:]]+/, ' ').strip
  end
end

class Parser

  def initialize(h)
    @url = h[:url]
  end

  def noko
    @noko ||= Nokogiri::HTML(open(@url).read)
  end

  def by_area
    noko.xpath(".//table[.//th[2][contains(.,'Siyasi Parti')]]/tr[td]").map do |tr|
      tds = tr.css('td')
      {
        name: tds[0].css('a').first.text.tidy,
        wikipedia__tk: tds[0].xpath('a[not(@class="new")]/@title').text.strip,
        party: tds[1].text.tidy,
        area: tr.xpath('preceding::h2/span[@class="mw-headline"]').last.text,
      }
    end
  end

  # Four column: Area (spanned), Name, Colour (spanned), Party (spanned)
  def four_column
    area = party = ''
    noko.xpath(".//table[.//th[3][contains(.,'Siyasi Parti')]]/tr[td]").map do |tr|
      tds = tr.css('td')
      if tds.count == 4
        area = tds[0].text 
        namecol = 1
        party = tds[3].text 
      elsif tds.count == 3
        namecol = 0
        party = tds[2].text
      elsif tds.count == 1
        namecol = 0
      end
      name  = ->(col) { tds[col].css('a').first.text.tidy }
      title = ->(col) { tds[col].xpath('a[not(@class="new")]/@title').text.strip }
      {
        name: name.(namecol),
        wikipedia__tk: title.(namecol),
        party: party,
        area: area,
      }
    end
  end

  # Three column: Area (spanned), Name, Party (unspanned)
  def three_column
    area = party = ''
    noko.xpath(".//table[.//th[3][contains(.,'Siyasi parti')]][1]/tr[td]").map do |tr|
      tds = tr.css('td')
      if tds.count == 3
        area = tds[0].text 
        namecol = 1
        party = tds[2].text 
      elsif tds.count == 2
        namecol = 0
        party = tds[1].text
      end
      name  = ->(col) { tds[col].css('a').first.text.tidy }
      title = ->(col) { tds[col].xpath('a[not(@class="new")]/@title').text.strip }
      {
        name: name.(namecol),
        wikipedia__tk: title.(namecol),
        party: party,
        area: area,
      }
    end
  end

  def single_party
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
        wikipedia__tk: title.(namecol),
        party: party,
        area: area,
      }
    end
  end

end

terms = {
  by_area: [ 25, 17 ],
  four_column: [ 24 ],
  three_column: [ 23, 22, 21, 20, 19, 18, 16, 15, 14, 13, 12, 11, 10, 9, 8 ],
  single_party: [ 7, 6, 5, 4, 3, 2, 1 ],
}

terms.each do |meth, ts|
  ts.each do |t|
    url = "https://tr.wikipedia.org/wiki/TBMM_#{t}._d%C3%B6nem_milletvekilleri_listesi"
    url = 'https://tr.wikipedia.org/w/index.php?title=TBMM_1._d%C3%B6nem_milletvekilleri_listesi&stable=0' if t == 1
    warn url
    data = Parser.new(url: url).send(meth).map { |m| m.merge(term: t, source: url) }
    # data.find_all { |m| m[:name][/[0-9]/] }.each { |m| puts m.to_s.magenta }
    ScraperWiki.save_sqlite([:name, :area, :term], data)
  end
end
