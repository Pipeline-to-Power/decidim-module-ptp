$(() => {
  const zipcodeInputs = document.querySelectorAll('#zip-code input[type="text"]');
  zipcodeInputs.forEach((input, ind) => {
    input.addEventListener("click", () => {
      input.value = ""
    })
    input.addEventListener("input", () => {
      const val = input.value
      if (val.length > 1) {
        val.slice(0, 1)
      }
      if (val.length === 1) {
        if (!(/^\d+$/).test(val.toString())) {
          input.value = ""
          return
        }
        const nextInput = zipcodeInputs[ind + 1];
        if (nextInput) {
          nextInput.focus();
        } else {
          input.blur()
        }
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

  const togglevalidity = (item) => {
    if (item.classList.contains("is-invisible")) {
      item.classList.remove("is-invisible")
      item.classList.add("is-visible")
    } else {
      item.classList.remove("is-visible")
      item.classList.add("is-invisible")
    }
  }

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
