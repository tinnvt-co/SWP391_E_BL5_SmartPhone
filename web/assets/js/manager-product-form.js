(function () {
    const editor = document.querySelector('[data-variant-editor]');
    if (!editor) {
        return;
    }

    const rows = editor.querySelector('[data-variant-rows]');
    const template = document.getElementById('variantRowTemplate');
    const addButton = editor.querySelector('[data-add-variant]');

    function addRow() {
        rows.appendChild(template.content.cloneNode(true));
    }

    addButton.addEventListener('click', addRow);

    rows.addEventListener('click', function (event) {
        const removeButton = event.target.closest('[data-remove-variant]');
        if (!removeButton) {
            return;
        }

        removeButton.closest('.variant-row').remove();
    });

    if (!rows.querySelector('.variant-row')) {
        addRow();
    }
})();
