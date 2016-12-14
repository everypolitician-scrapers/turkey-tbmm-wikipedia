require 'table_unspanner/scraped'

class TermPage < Scraped::HTML
  decorator TableUnspanner::Decorator

  field :tables do
    noko.xpath(".//table[.//th[contains(.,'Siyasi') or contains(.,'Seçim Bölgesi')]]").map do |table|
      TermTable.new(response: response, noko: table)
    end
  end

  field :members do
    tables.flat_map { |table| table.members }
  end
end
