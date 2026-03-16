defmodule UnicodeTransform.MixProject do
  use Mix.Project

  @version "1.0.0"

  def project do
    [
      app: :unicode_transform,
      version: @version,
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      build_embedded: Mix.env() == :prod,
      compilers: maybe_elixir_make() ++ Mix.compilers(),
      make_makefile: "c_src/Makefile",
      deps: deps(),
      docs: docs(),
      name: "Unicode Transform",
      source_url: "https://github.com/elixir-unicode/unicode_transform",
      description: description(),
      package: package(),
      elixirc_paths: elixirc_paths(Mix.env()),
      dialyzer: [
        plt_add_apps: ~w(mix sweet_xml unicode_set)a,
        ignore_warnings: ".dialyzer_ignore_warnings"
      ]
    ]
  end

  @doc false
  def nif_enabled? do
    String.downcase(System.get_env("CLDR_TRANSFORM_NIF", "false")) == "true" or
      Application.get_env(:ex_cldr_transform, :nif, false) == true
  end

  defp maybe_elixir_make do
    if nif_enabled?() do
      [:elixir_make]
    else
      []
    end
  end

  defp description do
    """
    Transliterates text between scripts, applies normalization and case
    mappings, and executes arbitrary CLDR transforms.
    """
  end

  defp package do
    [
      maintainers: ["Kip Cole"],
      licenses: ["Apache-2.0"],
      logo: "logo.png",
      links: links(),
      files: [
        "lib",
        "c_src",
        "priv/transforms",
        "logo.png",
        "mix.exs",
        "README*",
        "CHANGELOG*",
        "LICENSE*"
      ]
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {Unicode.Transform.Application, []}
    ]
  end

  defp deps do
    [
      {:unicode_set, "~> 1.6"},
      {:sweet_xml, "~> 0.7", runtime: false},
      {:ex_doc, "~> 0.24", only: [:dev, :release], runtime: false, optional: true},
      {:dialyxir, "~> 1.1", only: [:dev], runtime: false, optional: true},
      {:req, "~> 0.5", only: :dev, runtime: false},
      {:benchee, "~> 1.0", only: :dev, runtime: false},
      {:elixir_make, "~> 0.9", runtime: false, optional: true},
      {:stream_data, "~> 1.0", only: :test}
    ]
  end

  def links do
    %{
      "GitHub" => "https://github.com/elixir-unicode/unicode_transform",
      "Readme" =>
        "https://github.com/elixir-unicode/unicode_transform/blob/v#{@version}/README.md",
      "Changelog" =>
        "https://github.com/elixir-unicode/unicode_transform/blob/v#{@version}/CHANGELOG.md"
    }
  end

  def docs do
    [
      source_ref: "v#{@version}",
      main: "readme",
      logo: "logo.png",
      extras: [
        "README.md",
        "LICENSE.md",
        "CHANGELOG.md"
      ],
      skip_undefined_reference_warnings_on: ["changelog", "CHANGELOG.md"]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test"]
  defp elixirc_paths(:dev), do: ["lib", "bench"]
  defp elixirc_paths(_), do: ["lib"]
end
