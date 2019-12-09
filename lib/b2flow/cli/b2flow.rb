require "thor"
require "b2flow/cli/config"

module B2flow
  module Cli
    class B2flow < Thor
      # option :email
      # option :hostname
      #
      # def login
      #   puts options
      # end
      desc "config", "configure a b2flow client"
      subcommand "config", Config
    end
  end
end
