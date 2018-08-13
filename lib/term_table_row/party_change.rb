# frozen_string_literal: true

module TermTableRow
  class PartyChange < Base
    expected_headers ['Seçim Bölgesi', 'Siyasi Parti', 'Siyasi Parti', 'Milletvekili', 'Parti değişikliği']

    field :area do
      tds[0].text.tidy
    end

    private

    def name_cell
      tds[3]
    end

    def party_name
      tds[2]&.text&.tidy
    end
  end

  class PartyChangeDouble < PartyChange
    expected_headers ['Seçim Bölgesi', 'Siyasi Parti', 'Siyasi Parti', 'Milletvekili', /Değişikli/, /Değişikli/]
  end
end
