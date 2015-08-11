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

end

terms = {
  25 => [ 'https://tr.wikipedia.org/wiki/TBMM_25._d%C3%B6nem_milletvekilleri_listesi', 'scrape25' ],
}

terms.each do |t, i|
  data = Parser.new(url: i.first).send(i.last).map { |m| m.merge(term: t, source: i.first) }
  puts data
end
