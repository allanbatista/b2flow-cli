
require "thor"
require 'json'
require 'b2flow/api/connection'
require 'b2flow/helper'

module B2flow
  module Cli
    class Team < Thor
      COLUMNS = ["name", "created_at", "updated_at"]

      desc "list", "list teams"
      def list
        response = ::B2flow::Api::Connection.instance.get("/teams")

        if response.status == 200
          puts ::B2flow::Helper.table(JSON.parse(response.body), COLUMNS)
        else
          puts response.body
        end
      end

      desc "create NAME", "create a new team"
      def create(name)
        response = ::B2flow::Api::Connection.instance.post("/teams", {name: name})

        if response.status == 201
          puts ::B2flow::Helper.table([JSON.parse(response.body)], COLUMNS)
        else
          puts response.body
        end
      end
    end
  end
end
