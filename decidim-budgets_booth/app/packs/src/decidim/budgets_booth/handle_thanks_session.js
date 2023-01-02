$(() => {
  const $modal = $("#thanks-message");

  if (Boolean($modal) && $modal.attr("data-session") === "true") {
    $modal.foundation("open");
  }
});
