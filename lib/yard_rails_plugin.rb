# frozen_string_literal: true

require 'yard_rails_plugin/version'
require 'yard_rails_plugin/routes'

# Handlers
require 'yard_rails_plugin/controller_params_handler'

# Templates
YARD::Templates::Engine.register_template_path "#{File.dirname(__FILE__)}/../templates"

# After Source Parsing
def load_rails_environment(env)
  puts "[rails-plugin] Loading Rails environment (#{env})..."
  ENV['RAILS_ENV'] = env
  require File.join(Dir.pwd, 'config/environment')
end

YARD::Parser::SourceParser.after_parse_list do
  load_rails_environment 'development'
  routes = YARD::Rails::Plugin::Routes.new
  routes.generate_routes_description_file 'tmp/routes.html'
  routes.enrich_controllers
end
