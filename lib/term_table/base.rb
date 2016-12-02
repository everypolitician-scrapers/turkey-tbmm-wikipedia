module TermTable
  class Base < Scraped::HTML
    def self.expected_headers(expected = nil)
      @expected_headers ||= expected
    end

    field :members do
      rows.map { |row| self.class::Member.new(response: response, noko: row).to_h }
    end

    private

    def rows
      return [] unless headers == expected_headers
      noko.xpath('tr[td]')
    end

    def headers
      noko.xpath('tr[1]/th').map(&:text).map(&:tidy)
    end

    def expected_headers
      self.class.expected_headers.to_a
    end
  end
end
