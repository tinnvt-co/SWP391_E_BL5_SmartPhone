(function () {
    const editor = document.querySelector('[data-variant-editor]');
    if (!editor) {
        return;
    }

    const rows = editor.querySelector('[data-variant-rows]');
    const template = document.getElementById('variantRowTemplate');

    function addRow() {
        rows.appendChild(template.content.cloneNode(true));
    }

    editor.querySelector('[data-add-variant]').addEventListener('click', addRow);

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
