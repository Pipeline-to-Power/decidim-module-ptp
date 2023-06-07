$(() => {
  const $completedModal = $("#vote-completed");

  if (Boolean($completedModal) && $completedModal.attr("data-session") === "true") {
    $completedModal.foundation("open");
  }
});
