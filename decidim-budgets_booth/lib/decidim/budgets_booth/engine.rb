# frozen_string_literal: true

require "rails"
require "decidim/core"

module Decidim
  module BudgetsBooth
    # This is the engine that runs on the public interface of ptp-budgets.
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::BudgetsBooth

      initializer "decidim_budgets_booth.mount_routes", before: :add_routing_paths do
        # Mount the engine routes to Decidim::Core::Engine because otherwise
        # they would not get mounted properly. Note also that we need to prepend
        # the routes in order for them to override Decidim's own routes for the
        # "sms" authentication.
        Decidim::Budgets::Engine.routes.prepend do
          resources :budgets do
            resources :voting, only: [:index]

            namespace :voting do
              resources :projects, only: [:show]
            end
            collection do
              resources :zip_code, only: [:new, :create], controller: "user_data", path: "user/zip_code"
            end
          end
        end
      end

      initializer "decidim_budgets_booth.webpacker.assets_path" do
        Decidim.register_assets_path File.expand_path("app/packs", root)
      end

      initializer "decidim_budgets_booth.add_cells_view_paths", before: "decidim_budgets.add_cells_view_paths" do
        Cell::ViewModel.view_paths << File.expand_path("#{Decidim::BudgetsBooth::Engine.root}/app/cells")
        Cell::ViewModel.view_paths << File.expand_path("#{Decidim::BudgetsBooth::Engine.root}/app/views") # for partials
      end

      initializer "decidim_budgets_booth.add_customizations", after: "decidim.action_controller" do
        config.to_prepare do
          # Helper extensions
          Decidim::Budgets::ProjectsHelper.include(
            Decidim::BudgetsBooth::ProjectsHelperExtensions
          )

          # Cells extensions
          Decidim::Budgets::ProjectVotedHintCell.include(
            Decidim::BudgetsBooth::ProjectVotedHintCellExtensions
          )
          Decidim::Budgets::ProjectVoteButtonCell.include(
            Decidim::BudgetsBooth::ProjectVoteButtonCellExtensions
          )

          Decidim::Budgets::ProjectListItemCell.include(
            Decidim::BudgetsBooth::ProjectListItemExtensions
          )

          Decidim::Budgets::BudgetListItemCell.include(
            Decidim::BudgetsBooth::BudgetListItemCellExtensions
          )

          # We need to  change the budgets header only when zip-code is enabled.
          # for that we need to access #zip_code_workflow? inside BudgetsControllerHelper
          Decidim::Budgets::BudgetsHeaderCell.include(
            Decidim::BudgetsBooth::BudgetsControllerHelper
          )

          Decidim::Budgets::BudgetsHeaderCell.include(
            Decidim::BudgetsBooth::ScopeManager
          )

          # Controllers extensions
          Decidim::Budgets::LineItemsController.include(
            Decidim::BudgetsBooth::LineItemsControllerExtensions
          )

          Decidim::Budgets::OrdersController.include(
            Decidim::BudgetsBooth::OrdersControllerExtensions
          )

          Decidim::Budgets::BudgetsController.include(
            Decidim::BudgetsBooth::BudgetsControllerExtensions
          )

          Decidim::Budgets::OrdersController.include(
            Decidim::BudgetsBooth::OrderControllerExtensions
          )

          # Models extensions
          Decidim::Budgets::Budget.include(
            Decidim::BudgetsBooth::BudgetExtensions
          )

          Decidim::User.include(
            Decidim::BudgetsBooth::UserExtensions
          )

          Decidim::Component.include(
            Decidim::BudgetsBooth::ComponentExtensions
          )

          # Forms extensions
          Decidim::Budgets::Admin::BudgetForm.include(
            Decidim::BudgetsBooth::BudgetFormExtensions
          )
        end
      end

      # Initializing BudgetsBooth engine before running the server
      # Also, we neeed to new workflow for zip_code_voting as a configuration option.
      initializer "decidim_budgets_booth.add_global_component_settings" do
        manifest = Decidim.find_component_manifest("budgets")
        manifest.settings(:global) do |settings|
          settings.attribute :confirm_vote_content, type: :text, translated: true, editor: true
          settings.attribute :thanks_content, type: :text, translated: true, editor: true
          settings.attribute :city_name, type: :string, translated: true
        end
      end
    end
  end
end
