# frozen_string_literal: true

module Decidim
  module BudgetsBooth
    # Customizes the projects helper
    module ProjectsHelperExtensions
      include BudgetsControllerHelper

      delegate :progress?, to: :current_workflow

      def cuurent_phase
        process = Decidim::ParticipatoryProcesses::OrganizationParticipatoryProcesses
                  .new(current_organization).query.find_by(slug: params[:participatory_process_slug])
        process&.active_step&.title
      end
    end
  end
end
