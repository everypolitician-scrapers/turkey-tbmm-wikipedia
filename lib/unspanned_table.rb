require 'nokogiri'
require 'scraped'

class UnspannedTable
  def initialize(noko_table)
    @original = noko_table
  end

  def transformed
    original.children = reparsed.map { |c| '<tr>' + c.map(&:to_html).join + '</tr>' }.join
    original
  end

  private

  attr_reader :original

  def reparsed
    grid = []

    original.css('tr').each_with_index do |row, curr_x|
      row.css('td, th').each_with_index do |cell, curr_y|
        rowspan = cell.remove_attribute('rowspan').value.to_i rescue 1
        colspan = cell.remove_attribute('colspan').value.to_i rescue 1

        0.upto(rowspan - 1).each do |x|
          0.upto(colspan - 1).each do |y|
            curr_y += 1 while (grid[curr_x + x] ||= [])[curr_y + y]
            grid[curr_x + x][curr_y + y] = cell
          end
        end
      end
    end

    grid
  end
end

class UnspanAllTables < Scraped::Response::Decorator
  def body
    Nokogiri::HTML(super).tap do |doc|
      doc.css('table').each do |table|
        table.children = UnspannedTable.new(table).transformed.children
      end
    end.to_s
  end
end
