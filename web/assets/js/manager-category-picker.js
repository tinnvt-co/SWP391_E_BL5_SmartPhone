(() => {
    const form = document.getElementById("categoryProductForm");
    if (!form) {
        return;
    }

    const storageKey = `category-products-${form.dataset.categoryId}`;
    const checkboxes = Array.from(
            form.querySelectorAll('input[type="checkbox"][name="productIds"]'));
    const countLabel = document.getElementById("categorySelectionCount");

    let selectedIds = new Set();
    try {
        const savedIds = JSON.parse(sessionStorage.getItem(storageKey) || "[]");
        selectedIds = new Set(savedIds.map(String));
    } catch (error) {
        sessionStorage.removeItem(storageKey);
    }

    const updateCount = () => {
        if (countLabel) {
            countLabel.textContent = `${selectedIds.size} product(s) selected`;
        }
    };

    const saveSelection = () => {
        sessionStorage.setItem(storageKey, JSON.stringify([...selectedIds]));
        updateCount();
    };

    checkboxes.forEach((checkbox) => {
        checkbox.checked = selectedIds.has(checkbox.value);
        checkbox.addEventListener("change", () => {
            if (checkbox.checked) {
                selectedIds.add(checkbox.value);
            } else {
                selectedIds.delete(checkbox.value);
            }
            saveSelection();
        });
    });

    document.querySelectorAll("[data-clear-category-selection]")
            .forEach((link) => link.addEventListener("click", () => {
                sessionStorage.removeItem(storageKey);
            }));

    form.addEventListener("submit", (event) => {
        if (selectedIds.size === 0) {
            event.preventDefault();
            window.alert("Please select at least one product.");
            return;
        }

        checkboxes.forEach((checkbox) => {
            checkbox.disabled = true;
        });
        selectedIds.forEach((productId) => {
            const input = document.createElement("input");
            input.type = "hidden";
            input.name = "productIds";
            input.value = productId;
            form.appendChild(input);
        });
        sessionStorage.removeItem(storageKey);
    });

    updateCount();
})();
