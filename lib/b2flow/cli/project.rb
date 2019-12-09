

require "thor"
require 'json'
require 'b2flow/api/connection'
require 'b2flow/helper'

module B2flow
  module Cli
    class Project < Thor
      option :team, required: true

      COLUMNS = ["name", "created_at", "updated_at"]

      desc "list", "list teams"
      def list
        response = ::B2flow::Api::Connection.instance.get("/teams/#{options[:team]}/projects")

        if response.status == 200
          results = JSON.parse(response.body)

          if results.size > 0
            puts ::B2flow::Helper.table(results, COLUMNS)
          end
        else
          puts response.body
        end
      end

      desc "create NAME", "create a new team"
      option :team, required: true
      def create(name)
        response = ::B2flow::Api::Connection.instance.post("/teams/#{options[:team]}/projects", {name: name})

        if response.status == 201
          puts ::B2flow::Helper.table([JSON.parse(response.body)], COLUMNS)
        else
          puts response.body
        end
      end
    end
  end
end
