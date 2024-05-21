# frozen_string_literal: true

module YARD
  module Rails
    module Plugin
      # Handles Rails controller parameters
      class ControllerParamsHandler < YARD::Handlers::Ruby::Base
        handles(/params\[(:|')\w+'?\]/)
        def process
          return unless owner.is_a?(YARD::CodeObjects::MethodObject)

          op = owner.parent
          return unless op.is_a?(YARD::CodeObjects::ClassObject) || op.name.to_s[/Controller/]

          (owner[:params] ||= []) << statement.source.match(/params\[((:|')\w+'?)\]/)[1]
        end
      end
    end
  end
end
