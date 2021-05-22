defmodule OtpDependencyTest do
  use ExUnit.Case
  doctest OtpDependency

  test "greets the world" do
    assert OtpDependency.hello() == :world
  end
end
