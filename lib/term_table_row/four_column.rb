# frozen_string_literal: true

module TermTableRow
  class FourColumn < Base
    expected_headers ['Seçim Bölgesi', 'Milletvekili', 'Siyasi Parti', 'Siyasi Parti']

    field :wikipedia__tr do
      tds[1].xpath('a[not(@class="new")]/@title').text.strip
    end

    field :area do
      tds[0].text.tidy
    end

    private

    def name_cell
      tds[1]
    end

    def party_name
      tds[3] && tds[3].text.tidy
    end
  end
end
