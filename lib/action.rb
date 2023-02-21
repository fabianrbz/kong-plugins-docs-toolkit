require_relative 'api/client'

class Action
  def self.run!(plugin:, options:)
    new(plugin:, options:).run!
  end

  def initialize(plugin:, options:)
    @plugin  = plugin
    @options = options
    @client  = API::Client.new(host: @options[:host], port: @options[:port])
  end

  def run!
    begin
      prerequisites
      make_request!
      process_response

      log_result
    rescue Errno::ENOENT => e
      puts e.message
    end
  end
end
