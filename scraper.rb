#!/bin/env ruby
# encoding: utf-8

require 'colorize'
require 'mediawiki_api'
require 'nokogiri'
require 'open-uri'
require 'scraperwiki'
require 'require_all'

require 'pry'
require 'open-uri/cached'
OpenURI::Cache.cache_path = '.cache'

require_rel 'lib'

class String
  def tidy
    self.gsub(/[[:space:]]+/, ' ').strip
  end
end

def id_for(m)
  [m[:wikipedia__tr], m[:name]].find { |n| !n.to_s.empty? }.downcase.gsub(/[[:space:]]/,'_')
end

terms = {
  TermByAreaPage => [ 25 ],
  TermByAreaTwocolPage => [ 24 ],
  TermFourColumnPage => [ 26, 23, 22, 21, 20, 19, 17, 16, 15, 14, 13, 12, 11, 10, 9, 8 ],
  TermThreeColumnPage => [ 18 ],
  TermSinglePartyPage => [ 7, 6, 5, 4, 3, 2, 1 ],
}

ScraperWiki.sqliteexecute('DELETE FROM data') rescue nil
terms.each do |klass, ts|
  ts.each do |t|
    url = "https://tr.wikipedia.org/wiki/TBMM_#{t}._d%C3%B6nem_milletvekilleri_listesi"
    response = Scraped::Request.new(url: url).response
    data = klass.new(response: response).members.map { |m| 
      party_info = PartyInformation.new(m[:party])
      m.merge(party: party_info.name, party_id: party_info.id, term: t, source: url, id: id_for(m))
    }
    warn "#{t}: #{data.count}"
    ScraperWiki.save_sqlite([:id, :area, :term], data)
  end
end
