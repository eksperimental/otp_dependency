defmodule OtpDependency.MixProject do
  use Mix.Project

  def project do
    [
      app: :otp_dependency,
      version: "0.1.0",
      elixir: "~> 1.12",
      otp: "~> 24.0",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end

  defp aliases do
    [
      compile: [&check_otp_version/1, "compile"]
    ]
  end

  defp check_otp_version(_) do
    config = Mix.Project.config()

    if req = config[:otp] do
      case Version.parse_requirement(req) do
        {:ok, req} ->
          otp_version = otp_version()

          unless Version.match?(otp_version, req) do
            raise Mix.OTPVersionError,
              target: config[:app] || Mix.Project.get(),
              expected: req,
              actual: otp_version
          end

        :error ->
          Mix.raise("Invalid Elixir version requirement #{req} in mix.exs file")
      end
    end
  end

  defp otp_version() do
    {:ok, otp_release} =
      File.read(
        Path.join([
          :code.root_dir(),
          "releases",
          :erlang.system_info(:otp_release),
          "OTP_VERSION"
        ])
      )

    otp_release_string_to_version(otp_release)
  end

  defp otp_release_string_to_version(string) when is_binary(string) do
    string = String.trim(string)

    result =
      case Integer.parse(string) do
        :error ->
          :error

        {_, ""} ->
          string <> ".0.0"

        _ ->
          case Float.parse(string) do
            :error -> :error
            {_, ""} -> string <> ".0"
            _ -> string
          end
      end

    Version.parse!(result)
  end
end

defmodule Mix.OTPVersionError do
  defexception [:target, :expected, :actual, :message, mix: true]

  @impl true
  def exception(opts) do
    target = opts[:target]
    actual = opts[:actual]
    expected = opts[:expected]

    message =
      "You're trying to run #{inspect(target)} on Erlang/OTP #{actual} but it " <>
        "has declared in its mix.exs file it supports only Erlang/OTP #{expected}"

    %Mix.OTPVersionError{target: target, expected: expected, actual: actual, message: message}
  end
end
