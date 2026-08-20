(() => {
    const form = document.getElementById("categoryForm");
    if (!form) {
        return;
    }

    const fields = Array.from(form.querySelectorAll("[data-category-text]"));
    const validText = /^[\p{L}\p{N}]+(?: [\p{L}\p{N}]+)*$/u;

    const validateField = (field) => {
        const value = field.value.trim().replace(/\s+/g, " ");
        field.setCustomValidity("");

        if (value && !validText.test(value)) {
            const label = field.dataset.categoryText === "name"
                    ? "Category name" : "Description";
            field.setCustomValidity(
                    `${label} may contain letters, numbers and spaces only.`);
        }
    };

    fields.forEach((field) => {
        field.addEventListener("input", () => validateField(field));
        field.addEventListener("blur", () => {
            field.value = field.value.trim().replace(/\s+/g, " ");
            validateField(field);
        });
    });

    form.addEventListener("submit", (event) => {
        fields.forEach(validateField);
        if (!form.checkValidity()) {
            event.preventDefault();
            form.reportValidity();
        }
    });
})();
