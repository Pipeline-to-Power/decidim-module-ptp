$(() => {
  const $userRegistrationForm = $("#register-form");
  const $newsletterModal      = $("#sign-up-newsletter-modal");
  const $newsletterCheck      = $("#sms_registration_newsletter");

  const checkNewsletter = (check) => {
    // when buttons on modal are clicked it loads
    // makes the modal not to show again, and close the modal
    $newsletterCheck.prop("checked", check);
    $newsletterModal.data("continue", true);
    $newsletterModal.foundation("close");
    $userRegistrationForm.submit();
  }

  $userRegistrationForm.on("submit", (ev) => {
    if (!$newsletterModal.data("continue") && !$newsletterCheck.prop("checked")) {
      ev.preventDefault();
      $newsletterModal.foundation("open");
    }
  });

  $newsletterModal.find(".check-newsletter").on("click", (event) => {
    checkNewsletter($(event.target).data("check"));
  });
});
