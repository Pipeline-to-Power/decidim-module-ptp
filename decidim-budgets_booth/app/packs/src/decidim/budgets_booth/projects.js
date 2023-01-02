const initializeProjects = () => {
  const $projects = $("#projects, #project, .reveal.large");
  const $budgetSummaryTotal = $(".budget-summary__total");
  const $budgetExceedModal = $("#budget-excess");
  const $budgetSummary = $(".budget-summary__progressbox");
  const totalAllocation = parseInt($budgetSummaryTotal.attr("data-total-allocation"), 10);

  const cancelEvent = (event) => {
    event.stopPropagation();
    event.preventDefault();
  };
  $projects.on("click", ".customized-budget", (event) => {
    const currentAllocation = parseInt($budgetSummary.attr("data-current-allocation"), 10);
    const $currentTarget = $(event.currentTarget);
    const projectAllocation = parseInt($currentTarget.attr("data-allocation"), 10);
    if ($currentTarget.attr("disabled")) {
      cancelEvent(event);
    } else if (($currentTarget.attr("data-add") === "true") && ((currentAllocation + projectAllocation) > totalAllocation)) {
      $budgetExceedModal.foundation("toggle");
      cancelEvent(event);
    }
  });
};


export default initializeProjects;
