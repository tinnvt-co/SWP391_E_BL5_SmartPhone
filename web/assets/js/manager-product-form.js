(function () {
    const editor = document.querySelector('[data-variant-editor]');
    if (!editor) {
        return;
    }

    const rows = editor.querySelector('[data-variant-rows]');
    const template = document.getElementById('variantRowTemplate');
    const form = editor.closest('form');
    const categoryInputs = Array.from(
            form.querySelectorAll('input[name="categoryIds"]'));

    function validateCategories() {
        if (!categoryInputs.length) {
            return;
        }
        const hasSelection = categoryInputs.some(function (input) {
            return input.checked;
        });
        categoryInputs[0].setCustomValidity(
                hasSelection ? '' : 'Select at least one category.');
    }

    function addRow() {
        rows.appendChild(template.content.cloneNode(true));
    }

    editor.querySelector('[data-add-variant]').addEventListener('click', addRow);

    categoryInputs.forEach(function (input) {
        input.addEventListener('change', validateCategories);
    });
    validateCategories();

    rows.addEventListener('click', function (event) {
        const removeButton = event.target.closest('[data-remove-variant]');
        if (!removeButton) {
            return;
        }
        if (rows.querySelectorAll('.variant-row').length === 1) {
            window.alert('A product must have at least one variant.');
            return;
        }
        removeButton.closest('.variant-row').remove();
    });

    if (!rows.querySelector('.variant-row')) {
        addRow();
    }
})();
