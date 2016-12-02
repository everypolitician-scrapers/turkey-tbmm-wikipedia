module TermTable
  class ByAreaTwocol < Scraped::HTML
    decorator UnspanAllTables

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
        tds[1].css('a').first.text.tidy rescue 'Bağımsız'
      end

      private

      def tds
        noko.css('td')
      end
    end

    field :members do
      noko.xpath(".//table[.//th[2][contains(.,'Siyasi Parti')]]/tr[td]").map do |tr|
        Member.new(response: response, noko: tr).to_h
      end
    end
  end
end
