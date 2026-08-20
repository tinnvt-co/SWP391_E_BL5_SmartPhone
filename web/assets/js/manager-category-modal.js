(() => {
    const modal = document.querySelector("[data-category-product-modal]");
    const openButton = document.querySelector("[data-open-category-product-modal]");
    if (!modal || !openButton) {
        return;
    }

    const form = modal.querySelector("[data-category-product-form]");
    const searchInput = modal.querySelector("[data-category-product-search]");
    const allRows = Array.from(modal.querySelectorAll("[data-category-product-row]"));
    const emptyRow = modal.querySelector("[data-category-product-empty]");
    const previousButton = modal.querySelector("[data-category-modal-previous]");
    const nextButton = modal.querySelector("[data-category-modal-next]");
    const pageLabel = modal.querySelector("[data-category-modal-page]");
    const summary = modal.querySelector("[data-category-modal-summary]");
    const selectionLabel = modal.querySelector("[data-category-modal-selection]");
    const pageSize = 10;
    let currentPage = 1;
    let filteredRows = allRows;

    const updateSelection = () => {
        const selectedTotal = allRows.filter((row) =>
            row.querySelector('[name="productIds"]').checked).length;
        selectionLabel.textContent = `${selectedTotal} product(s) selected`;
    };

    const renderPage = () => {
        const totalPages = Math.max(1, Math.ceil(filteredRows.length / pageSize));
        currentPage = Math.min(Math.max(currentPage, 1), totalPages);
        const start = (currentPage - 1) * pageSize;
        const end = Math.min(start + pageSize, filteredRows.length);

        allRows.forEach((row) => {
            row.hidden = true;
        });
        filteredRows.slice(start, end).forEach((row, index) => {
            row.hidden = false;
            row.querySelector("[data-visible-number]").textContent = start + index + 1;
        });

        emptyRow.hidden = filteredRows.length !== 0;
        summary.textContent = filteredRows.length === 0
                ? "0 products"
                : `Showing ${start + 1}–${end} of ${filteredRows.length} products`;
        pageLabel.textContent = `Page ${currentPage} of ${totalPages}`;
        previousButton.disabled = currentPage === 1;
        nextButton.disabled = currentPage === totalPages;
    };

    const clearSelection = () => {
        allRows.forEach((row) => {
            row.querySelector('[name="productIds"]').checked = false;
        });
        updateSelection();
    };

    const openModal = () => {
        modal.hidden = false;
        document.body.classList.add("category-product-modal-open");
        currentPage = 1;
        renderPage();
        searchInput.focus();
    };

    const closeModal = () => {
        modal.hidden = true;
        document.body.classList.remove("category-product-modal-open");
        searchInput.value = "";
        filteredRows = allRows;
        currentPage = 1;
        clearSelection();
    };

    openButton.addEventListener("click", openModal);
    modal.querySelectorAll("[data-close-category-product-modal]")
            .forEach((button) => button.addEventListener("click", closeModal));

    modal.addEventListener("click", (event) => {
        if (event.target === modal) {
            closeModal();
        }
    });

    document.addEventListener("keydown", (event) => {
        if (event.key === "Escape" && !modal.hidden) {
            closeModal();
        }
    });

    searchInput.addEventListener("input", () => {
        const keyword = searchInput.value.trim().toLocaleLowerCase("vi");
        filteredRows = allRows.filter((row) =>
            row.dataset.productName.toLocaleLowerCase("vi").includes(keyword));
        currentPage = 1;
        renderPage();
    });

    searchInput.addEventListener("keydown", (event) => {
        if (event.key === "Enter") {
            event.preventDefault();
        }
    });

    previousButton.addEventListener("click", () => {
        currentPage -= 1;
        renderPage();
    });

    nextButton.addEventListener("click", () => {
        currentPage += 1;
        renderPage();
    });

    form.addEventListener("change", updateSelection);
    form.addEventListener("submit", (event) => {
        const hasSelection = allRows.some((row) =>
            row.querySelector('[name="productIds"]').checked);
        if (!hasSelection) {
            event.preventDefault();
            window.alert("Please select at least one product.");
        }
    });

    renderPage();
    updateSelection();
})();
