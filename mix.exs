defmodule Eventizer.MixProject do
  use Mix.Project

  def project do
    [
      app: :eventizer,
      version: "0.1.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {Eventizer.Application, []}
    ]
  end

  defp deps do
    [
      {:mox, "~> 0.3", only: :test}
    ]
  end
end
