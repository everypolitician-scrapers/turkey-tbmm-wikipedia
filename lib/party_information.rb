# frozen_string_literal: true

class PartyInformation
  MAPPING = {
    AKP:   ['Adalet ve Kalkınma Partisi'],
    ANAP:  ['Anavatan Partisi'],
    AP:    ['Adalet Partisi'],
    BBP:   ['Büyük Birlik Partisi'],
    BDP:   ['Barış ve Demokrasi Partisi'],
    CGP:   ['Cumhuriyetçi Güven Partisi', 'Güven Partisi'],
    CHP:   ['Cumhuriyet Halk Partisi'],
    CKMP:  ['Cumhuriyetçi Köylü Millet Partisi'],
    CMP:   ['Cumhuriyetçi Millet Partisi'],
    DBP:   ['Demokratik Bölgeler Partisi'],
    DP46:  ['Demokrat Parti'],
    DP70:  ['Demokratik Parti'],
    DSP:   ['Demokratik Sol Parti'],
    DTP:   ['Demokratik Türkiye Partisi'],
    DYP:   ['Doğru Yol Partisi'],
    FP:    ['Fazilet Partisi'],
    HDP:   ['Halkların Demokratik Partisi'],
    HP:    ['Halkçı Parti'],
    HP55:  ['Hürriyet Partisi'],
    KADEP: ['Katılımcı Demokrasi Partisi'],
    MDP:   ['Milliyetçi Demokrasi Partisi'],
    MHP:   ['Milliyetçi Hareket Partisi'],
    MÇP:   ['Milliyetçi Çalışma Partisi'],
    MP:    ['Millet Partisi'],
    MSP:   ['Millî Selamet Partisi', 'Milli Selamet Partisi'],
    RP:    ['Refah Partisi'],
    SHP:   ['Sosyaldemokrat Halkçı Parti', 'Sosyal Demokrat Halkçı Parti'],
    TBP:   ['Türkiye Birlik Partisi', 'Birlik Partisi'],
    TİP:   ['Türkiye İşçi Partisi'],
    YTP:   ['Yeni Türkiye Partisi'],
    ind:   ['Bağımsız'],
  }.freeze

  def initialize(party_name)
    @party_name = party_name.to_s
  end

  def id
    @id ||= match && match.first.to_s
  end

  def name
    @name ||= match && match.last.first
  end

  private

  attr_reader :party_name

  def match
    @match ||= MAPPING.find { |_id, ns| ns.include? party }
  end

  def party
    return party_name unless party_name.include? '→'
    party_name.split(/\s*→\s*/).first
  end
end
