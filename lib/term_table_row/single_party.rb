module TermTableRow
  class SingleParty < Base
    class Member < Scraped::HTML
      field :name do
        tds[1].css('a').first.text.tidy
      end

      field :wikipedia__tr do
        tds[1].xpath('a[not(@class="new")]/@title').text.strip
      end

      field :area do
        tds[0].text.tidy
      end

      field :party do
        'Cumhuriyet Halk Partisi'
      end

      def tds
        @tds ||= noko.css('td')
      end
    end

    expected_headers ['Seçim Bölgesi', 'Mebus']
  end
end
