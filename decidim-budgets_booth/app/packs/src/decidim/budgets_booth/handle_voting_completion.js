const initVoteCompleteElement = () => {
  const template = document.getElementById("vote-completed-snippet");
  if (!template) {
    return;
  }

  const wrapper = document.createElement("div");
  wrapper.innerHTML = template.innerText;

  const reveal = wrapper.querySelector("div");
  document.body.append(reveal);

  // With foundation we still have to use jQuery.
  // The purpose is to open the reveal after Foundation has initialized the
  // reveal element which happens with the Decidim's default JS. This code is
  // run before that.
  $(reveal).on("init.zf.reveal", () => $(reveal).foundation("open"));
}

initVoteCompleteElement();
