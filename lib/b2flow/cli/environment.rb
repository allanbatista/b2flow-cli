require "thor"
require 'json'
require 'safe_yaml'
require 'b2flow/api/connection'
require 'b2flow/helper'
require 'base64'

module B2flow
  module Cli
    class Environment < Thor

      desc "show", "use this to inspect env vars"
      option :project, type: :string, default: '.'
      option :complete, type: :boolean, default: false
      def show
        filename = File.join(options[:project], "b2flow.yml")
        dag = YAML.load(File.read(filename), :safe => true)["dag"]
        response = ::B2flow::Api::Connection.instance.get("/teams/#{dag["team"]}/projects/#{dag["project"]}/dags/#{dag['name']}/environments?complete=#{options[:complete]}")

        if response.status == 200
          rows = JSON.parse(response.body)
          puts ::B2flow::Helper.table(rows) if rows.any?
        else
          puts response.status
          puts response.body
        end
      end

      desc "set", "set KEY=VALUE K2=v2"
      option :project, type: :string, default: '.'
      option :secret, type: :boolean, default: false
      def set(*values)
        filename = File.join(options[:project], "b2flow.yml")
        dag = YAML.load(File.read(filename), :safe => true)["dag"]

        values.each do |keyvalue|
          key, value = keyvalue.strip.split("=")

          response = ::B2flow::Api::Connection.instance.put("/teams/#{dag["team"]}/projects/#{dag["project"]}/dags/#{dag['name']}/environments/#{key}", {
              value: value,
              secret: options[:secret]
          })

          if response.status < 300
            puts "#{key} created"
          else
            puts response.status
            puts response.body
          end
        end
      end

      desc "delete", "delete k1 k2 k3"
      option :project, type: :string, default: '.'
      def delete(*values)
        filename = File.join(options[:project], "b2flow.yml")
        dag = YAML.load(File.read(filename), :safe => true)["dag"]

        values.each do |key_raw|
          key = key_raw.strip

          response = ::B2flow::Api::Connection.instance.delete("/teams/#{dag["team"]}/projects/#{dag["project"]}/dags/#{dag['name']}/environments/#{key}")

          if response.status < 300
            puts "#{key} removed"
          else
            puts response.status
            puts response.body
          end
        end
      end
    end
  end
end