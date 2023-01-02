# frozen_string_literal: true

if ENV["SIMPLECOV"]
  SimpleCov.start do
    # `ENGINE_ROOT` holds the name of the engine we're testing.
    # This brings us to the main folder if we want to test all of the modules at
    # once. By default, we report the coverage for every module separately.
    # root File.expand_path("..", ENV.fetch("ENGINE_ROOT", nil))

    # We make sure we track all Ruby files, to avoid skipping unrequired files.
    track_files "**/*.rb"

    # We ignore some of the files because they are never tested
    add_filter %r{/lib/decidim/([^/]+/)+version.rb}
    add_filter "/config/"
    add_filter "/db/"
    add_filter "/vendor/"
    add_filter "/spec/"
  end

  SimpleCov.merge_timeout 1800

  if ENV["CI"]
    require "simplecov-cobertura"
    SimpleCov.formatter = SimpleCov::Formatter::CoberturaFormatter
  end
end
