$(() => {
  const queryString = window.location.search;
  const urlParams = new URLSearchParams(queryString);
  const selectedProject = $(`#project-modal-${urlParams.get("select_project")}`);
  if (selectedProject.length === 1) {
    selectedProject.foundation("open");
  }
});
