$(() => {
  const zipcodeInputs = document.querySelectorAll('#zip-code input[type="text"]');
  const zipCodeelement = document.querySelector("#zip-code-not-valid");
  const togglevalidity = (item) => {
    if (item.classList.contains("is-invisible")) {
      item.classList.remove("is-invisible")
      item.classList.add("is-visible")
    } else {
      item.classList.remove("is-visible")
      item.classList.add("is-invisible")
    }
  }
  if (zipCodeelement.dataset.invalid) {
    console.log("The valididity is", zipCodeelement.dataset.invalid);
    zipcodeInputs.forEach((input) => {
      input.classList.add("is-invalid-input")
    });
    togglevalidity(zipCodeelement)
  }
  zipcodeInputs.forEach((input, ind) => {
    input.setAttribute("maxlength", "1");
    input.addEventListener("click", () => {
      input.select();
    })
    input.addEventListener("input", () => {
      const val = input.value

      if (!(/\d/).test(val)) {
        input.value = ""
        return
      }
      const nextInput = zipcodeInputs[ind + 1];
      if (nextInput) {
        nextInput.focus();
      } else {
        input.blur()
      }
    })
  });
  const fieldsvalid = () => {
    let allFieldsFilled = true;
    zipcodeInputs.forEach((input) => {
      if (input.value.trim() === "") {
        allFieldsFilled = false;
      }
    });
    return allFieldsFilled
  };

  const setZipcodeField = () => {
    let combinedValue = "";
    zipcodeInputs.forEach((input) => {
      combinedValue += input.value.trim();
    });
    document.querySelector('input[name="user_data[metadata]"]').value = combinedValue
  };

  const makeFieldsInvalid = () => {
    zipcodeInputs.forEach((input) => {
      input.classList.add("is-invalid-input")
    })
    togglevalidity(document.querySelector("#zip-code-error"))
  }

  const form = document.querySelector(".new_user_data");
  $(form).on("submit", (ev) => {
    setZipcodeField();
    if (fieldsvalid()) {
      return;
    }

    ev.preventDefault();
    makeFieldsInvalid();
  });
})
