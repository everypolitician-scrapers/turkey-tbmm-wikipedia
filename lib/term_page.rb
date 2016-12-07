class TermPage < Scraped::HTML
  # See comment in term_18_temporary_fix.rb for more details.
  decorator Term18TemporaryFix
  decorator UnspanAllTables

  field :tables do
    noko.xpath(".//table[.//th[contains(.,'Siyasi') or contains(.,'Seçim Bölgesi')]]").map do |table|
      TermTable.new(response: response, noko: table)
    end
  end

  field :members do
    tables.flat_map { |table| table.members }
  end
end
