# frozen_string_literal: true

require "rails"
require "decidim/core"

module Decidim
  module L10n
    # This is the engine that runs on the public interface of l10n.
    class Engine < ::Rails::Engine
      initializer "decidim_l10n.webpacker.assets_path" do
        Decidim.register_assets_path File.expand_path("app/packs", root)
      end

      initializer "decidim_l10n.setup" do
        l10n_backend = Decidim::L10n.i18n_backend
        l10n_backend.region = :US # Hard coded region for now
        I18n.backend = I18n::Backend::Chain.new(
          l10n_backend,
          I18n.backend
        )
      end

      config.after_initialize do
        # Hack to make our l10n overrides the first one of any Decidim module
        # but after the application's cell paths in order not to disable direct
        # overrides from the app.
        first_path = Cell::ViewModel.view_paths.shift
        Cell::ViewModel.view_paths.prepend File.expand_path("#{Decidim::L10n::Engine.root}/app/cells")
        Cell::ViewModel.view_paths.prepend File.expand_path("#{Decidim::L10n::Engine.root}/app/views") # for partials
        Cell::ViewModel.view_paths.prepend first_path

        # The same hack is needed for normal views so that the l10n overrides
        # get priority. Otherwise they might not be loaded properly in case some
        # other module is loaded before them.
        view_paths = ActionController::Base._view_paths
        first_path = view_paths.paths.shift
        module_path = "#{Decidim::L10n::Engine.root}/app/views"
        ActionController::Base._view_paths = ActionView::PathSet.new([first_path, module_path] + view_paths)
      end

      initializer "decidim_l10n.add_customizations", after: "decidim.action_controller" do
        config.to_prepare do
          # Cells extensions
          Decidim::Meetings::MeetingMCell.include(
            ::Decidim::L10n::MeetingMCellExtensions
          )

          Decidim::Debates::DebateMCell.include(
            ::Decidim::L10n::DebateMCellExtensions
          )
          # Form builders
          Decidim::FormBuilder.include(::Decidim::L10n::FormBuilderExtensions)

          # Helpers
          Decidim::ParticipatoryProcesses::ParticipatoryProcessHelper.include(
            Decidim::L10n::ParticipatoryProcessHelperExtensions
          )
        end
      end
    end
  end
end
