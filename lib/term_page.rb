# frozen_string_literal: true

require 'scraped'
require 'wikidata_ids_decorator'
require_relative 'unspan_all_tables'

class TermPage < Scraped::HTML
  decorator UnspanAllTables
  decorator WikidataIdsDecorator::Links

  field :tables do
    noko.xpath(".//table[.//th[contains(.,'Siyasi') or contains(.,'Seçim Bölgesi')]]").map do |table|
      TermTable.new(response: response, noko: table)
    end
  end

  field :members do
    tables.flat_map(&:members)
  end
end
