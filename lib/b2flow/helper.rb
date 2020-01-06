require 'zip'
require 'terminal-table'

module B2flow
  module Helper
    def self.table(results, columns=nil)
      if columns.nil?
        columns = results.map {|row| row.keys }.flatten.uniq.sort
      end


      rows = results.map do |row|
        columns.map do |column|
          value = row[column]
          if value.is_a?(Array) || value.is_a?(Hash)
            value.to_json
          else
            value
          end
        end
      end

      Terminal::Table.new(rows: rows, headings: columns)
    end

    def self.zip(dir)
      file = Zip::OutputStream::write_buffer do |zos|
        Dir["#{dir}/**/**"].each do |file|
          path_for_file_in_zip = file.sub(/\A#{dir}\//, '')
          if !File.directory?(file)
            zip_entry = zos.put_next_entry(path_for_file_in_zip)
            zos << IO.read(file)
          end
        end
      end

      file.rewind
      file
    end
  end
end
