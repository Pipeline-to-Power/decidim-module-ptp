/* eslint-disable require-jsdoc */
import flatpickr from "vendor/flatpickr/flatpickr"

export default function formDatePicker() {
  $("[data-datepicker]").each((_index, node) => {
    const pickTime = node.dataset.timepicker === "";
    const format = node.dataset.dateFormat || "m/d/Y";
    const clockFormat = window.I18N_CLOCK_FORMAT || "24";

    if (typeof node.value === "string" && node.value.length > 0) {
      // Take out the timezone from the initial date/time format in order to
      // avoid "jumping" when the time is converted back to the input value.
      // The provided value format is e.g. 2022-11-21 17:35:35 UTC.
      const initialDate = new Date(node.value.substring(0, 19));
      node.setAttribute("value", flatpickr.formatDate(initialDate, format));
    }

    flatpickr(node, {
      prevArrow: "<<",
      nextArrow: ">>",
      allowInput: true,
      dateFormat: format,
      enableTime: pickTime,
      time_24hr: clockFormat === "24" // eslint-disable-line camelcase
    });
  });
}
