require "yard"
require "yard/handlers/ruby/base"
require "byebug"

YARD::Templates::Engine.register_template_path File.dirname(__FILE__) + '/../templates'

module Yard
  module MinitestExample
    class ExampleDefWrapper < YARD::Handlers::Ruby::HandlesExtension
      def matches?(node)
        case node.type
        when :def
          return true if node[0][0].start_with?(name)
        when :class
          return false if node.superclass.nil?
          return node.superclass[0][0][0] == "Minitest" && node.superclass[1][0] == "Example"
        end

        false
      end
    end


    class Handler < YARD::Handlers::Ruby::Base
      class << self
        def example_call
          ExampleDefWrapper.new("example_")
        end
      end

      handles example_call

      def process
        if statement.type == :class
          class_name = statement.class_name.path[0].sub("Test", "")
          obj = { example: class_name }
          parse_block(statement.last.last, owner: obj)
        elsif statement.type == :def
          return if owner.nil?

          m = statement.first[0].sub("example_", "")
          obj = YARD::Registry.resolve(P(owner[:example]), "##{m}")
          return if obj.nil?

          (obj[:example] ||= []) << {
            source: statement.last.source.chomp.strip
          }
        end
      rescue YARD::Handlers::NamespaceMissingError
      end
    end
  end
end
