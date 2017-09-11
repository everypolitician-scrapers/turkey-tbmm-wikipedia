# frozen_string_literal: true

class TermTable < Scraped::HTML
  def self.row_classes
    @row_classes ||= [
      TermTableRow::SingleParty,
      TermTableRow::ByArea,
      TermTableRow::ByAreaTwocol,
      TermTableRow::ThreeColumn,
      TermTableRow::FourColumn,
    ]
  end

  field :members do
    return [] unless row_class
    rows.map { |row| row_class.new(response: response, noko: row) }
  end

  private

  def rows
    noko.xpath('tr[td]')
  end

  def row_class
    @row_class ||= self.class.row_classes.find do |klass|
      klass.can_handle?(headers)
    end
  end

  def headers
    noko.xpath('tr[1]/th').map(&:text).map(&:tidy)
  end
end
