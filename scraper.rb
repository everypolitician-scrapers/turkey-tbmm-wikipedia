# frozen_string_literal: true

require 'bundler/setup'
require 'scraperwiki'
require 'require_all'

require 'pry'
require 'open-uri/cached'
OpenURI::Cache.cache_path = '.cache'

require_rel 'lib'

class String
  def tidy
    gsub(/[[:space:]]+/, ' ').strip
  end
end

ScraperWiki.sqliteexecute('DROP TABLE data') rescue nil

26.downto(1) do |t|
  url = "https://tr.wikipedia.org/wiki/TBMM_#{t}._d%C3%B6nem_milletvekilleri_listesi"
  url = 'https://tr.wikipedia.org/w/index.php?title=TBMM_21._d%C3%B6nem_milletvekilleri_listesi&stable=0' if t == 21
  response = Scraped::Request.new(url: url).response
  data = TermPage.new(response: response).members.map { |m| m.to_h.merge(term: t) }
  data.each { |mem| puts mem.reject { |_, v| v.to_s.empty? }.sort_by { |k, _| k }.to_h } if ENV['MORPH_DEBUG']
  ScraperWiki.save_sqlite(%i[id area term], data)
end
