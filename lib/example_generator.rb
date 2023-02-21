require 'json'

class ExampleGenerator
  def self.run!(plugin:, options:)
    new(plugin:, options:).run!
  end

  def initialize(plugin:, options:)
    @plugin  = plugin
    @options = options
  end

  def run!
    # TODO:
    # generate json
    #   name: @plugin
    #   config: ...
    # write to yaml
    schema['fields'].each do |field|
      field.each do |name, schema|
        if schema['required'] && !schema['default']
          case schema['type']
          when 'record'
          when 'array'
          when 'boolean'
          when 'string'
          when 'number'
          end
          p "Name: #{name}"
          p "Schema: #{schema}"
        end
      end
    end
  end

  private

  def schema
    @schema ||= JSON.parse(File.read(file_path))
  end

  def file_path
    File.join(@options[:source], @plugin, "#{@options[:version]}.json")
  end
end
