require 'json'
require 'faraday'

module B2flow
  module Api
    class Authentication
      attr_reader :hostname, :username, :password, :protocol, :port

      def initialize(hostname, username, password, protocol="http", port='80')
        @hostname = hostname
        @username = username
        @password = password
        @protocol = protocol
        @port = port
      end

      def get_token
        response = Faraday.post do |f|
          f.url "#{protocol}://#{hostname}:#{port}/authentications"
          f.headers['Content-Type'] = 'application/json'
          f.body = { email: username,  password: password }.to_json
        end

        if response.status == 201
          return JSON.parse(response.body)['token']
        elsif response.status == 401
          puts JSON.parse(response.body)['message']
          nil
        else
          raise StandardError.new("Authentication\nstatus: #{response.status}\n#{response.body}")
        end
      end
    end
  end
end