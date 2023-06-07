import initializeProjects from "src/decidim/budgets_booth/projects"
import "src/decidim/budgets_booth/progressFixed"
import "src/decidim/budgets_booth/exit_handler"
import "src/decidim/budgets_booth/popup_selected_project"

$(() => {
  initializeProjects();
});
