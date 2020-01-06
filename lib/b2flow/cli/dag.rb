require "thor"
require 'json'
require 'safe_yaml'
require 'b2flow/api/connection'
require 'b2flow/helper'
require 'b2flow/cli/environment'
require 'base64'

module B2flow
  module Cli
    class Dag < Thor
      COLUMNS = ["name", "enable", "cron", "config"]

      desc "init NAME", "create a b2flow base"
      option :team, required: true
      option :project, required: true
      option :force, default: false, type: :boolean
      option :project, default: "."
      def init(name)
        filename = File.join(options[:project], "b2flow.yml")
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

      desc "show PATH", "show remote a dag. default=."
      option :project, type: :string, default: '.'
      def show
        filename = File.join(options[:project], "b2flow.yml")
        dag = YAML.load(File.read(filename), :safe => true)["dag"]

        response = ::B2flow::Api::Connection.instance.get("/teams/#{dag["team"]}/projects/#{dag["project"]}/dags/#{dag['name']}")

        puts JSON.pretty_generate(JSON.parse(response.body))

        if response.status == 200
          puts ::B2flow::Helper.table([JSON.parse(response.body)], COLUMNS)
        else
          puts response.status
          puts response.body
        end
      end

      desc "create PATH", "create a new dag. default=."
      option :enable, type: :boolean, default: false
      option :project, type: :string, default: '.'
      def create
        filename = File.join(options[:project], "b2flow.yml")
        dag = YAML.load(File.read(filename), :safe => true)["dag"]
        dag['source'] = Base64.encode64(::B2flow::Helper.zip(".").read)
        dag['enable'] = options[:enable] unless options[:enable].nil?

        response = ::B2flow::Api::Connection.instance.post("/teams/#{dag["team"]}/projects/#{dag["project"]}/dags", dag)

        if response.status == 201
          puts ::B2flow::Helper.table([JSON.parse(response.body)], COLUMNS)
        else
          puts response.status
          puts response.body
        end
      end

      desc "update PATH", "update a dag. default=."
      option :enable, type: :boolean
      option :project, type: :string, default: '.'
      def update
        filename = File.join(options[:project], "b2flow.yml")
        dag = YAML.load(File.read(filename), :safe => true)["dag"]
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

      desc "environment", "configure environment variables"
      subcommand "environment", B2flow::Cli::Environment
    end
  end
end
