(function () {
    const modal = document.querySelector('[data-brand-product-modal]');
    const openButton = document.querySelector('[data-open-brand-product-modal]');
    if (!modal || !openButton) {
        return;
    }

    const rows = Array.from(modal.querySelectorAll('[data-brand-product-row]'));
    const search = modal.querySelector('[data-brand-product-search]');
    const emptyRow = modal.querySelector('[data-brand-product-empty]');
    const previousButton = modal.querySelector('[data-brand-modal-previous]');
    const nextButton = modal.querySelector('[data-brand-modal-next]');
    const pageLabel = modal.querySelector('[data-brand-modal-page]');
    const summary = modal.querySelector('[data-brand-modal-summary]');
    const selectionLabel = modal.querySelector('[data-brand-modal-selection]');
    const form = modal.querySelector('[data-brand-product-form]');
    const pageSize = 10;
    let currentPage = 1;

    function matchingRows() {
        const keyword = search.value.trim().toLocaleLowerCase();
        return rows.filter(function (row) {
            return row.dataset.searchText.toLocaleLowerCase().includes(keyword);
        });
    }

    function render() {
        const matches = matchingRows();
        const totalPages = Math.max(1, Math.ceil(matches.length / pageSize));
        currentPage = Math.min(currentPage, totalPages);
        const start = (currentPage - 1) * pageSize;
        const visibleRows = matches.slice(start, start + pageSize);

        rows.forEach(function (row) { row.hidden = true; });
        visibleRows.forEach(function (row, index) {
            row.hidden = false;
            row.querySelector('[data-visible-number]').textContent = start + index + 1;
        });
        emptyRow.hidden = matches.length !== 0;
        pageLabel.textContent = 'Page ' + currentPage + ' of ' + totalPages;
        summary.textContent = matches.length === 0 ? '0 products'
                : 'Showing ' + (start + 1) + '–' + Math.min(start + pageSize, matches.length)
                + ' of ' + matches.length + ' products';
        previousButton.disabled = currentPage === 1;
        nextButton.disabled = currentPage === totalPages;
        const selected = rows.filter(function (row) {
            return row.querySelector('input[type="checkbox"]').checked;
        }).length;
        selectionLabel.textContent = selected + ' product(s) selected';
    }

    function openModal() {
        modal.hidden = false;
        document.body.classList.add('category-product-modal-open');
        search.focus();
        render();
    }

    function closeModal() {
        modal.hidden = true;
        document.body.classList.remove('category-product-modal-open');
    }

    openButton.addEventListener('click', openModal);
    modal.querySelectorAll('[data-close-brand-product-modal]').forEach(function (button) {
        button.addEventListener('click', closeModal);
    });
    search.addEventListener('input', function () { currentPage = 1; render(); });
    previousButton.addEventListener('click', function () { currentPage--; render(); });
    nextButton.addEventListener('click', function () { currentPage++; render(); });
    rows.forEach(function (row) {
        row.querySelector('input[type="checkbox"]').addEventListener('change', render);
    });
    form.addEventListener('submit', function (event) {
        const selected = rows.filter(function (row) {
            return row.querySelector('input[type="checkbox"]').checked;
        }).length;
        if (selected === 0) {
            event.preventDefault();
            window.alert('Select at least one product to move.');
            return;
        }
        if (!window.confirm('Move ' + selected + ' selected product(s) to this brand?')) {
            event.preventDefault();
        }
    });
    modal.addEventListener('click', function (event) {
        if (event.target === modal) { closeModal(); }
    });
    document.addEventListener('keydown', function (event) {
        if (event.key === 'Escape' && !modal.hidden) { closeModal(); }
    });
})();
