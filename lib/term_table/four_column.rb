module TermTable
  class FourColumn < Scraped::HTML
    decorator RemoveUnwantedTable
    decorator UnspanAllTables

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
        tds[3] && tds[3].text.tidy
      end

      private

      def tds
        @tds ||= noko.css('td')
      end
    end

    field :members do
      noko.xpath(".//table[.//th[contains(.,'Siyasi')]][1]/tr[td]").map do |tr|
        Member.new(response: response, noko: tr).to_h
      end
    end
  end
end
