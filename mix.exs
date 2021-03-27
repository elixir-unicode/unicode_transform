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

  defp deps do
    [
      {:unicode_set, "~> 0.12", optional: true},
      {:sweet_xml, "~> 0.6", only: [:dev, :test], optional: true}
    ]
  end
end
