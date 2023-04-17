$(() => {
  const zipcodeInputs = document.querySelectorAll('#zip-code input[type="text"]');
  const zipCodeNotValid = document.querySelector("#zip-code-not-valid");
  const zipCodeError = document.querySelector("#zip-code-error");
  const onlyLettersAllowed = document.querySelector("#only-letters-allowed");
  const submitBotton = document.querySelector("button[name='commit']");

  const removeAllErrorMessages = () => {
    document.querySelectorAll(".form-error").forEach((element) => {
      if (element.classList.contains("is-visible")) {
        element.classList.remove("is-visible")
        element.classList.add("is-invisible")
      }
    })
  }

  const showErrorMessage = (element) => {
    removeAllErrorMessages()
    if (element.classList.contains("is-invisible")) {
      element.classList.remove("is-invisible")
      element.classList.add("is-visible")
    }
  }
  const invalidField = (element) => {
    zipcodeInputs.forEach((item) => {
      if (!item.classList.contains("is-invalid-input")) {
        item.classList.add("is-invalid-input")
      }
    })
    showErrorMessage(element)
  }

  const resetField = () => {
    zipcodeInputs.forEach((item) => {
      if (item.classList.contains("is-invalid-input")) {
        item.classList.remove("is-invalid-input")
      }
    })
  }

  const validUserInput = (val) => (/^[a-zA-Z0-9]+$/).test(val)

   // check if the hidden zip code input field has a value
   const hiddenZipCodeField = document.querySelector('input[name="user_data[zip_code]"]');
   if (hiddenZipCodeField.value.trim() !== "") {
     const zipCodeValue = hiddenZipCodeField.value.trim().split("");
     zipcodeInputs.forEach((input, index) => {
       input.value = zipCodeValue[index] || "";
     });
   }

  if (zipCodeNotValid.dataset.invalid) {
    zipcodeInputs.forEach((input) => {
      input.classList.add("is-invalid-input")
    });
    invalidField(zipCodeNotValid)
  }
  zipcodeInputs.forEach((input, ind) => {
    input.setAttribute("maxlength", "1");
    input.addEventListener("click", () => {
      resetField();
      input.select();
    })

    input.addEventListener("paste", (event) => {
      const clipboardData = event.clipboardData || window.clipboardData;
      const pastedData = clipboardData.getData("text").trim();
      if (!validUserInput(pastedData)) {
        invalidField(onlyLettersAllowed)
        input.blur();
        input.classList.add("is-invalid-input");
        return
      }

      // find the first empty input field and paste the data there
      let jj = 0;
      for (let ii = ind; ii < zipcodeInputs.length; ii += 1) {
        if (jj > pastedData.length) {
          console.log("1")
          return;
        }
        if (pastedData.substr(jj, 1)) {
          zipcodeInputs[ii].value = pastedData.substr(jj, 1);
          zipcodeInputs[ii].focus();
          jj += 1
        }
      }
      event.preventDefault();
    });
    input.addEventListener("keydown", function(event) {
      const previousInput = zipcodeInputs[ind - 1];
      if (event.key === "Backspace") {
        if (previousInput) {
          previousInput.select();
          event.preventDefault();
          input.value = ""
        }
        console.log("Backspace key pressed");
      }
    });

    input.addEventListener("input", () => {
      const val = input.value

      if (!validUserInput(val)) {
        input.value = ""
        return
      }
      const nextInput = zipcodeInputs[ind + 1];
      if (nextInput) {
        nextInput.select();
      } else {
        submitBotton.focus();
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
    document.querySelector('input[name="user_data[zip_code]"]').value = combinedValue
  };

  const form = document.querySelector(".new_user_data");
  $(form).on("submit", (ev) => {
    removeAllErrorMessages()
    setZipcodeField();
    if (fieldsvalid()) {
      return;
    }

    ev.preventDefault();
    invalidField(zipCodeError);
  });
})
