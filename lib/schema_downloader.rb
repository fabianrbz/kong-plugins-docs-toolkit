require 'fileutils'
require_relative 'action'

class SchemaDownloader < Action
  def prerequisites
    FileUtils.mkdir_p("#{@options[:destination]}/#{@plugin}")
  end

  def make_request!
    @res = @client.download_plugin_schema(@plugin)
  end

  def process_response
    if success?
      write_schema_to_file(JSON.parse(@res.body))
    end
  end

  def log_result
    if @options[:verbose]
      puts '-' * 33
      puts "| Plugin: #{@plugin}"
      puts "| Destination: #{file_path}"
      puts "| Response Code: #{@res.code}"
      puts '-' * 33
    else
      puts "#{@plugin} #{success? ? '✅' : '❌'}"
    end
  end

  private

  def success?
    @res && @res.code == '200'
  end

  def write_schema_to_file(schema)
    File.write(file_path, JSON.dump(schema))
  end

  def file_path
    "#{@options[:destination]}/#{@plugin}/#{@options[:version]}.json"
  end
end
