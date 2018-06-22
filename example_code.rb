class A
  def output
    puts "b"
  end
end

class ATest < Minitest::Example
  def example_output
    puts "Hello"

    # Output:
    # Hello
  end
end
