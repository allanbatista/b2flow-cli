require "thor"
require 'json'
require 'b2flow/api/authentication'

module B2flow
  module Cli
    class Config < Thor
      desc "auth", "do authentication"
      option :hostname, required: true
      option :username, required: true
      option :password
      option :protocol, default: 'http'
      option :port, default: '80'
      def auth
        password = options[:password]

        if password.nil?
          puts "type password: "
          password = $stdin.gets
        end

        authentication = ::B2flow::Api::Authentication.new(
          options[:hostname],
          options[:username],
          password,
          options[:protocol],
          options[:port]
        )

        token = authentication.get_token

        unless token.nil?
          File.open("#{ENV['HOME']}/.b2flow.json", "w+") do |f|
            f.write(JSON.pretty_generate({
              "hostname": options[:hostname],
              "username": options[:username],
              "protocol": options[:protocol],
              "port": options[:port],
              "token": token
            }))
          end

          puts "successful authentication"
        end
      end
    end
  end
end
