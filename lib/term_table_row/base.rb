module TermTableRow
  class Base < Scraped::HTML
    def self.expected_headers(expected = nil)
      @expected_headers ||= expected
    end
  end
end
