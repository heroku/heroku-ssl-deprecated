require "heroku/command"
require "ssl/heroku/run_with_status"

module Heroku::Command
  extend Heroku::RunWithStatus
end
