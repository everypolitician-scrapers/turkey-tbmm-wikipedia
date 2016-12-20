module TermTableRow
  class ThreeColumn < Base
    expected_headers ["Seçim Bölgesi", "Milletvekili", "Siyasi parti"]

    field :name do
      tds[1].css('a').first.text.tidy
    end

    field :wikipedia__tr do
      tds[1].xpath('a[not(@class="new")]/@title').text.strip
    end

    field :area do
      tds[0].text.tidy
    end

    private

    def party_name
      tds[2].xpath('.//text()').first.text.tidy rescue ''
    end

    def tds
      @tds ||= noko.css('td')
    end
  end
end
