# frozen_string_literal: true

module TermTableRow
  class ByAreaTwocol < Base
    expected_headers ['Milletvekili', /Siyasi Parti/]

    field :area do
      noko.xpath('preceding::h2/span[@class="mw-headline"]').last.text
    end

    private

    def name_cell
      tds[0]
    end

    def party_name
      tds[1].css('a').first.text.tidy rescue 'Bağımsız'
    end
  end
end
