# frozen_string_literal: true
module TermTableRow
  class ByAreaTwocol < Base
    expected_headers ['Milletvekili', /Siyasi Parti/]

    field :name do
      tds[0].css('a').first.text.tidy
    end

    field :wikipedia__tr do
      tds[0].xpath('a[not(@class="new")]/@title').text.strip
    end

    field :area do
      noko.xpath('preceding::h2/span[@class="mw-headline"]').last.text
    end

    private

    def party_name
      tds[1].css('a').first.text.tidy rescue 'Bağımsız'
    end

    def tds
      noko.css('td')
    end
  end
end
