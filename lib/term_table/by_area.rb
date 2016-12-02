module TermTable
  class ByArea < Base
    class Member < Scraped::HTML
      field :name do
        tds[0].css('a').first.text.tidy
      end

      field :wikipedia__tr do
        tds[0].xpath('a[not(@class="new")]/@title').text.strip
      end

      field :area do
        noko.xpath('preceding::h2/span[@class="mw-headline"]').last.text
      end

      field :party do
        tds[2].xpath('.//text()').first.text.tidy
      end

      private

      def tds
        noko.css('td')
      end
    end

    expected_headers ["Milletvekili", "Siyasi Parti", "Siyasi Parti"]
  end
end
