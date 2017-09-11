# frozen_string_literal: true

module TermTableRow
  class ThreeColumn < Base
    expected_headers ['Seçim Bölgesi', 'Milletvekili', 'Siyasi parti']

    field :area do
      tds[0].text.tidy
    end

    private

    def name_cell
      tds[1]
    end

    def party_name
      tds[2].xpath('.//text()').first.text.tidy rescue ''
    end
  end
end
