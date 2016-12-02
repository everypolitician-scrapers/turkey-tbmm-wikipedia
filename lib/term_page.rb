class TermPage < Scraped::HTML
  decorator UnspanAllTables

  field :tables do
    noko.xpath(".//table[.//th[contains(.,'Siyasi') or contains(.,'Seçim Bölgesi')]]").map do |table|
      TermTable.new(response: response, noko: table)
    end
  end

  field :members do
    tables.flat_map do |table|
      table.members
    end
  end
end
