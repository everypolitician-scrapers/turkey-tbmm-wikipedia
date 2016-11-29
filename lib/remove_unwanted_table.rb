class RemoveUnwantedTable < Scraped::Response::Decorator
  def body
    doc = Nokogiri::HTML(super)
    doc.xpath(".//table[.//th[4][contains(.,'Değişim')]]").remove
    doc.to_s
  end
end
