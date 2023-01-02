import SlimSelect from "vendor/slim-select/slimselect"

document.addEventListener("DOMContentLoaded", () => {
  document.querySelectorAll(".country-select").forEach((select) => {
    const data = [];
    select.querySelectorAll("option").forEach((opt) => {
      if (opt.value.length < 1) {
        return;
      }

      data.push({
        text: opt.textContent,
        value: opt.value,
        selected: opt.selected,
        innerHTML: `<span class="country-flag"><img src="${opt.dataset.flagImage}" loading="lazy" alt=""></span> ${opt.textContent}`
      });
    });

    /* eslint-disable no-new */
    new SlimSelect({select, data});
  });
});
