# frozen_string_literal: true

module TermTableRow
  class Base < Scraped::HTML
    def self.expected_headers(expected = nil)
      @expected_headers ||= expected
    end

    def self.can_handle?(headers)
      expected_headers.zip(headers).all? do |expected, actual|
        next unless actual
        expected.match(actual.to_s)
      end
    end

    field :id do
      [wikipedia__tr, name].find { |n| !n.to_s.empty? }.downcase.gsub(/[[:space:]]/, '_')
    end

    field :name do
      name_node.text.tidy
    end

    field :wikidata do
      name_node.attr('wikidata')
    end

    field :wikipedia__tr do
      name_cell.xpath('a[not(@class="new")]/@title').text.strip
    end

    field :source do
      url.to_s
    end

    field :party_id do
      party_info.id
    end

    field :party do
      party_info.name
    end

    private

    def tds
      noko.css('td')
    end

    def name_node
      name_cell.css('a').first
    end

    def party_info
      @party_info = PartyInformation.new(party_name)
    end
  end
end
