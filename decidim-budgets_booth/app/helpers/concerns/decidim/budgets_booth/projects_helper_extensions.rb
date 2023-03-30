# frozen_string_literal: true

module Decidim
  module BudgetsBooth
    # Customizes the projects helper
    module ProjectsHelperExtensions
      include BudgetsControllerHelper

      delegate :progress?, to: :current_workflow

      def cuurent_phase
        Decidim::ParticipatoryProcesses::OrganizationParticipatoryProcesses.new(current_organization)
                                                                           .query
                                                                           .where(slug: params[:participatory_process_slug])
                                                                           .first
                                                                           .active_step
                                                                           .title
      end
    end
  end
end
