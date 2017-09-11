# frozen_string_literal: true

module TermTableRow
  class SingleParty < Base
    expected_headers ['Seçim Bölgesi', 'Mebus']

    field :area do
      tds[0].text.tidy
    end

    private

    def name_cell
      tds[1]
    end

    def party_name
      'Cumhuriyet Halk Partisi'
    end
  end
end
