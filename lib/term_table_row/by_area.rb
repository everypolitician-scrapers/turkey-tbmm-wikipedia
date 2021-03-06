# frozen_string_literal: true

module TermTableRow
  class ByArea < Base
    expected_headers ['Milletvekili', 'Siyasi Parti', 'Siyasi Parti']

    field :area do
      noko.xpath('preceding::h2/span[@class="mw-headline"]').last.text
    end

    private

    def name_cell
      tds[0]
    end

    def party_name
      tds[2].xpath('.//text()').first.text.tidy
    end
  end
end
