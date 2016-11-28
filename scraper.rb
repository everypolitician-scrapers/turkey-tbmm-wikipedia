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

PARTY = {
  AKP: ['Adalet ve Kalkınma Partisi'],
  ANAP: ['Anavatan Partisi'],
  AP:  ['Adalet Partisi'],
  BBP: ['Büyük Birlik Partisi'],
  BDP: ['Barış ve Demokrasi Partisi'],
  CGP: ['Cumhuriyetçi Güven Partisi', 'Güven Partisi'],
  CHP: ['Cumhuriyet Halk Partisi'],
  CKMP: ['Cumhuriyetçi Köylü Millet Partisi'],
  CMP: ['Cumhuriyetçi Millet Partisi'],
  DBP: ['Demokratik Bölgeler Partisi'],
  DP46: ['Demokrat Parti'],
  DP70: ['Demokratik Parti'],
  DSP: ['Demokratik Sol Parti'],
  DTP: ['Demokratik Türkiye Partisi'],
  DYP: ['Doğru Yol Partisi'],
  FP:  ['Fazilet Partisi'],
  HDP: ['Halkların Demokratik Partisi'],
  HP:  ['Halkçı Parti'],
  HP55:  ['Hürriyet Partisi'],
  KADEP: ['Katılımcı Demokrasi Partisi'],
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

ScraperWiki.sqliteexecute('DELETE FROM data') rescue nil
terms.each do |klass, ts|
  ts.each do |t|
    url = "https://tr.wikipedia.org/wiki/TBMM_#{t}._d%C3%B6nem_milletvekilleri_listesi"
    response = Scraped::Request.new(url: url).response
    data = klass.new(response: response).members.map { |m| 
      binding.pry if m[:party].to_s.empty?
      m.merge(party_from(m[:party])).merge(term: t, source: url, id: id_for(m))
    }
    warn "#{t}: #{data.count}"
    data.find_all { |m| m[:party][/[0-9]/] }.each { |m| puts m.to_s.magenta }
    ScraperWiki.save_sqlite([:id, :area, :term], data)
  end
end
