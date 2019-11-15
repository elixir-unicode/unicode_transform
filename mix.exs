defmodule UnicodeTransform.MixProject do
  use Mix.Project

  def project do
    [
      app: :unicode_transform,
      version: "0.1.0",
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_unicode, "~> 1.0"},
      {:sweet_xml, "~> 0.6", only: [:dev, :test]},
      {:nimble_parsec, "~> 0.5", only: [:dev, :test]}
    ]
  end
end
