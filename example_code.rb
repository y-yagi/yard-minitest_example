class A
  def output
    puts "b"
  end

  def multiple_output
    puts "a"
    puts "b"
  end
end

class ATest < Minitest::Example
  def example_output
    puts "Hello"

    # Output:
    # Hello
  end

  def example_multiple_output
    puts "a"
    puts "b"

    # Output:
    # a
    # b
  end
end
