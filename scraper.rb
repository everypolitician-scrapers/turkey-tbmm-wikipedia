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
      data = {
        name: tds[0].css('a').first.text.tidy,
        wikipedia__tk: tds[0].xpath('a[not(@class="new")]/@title').text.strip,
        area: tr.xpath('preceding::h2/span[@class="mw-headline"]').last.text,
        party: tds[2].xpath('.//text()').first.text.tidy,
      }
    end
  end

  # Four column: Area (spanned), Name, Colour (spanned), Party (spanned)
  def four_column
    area = party = ''
    rows = noko.xpath(".//table[.//th[contains(.,'Siyasi')]]/tr[td]")
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
        wikipedia__tk: title.(namecol),
        area: area,
        party: party,
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
        party = tds[2].xpath('.//text()').first.text.tidy
      elsif tds.count == 2
        namecol = 0
        party = tds[1].xpath('.//text()').first.text.tidy
      end
      name  = ->(col) { tds[col].css('a').first.text.tidy }
      title = ->(col) { tds[col].xpath('a[not(@class="new")]/@title').text.strip }
      {
        name: name.(namecol),
        wikipedia__tk: title.(namecol),
        area: area,
        party: party,
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
        area: area,
        party: party,
      }
    end
  end

end

def id_for(m)
  [m[:wikipedia__tk], m[:name]].find { |n| !n.to_s.empty? }.downcase.gsub(/[[:space:]]/,'_')
end

terms = {
  by_area: [ 25 ],
  four_column: [ 24, 17 ],
  three_column: [ 23, 22, 21, 20, 19, 18, 16, 15, 14, 13, 12, 11, 10, 9, 8 ],
  single_party: [ 7, 6, 5, 4, 3, 2, 1 ],
}

PARTY = { 
  AKP: ['Adalet ve Kalkınma Partisi'],
  ANAP: ['Anavatan Partisi'],
  AP:  ['Adalet Partisi'],
  BBP: ['Büyük Birlik Partisi'],
  CGP: ['Cumhuriyetçi Güven Partisi', 'Güven Partisi'],
  CHP: ['Cumhuriyet Halk Partisi'],
  CKMP: ['Cumhuriyetçi Köylü Millet Partisi'],
  CMP: ['Cumhuriyetçi Millet Partisi'],
  DP46: ['Demokrat Parti'],
  DP70: ['Demokratik Parti'],
  DSP: ['Demokratik Sol Parti'],
  DTP: ['Demokratik Türkiye Partisi'], 
  DYP: ['Doğru Yol Partisi'],
  FP:  ['Fazilet Partisi'],
  HDP: ['Halkların Demokratik Partisi'],
  HP:  ['Halkçı Parti'],
  HP55:  ['Hürriyet Partisi'],
  MDP: ['Milliyetçi Demokrasi Partisi'],
  MHP: ['Milliyetçi Hareket Partisi'],
  MÇP: ['Milliyetçi Çalışma Partisi'],
  MP:  ['Millet Partisi'],
  MSP: ['Millî Selamet Partisi', 'Milli Selamet Partisi'],
  RP:  ['Refah Partisi'],
  SHP: ['Sosyaldemokrat Halkçı Parti', 'Sosyal Demokrat Halkçı Parti'],
  TBP: ['Türkiye Birlik Partisi', 'Birlik Partisi'],
  TİP: ['Türkiye İşçi Partisi'],
  YTP: ['Yeni Türkiye Partisi'],
  ind: ['Bağımsız'],
}

WARNED = Set.new
def party_from(party)
  party = party.split(/\s*→\s*/).first if party.include? '→'
  found = PARTY.find { |id, ns| ns.include? party } or binding.pry
  { 
    party_id: found.first.to_s,
    party: found.last.first,
  }
end

terms.each do |meth, ts|
  ts.each do |t|
    url = "https://tr.wikipedia.org/wiki/TBMM_#{t}._d%C3%B6nem_milletvekilleri_listesi"
    # url = 'https://tr.wikipedia.org/w/index.php?title=TBMM_1._d%C3%B6nem_milletvekilleri_listesi&stable=0' if t == 1
    data = Parser.new(url: url).send(meth).map { |m| 
      m.merge(party_from(m[:party])).merge(term: t, source: url, id: id_for(m)) 
    }
    warn "#{t}: #{data.count}"
    data.find_all { |m| m[:party][/[0-9]/] }.each { |m| puts m.to_s.magenta }
    ScraperWiki.save_sqlite([:id, :area, :term], data)
  end
end
