# frozen_string_literal: true

require 'erb'

module YARD
  module Rails
    module Plugin
      # Handles Rails's route documentations
      class Routes
        def initialize
          puts '[rails-plugin] Analyzing Routes...'
          @routes = load_routes.collect do |route|
            next if route.path.spec.to_s =~ %r{/rails/*|^/assets|^/cable}

            reqs = route.requirements.dup

            next if reqs.blank?

            { name: route.name.to_s,
              verb: route.verb.to_s,
              path: route.path.spec.to_s,
              action: reqs[:action],
              controller: get_controller(reqs),
              rack_app: get_rack_app(route),
              constraints: get_constraints(reqs) }
          end
          @routes.compact!
        end

        def generate_routes_description_file(filename)
          template = %q(
          <html>
          <head></head>
          <body>
            <h1>Routes</h1>
            <table>
              <tr style='background: #EAF0FF; font-weight: bold; line-height: 28px; text-align: left'>
                <th>Rails Method</th>
                <th>Verb</th>
                <th>Endpoint</th>
                <th>Destination</th>
              </tr>
              <% @routes.each_with_index do |r, i|
                next if r == nil
              %>
              <tr class='<%=(i.even? ? 'even' : 'odd')%>'>
                <td><%= r[:name] %></td>
                <td><%= r[:verb] %></td>
                <td><%= r[:path].gsub(/(:|\*)\w+/) do |m|
                  "<span style='font-family: monospace; color: green'>#{m}</span>"
                end %></td>
                <td><%= r[:rack_app].present? ? "<pre>#{r[:rack_app].inspect} #{r[:constraints]}</pre>" :
                  "{#{r[:controller]} #{r[:controller]}}##{r[:action]}  #{r[:constraints]}" %></td>
              </tr>
              <% end %>
              </table>
            </body>
          </html>).gsub(/^\s+/, '')
          erb = ERB.new(template, trim_mode: '%<>')

          b = binding

          File.write(
            File.join(Dir.pwd, filename),
            erb.result(b)
          )
        end

        def enrich_controllers
          @routes.each do |r|
            next unless r[:controller]

            node = YARD::Registry.resolve(nil, r[:controller], true)
            next if node.nil?

            (node[:routes] ||= []) << r

            next unless r[:action]

            node = YARD::Registry.resolve(nil, "#{r[:controller]}##{r[:action]}", true)
            next if node.nil?

            (node[:routes] ||= []) << r
          end
        end

        private

        def load_routes
          ::Rails.application.reload_routes!
          ::Rails.application.routes.routes
        end

        def get_controller(reqs)
          return unless reqs[:controller]

          "#{reqs[:controller].camelize}Controller"
        end

        def get_constraints(reqs)
          return if reqs.except(:controller, :action).blank?

          reqs.except(:controller, :action).inspect
        end

        def get_rack_app(route)
          return unless route.app.is_a?(ActionDispatch::Routing)

          route.app.inspect
        end
      end
    end
  end
end
