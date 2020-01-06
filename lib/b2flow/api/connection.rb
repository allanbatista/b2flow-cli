require 'json'
require 'faraday'
require 'singleton'
require "logger"

module B2flow
  module Api
    class Connection
      include Singleton

      attr_reader :config

      def initialize
        @config = JSON.parse(File.read("#{ENV['HOME']}/.b2flow.json"))
      end

      def connection
        @connection ||= Faraday.new(
          url: "#{config['protocol']}://#{config['hostname']}:#{config['port']}",
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'X-Auth-token': config['token']
          }
        )
      end

      def get(path, params={})
        connection.get(path) do |f|
          f.params = f.params.merge(params)
        end
      end

      def post(path, body={})
        connection.post(path) do |f|
          f.body = body.to_json
        end
      end

      def put(path, body={})
        connection.put(path) do |f|
          f.body = body.to_json
        end
      end

      def delete(path)
        connection.delete(path)
      end
    end
  end
end
