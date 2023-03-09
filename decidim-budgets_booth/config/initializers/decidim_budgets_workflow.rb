# frozen_string_literal: true

require "decidim/budgets_booth/zip_code"
Decidim::Budgets.workflows[:zip_code] = Decidim::BudgetsBooth::ZipCode
