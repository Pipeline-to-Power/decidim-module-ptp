# frozen_string_literal: true

require "decidim/budgets_booth/workflows/zip_code"
Decidim::Budgets.workflows[:zip_code] = Decidim::BudgetsBooth::Workflows::ZipCode
