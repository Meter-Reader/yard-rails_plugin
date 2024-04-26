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
            next if route[:path] =~ '/rails/info/properties|^/assets'

            reqs = route.requirements.dup
            { name: route.name.to_s,
              verb: route.verb.to_s,
              path: route.path.spec.to_s,
              action: reqs[:action],
              controller: get_controller(reqs),
              rack_app: get_rack_app(route),
              constraints: get_constraints(reqs) }
          end
        end

        def generate_routes_description_file(filename)
          template = %q(
          <h1>Routes</h1>
          <table>
            <tr style='background: #EAF0FF; font-weight: bold; line-height: 28px; text-align: left'>
              <th>Rails Method</th>
              <th>Verb</th>
              <th>Endpoint</th>
              <th>Destination</th>
            </tr>
            <% i = 0;
             @routes.each do |r|
              odd_or_even = (i.even? ? 'even' : 'odd')
              destination = if r[:rack_app]
                "<pre>#{r[:rack_app].inspect} #{r[:constraints]}</pre>"
              else
                "{#{r[:controller]} #{r[:controller]}}##{r[:action]}  #{r[:constraints]}"
              end
              endpoint = r[:path].gsub(/(:|\*)\w+/) do |m|
                "<span style='font-family: monospace; color: green'>#{m}</span>"
              end
              i += 1
            %>
            <tr class='#{odd_or_even}'>
              <td><%= r[:name]%></td>
              <td><%= r[:verb]%></td>
              <td><%= endpoint%></td>
              <td><%= destination%></td>
            </tr>"
            <% end %>
            </table>
          ').gsub(/^  /, '')
          erb = ERB.new(template, trim_mode: '%<>')

          File.open(File.join(Dir.pwd, filename), 'w') do |f|
            f.write erb.result
          end
        end

        def enrich_controllers
          @routes.each do |r|
            next unless r[:controller]

            node = YARD::Registry.resolve(nil, r[:controller], true)
            (node[:routes] ||= []) << r

            next unless r[:action]

            node = YARD::Registry.resolve(nil, "#{r[:controller]}##{r[:action]}", true)
            (node[:routes] ||= []) << r
          end
        end
      end

      private

      def load_routes
        ::Rails.application.reload_routes!
        ::Rails.application.routes.routes
      end

      def get_controller(reqs)
        return unless reqs[:controller]

        "#{reqs[:controller].upcase.gsub('_', '').gsub('/', '::')}_Controller"
      end

      def get_constraints(reqs)
        return unless reqs.except(:controller, :action).present?

        reqs.except(:controller, :action).inspect
      end

      def get_rack_app(route)
        return unless route.app.is_a?('ActionDispatch::Routing')

        route.app.inspect
      end
    end
  end
end
