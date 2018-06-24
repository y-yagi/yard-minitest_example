require "yard"
require "yard/handlers/ruby/base"
require "byebug"

YARD::Templates::Engine.register_template_path File.dirname(__FILE__) + '/../templates'

YARD::Parser::SourceParser.before_parse_file do |parser|
  if parser.file.end_with?("_test.rb") && !parser.file.end_with?("example_test.rb")
    false
  else
    true
  end
end

YARD::Parser::SourceParser.after_parse_list do |_files, _globals|
  YARD::Registry.all(:class).map do |o|
    o.visibility = :private if o.superclass.to_s == "Minitest::Example"
  end
end

module Yard
  module MinitestExample
    class ExampleWrapper < YARD::Handlers::Ruby::HandlesExtension
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
          ExampleWrapper.new("example_")
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

          class_name = self.namespace.to_s.sub("ExampleTest", "")
          m = statement.first[0].sub("example_", "")
          obj = YARD::Registry.resolve(P(class_name), "##{m}")
          return if obj.nil?

          code, output = statement.last.source.split("# Output:\n")

          (obj[:example] ||= []) << {
            code: code.chomp.gsub(/^\s+/, ""),
            output: output.chomp.gsub(/^\s+/, "").gsub("#", "# =>"),
          }
        end
      rescue YARD::Handlers::NamespaceMissingError
      end
    end
  end
end
