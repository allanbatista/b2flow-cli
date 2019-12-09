require "thor"
require "b2flow/cli/config"
require "b2flow/cli/team"
require "b2flow/cli/project"

module B2flow
  module Cli
    class B2flow < Thor
      desc "config", "configure a b2flow client"
      subcommand "config", Config

      desc "teams", "teams resource"
      subcommand "teams", Team

      desc "projects", "projects resource"
      subcommand "projects", Project
    end
  end
end
