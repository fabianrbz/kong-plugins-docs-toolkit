require 'json'

class ReferenceableFields
  def self.run!(plugins:, options:)
    new(plugins:, options:).run!
  end

  def initialize(plugins:, options:)
    @plugins = plugins
    @options = options
    @referenceable_fields = {}
  end

  def run!
    schemas.each_with_object([]) do |(plugin_name, schema), fields|
      next unless File.exist?(schema)

      json_schema = JSON.parse(File.read(schema))

      fields = find_referenceable_fields(
        json_schema['fields'].detect { |f| f.key?('config') }['config'],
        'config'
      )

      puts "Plugin `#{plugin_name}`: #{fields.size} referenceable fields found" if @options[:verbose]

      @referenceable_fields[plugin_name] = fields if fields.any?
    end

    if @options['verbose']
      puts "Referenceable fields"
      puts JSON.pretty_generate(@referenceable_fields)
    end

    dest = File.join(@options['destination'], 'referenceable_fields.json')
    File.write(dest, JSON.pretty_generate(@referenceable_fields))

    puts "Referenceable fields written to: #{dest}"
  end

  private

  def find_referenceable_fields(obj, field_name)
    return [] if obj.nil?

    result = []

    if obj['referenceable'] || obj.dig('elements', 'referenceable') || obj.dig('values', 'referenceable')
      result << field_name
    else
      if obj.key?('fields')
        obj['fields'].each do |field|
          result += find_referenceable_fields(
            field.values.first,
            "#{field_name}.#{field.keys.first}"
          )
        end
      end
      if obj.dig('elements', 'fields')
        obj.dig('elements', 'fields').each do |field|
          result += find_referenceable_fields(
            field.values.first,
            "#{field_name}.#{field.keys.first}"
          )
        end
      end
    end

    result
  end

  def schemas
    @schemas ||= @plugins.map do |plugin_name|
      [plugin_name, schema_path(plugin_name)]
    end
  end

  def schema_path(plugin)
    File.join(@options['source'], plugin, "#{@options['version']}.json")
  end
end
