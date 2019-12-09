require 'terminal-table'

module B2flow
  module Helper
    def self.table(results, columns=nil)
      if columns.nil?
        columns = results.map {|row| row.keys }.flatten.uniq.sort
      end

      rows = results.map do |row|
        columns.map { |column| row[column] }
      end

      Terminal::Table.new(rows: rows, headings: columns)
    end
  end
end
