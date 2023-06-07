# frozen_string_literal: true

module Decidim
  module BudgetsBooth
    module BudgetListItemCellExtensions
      extend ActiveSupport::Concern
      include VotingSupport

      included do
        delegate :voting_open?, :voting_finished?, to: :controller

        def button_text
          t(:vote, scope: i18n_scope)
        end

        def mark_image_as_voted(budget)
          return nil unless voted_this?(budget)

          return nil unless voting_open?

          " voted-budget"
        end

        def link_to_budget(budget, **options)
          link_options = options

          link_target =
            if voting_open? && !voted_this?(budget)
              budget_voting_index_path(budget)
            elsif voting_open? && voted_this?(budget)
              link_options[:remote] = true
              decidim_budgets.budget_order_path(budget)
            else
              budget_projects_path(budget)
            end

          link_to link_target, **link_options do
            yield
          end
        end

        def generate_text_for(budget)
          if voted_this?(budget)
            t("decidim.budgets.budget_list_item.show_my_vote")
          else
            t("decidim.budgets.budget_list_item.more_info")
          end
        end
      end
    end
  end
end
