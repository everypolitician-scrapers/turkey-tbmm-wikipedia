require 'bundler/setup'
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

ScraperWiki.sqliteexecute('DELETE FROM data') rescue nil

26.downto(1) do |t|
  url = "https://tr.wikipedia.org/wiki/TBMM_#{t}._d%C3%B6nem_milletvekilleri_listesi"
  url = 'https://tr.wikipedia.org/w/index.php?title=TBMM_18._d%C3%B6nem_milletvekilleri_listesi&stable=0' if t == 18
  url = 'https://tr.wikipedia.org/w/index.php?title=TBMM_16._d%C3%B6nem_milletvekilleri_listesi&stable=0' if t == 16
  url = 'https://tr.wikipedia.org/w/index.php?title=TBMM_9._d%C3%B6nem_milletvekilleri_listesi&stable=0'  if t == 9
  response = Scraped::Request.new(url: url).response
  data = TermPage.new(response: response).members
  warn "#{t}: #{data.count}"
  ScraperWiki.save_sqlite([:id, :area, :term], data.map { |m| m.to_h.merge(term: t) })
end
