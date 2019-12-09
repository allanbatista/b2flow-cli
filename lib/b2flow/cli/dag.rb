require "thor"
require 'json'
require 'safe_yaml'
require 'b2flow/api/connection'
require 'b2flow/helper'
require 'base64'

module B2flow
  module Cli
    class Dag < Thor
      COLUMNS = ["name", "enable", "cron", "config"]

      desc "init NAME", "create a b2flow base"
      option :team, required: true
      option :project, required: true
      option :force, default: false, type: :boolean
      option :filename, default: 'b2flow.yml'
      def init(name)
        if !File.exist?(options[:filename]) || options[:force]
          File.open(options[:filename], "w+") do |f|
            f.write(YAML.dump({
                "name" => name,
                "team" => options[:team],
                "project" => options[:project],
                "config" => {
                    "jobs" => {
                        "example" => {
                            "engine" => "docker"
                        }
                    }
                }
            }))
          end

          puts File.read(options[:filename])
        else
          puts "config already exists"
        end
      end

      desc "create FILENAME", "create a new dag. default=b2flow.yml"
      option :enable, type: :boolean, default: false
      def create(filename="b2flow.yml")
        dag = YAML.load(File.read(filename), :safe => true)
        dag['source'] = Base64.encode64(::B2flow::Helper.zip(".").read)
        dag['enable'] = options[:enable] unless options[:enable].nil?

        response = ::B2flow::Api::Connection.instance.post("/teams/#{dag["team"]}/projects/#{dag["project"]}/dags", dag)

        if response.status == 200
          puts ::B2flow::Helper.table([JSON.parse(response.body)], COLUMNS)
        else
          puts response.status
          puts response.body
        end
      end

      desc "update FILENAME", "update a dag. default=b2flow.yml"
      option :enable, type: :boolean
      def update(filename="b2flow.yml")
        dag = YAML.load(File.read(filename), :safe => true)
        dag['source'] = Base64.encode64(::B2flow::Helper.zip(".").read)
        dag['enable'] = options[:enable] unless options[:enable].nil?

        response = ::B2flow::Api::Connection.instance.put("/teams/#{dag["team"]}/projects/#{dag["project"]}/dags/#{dag['name']}", dag)

        if response.status == 200
          puts ::B2flow::Helper.table([JSON.parse(response.body)], COLUMNS)
        else
          puts response.status
          puts response.body
        end
      end
    end
  end
end
