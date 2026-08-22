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
    const productNameInput = form.querySelector('input[name="name"]');
    const brandSelect = form.querySelector('[data-product-brand]');
    const brandConfirmation = form.querySelector(
            'input[name="confirmBrandMismatch"]');

    productNameInput.addEventListener('input', function () {
        brandConfirmation.value = 'false';
    });
    brandSelect.addEventListener('change', function () {
        brandConfirmation.value = 'false';
    });

    function detectBrands(productName) {
        const name = productName.toLowerCase();
        const detected = [];
        if (/\biphone\b/.test(name)) detected.push('Apple');
        if (/\b(samsung|galaxy)\b/.test(name)) detected.push('Samsung');
        if (/\b(xiaomi|redmi|poco)\b/.test(name)) detected.push('Xiaomi');
        if (/\boppo\b/.test(name)) detected.push('Oppo');
        return Array.from(new Set(detected));
    }

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

    function validateVariants() {
        const optionKeys = new Set();

        rows.querySelectorAll('.variant-row').forEach(function (row) {
            const ram = row.querySelector('[name="variantRam"]');
            const storage = row.querySelector('[name="variantStorage"]');
            const color = row.querySelector('[name="variantColorName"]');

            color.setCustomValidity('');

            const normalizedColor = color.value.trim().replace(/\s+/g, ' ').toLowerCase();
            const optionKey = `${ram.value}|${storage.value}|${normalizedColor}`;
            if (ram.value && storage.value && normalizedColor) {
                if (optionKeys.has(optionKey)) {
                    color.setCustomValidity('RAM, storage and color duplicate another variant.');
                } else {
                    optionKeys.add(optionKey);
                }
            }

        });
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
        validateVariants();
    });

    rows.addEventListener('input', validateVariants);
    rows.addEventListener('change', validateVariants);

    form.addEventListener('submit', function (event) {
        validateCategories();
        validateVariants();
        if (!form.checkValidity()) {
            event.preventDefault();
            form.reportValidity();
            return;
        }

        const selectedOption = brandSelect.options[brandSelect.selectedIndex];
        const selectedBrand = selectedOption
                ? selectedOption.dataset.brandName : '';
        const detectedBrands = detectBrands(productNameInput.value);
        const hasSeveralBrands = detectedBrands.length > 1;
        const hasWrongBrand = detectedBrands.length === 1 && selectedBrand
                && detectedBrands[0].toLowerCase()
                !== selectedBrand.toLowerCase();
        if ((hasSeveralBrands || hasWrongBrand)
                && brandConfirmation.value !== 'true') {
            const warning = hasSeveralBrands
                    ? 'The product name contains keywords from multiple brands: '
                    + detectedBrands.join(', ')
                    + '. Do you want to save anyway?'
                    : 'The product name appears to belong to '
                    + detectedBrands[0] + ', but the selected brand is '
                    + selectedBrand + '. Do you want to save anyway?';
            const confirmed = window.confirm(warning);
            if (!confirmed) {
                event.preventDefault();
                return;
            }
            brandConfirmation.value = 'true';
        }
    });

    if (!rows.querySelector('.variant-row')) {
        addRow();
    }
    validateVariants();
})();
