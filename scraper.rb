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

  def scrape25
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
  def scrape24
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
  def scrape23
    area = party = ''
    noko.xpath(".//table[.//th[3][contains(.,'Siyasi parti')]]/tr[td]").map do |tr|
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

end

terms = {
  25 => [ 'https://tr.wikipedia.org/wiki/TBMM_25._d%C3%B6nem_milletvekilleri_listesi', 'scrape25' ],
  24 => [ 'https://tr.wikipedia.org/wiki/TBMM_24._d%C3%B6nem_milletvekilleri_listesi', 'scrape24' ],
  23 => [ 'https://tr.wikipedia.org/wiki/TBMM_23._d%C3%B6nem_milletvekilleri_listesi', 'scrape23' ],
}

terms.each do |t, i|
  data = Parser.new(url: i.first).send(i.last).map { |m| m.merge(term: t, source: i.first) }
  puts data
end
