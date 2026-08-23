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
    const validationSummary = form.querySelector(
            '[data-product-validation-summary]');
    const validationErrors = form.querySelector(
            '[data-product-validation-errors]');
    const MAX_IMAGE_SIZE = 5 * 1024 * 1024;
    const MAX_REQUEST_SIZE = 60 * 1024 * 1024;

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
        const frontImageNames = new Set();
        let totalUploadSize = 0;

        rows.querySelectorAll('.variant-row').forEach(function (row, index) {
            const ram = row.querySelector('[name="variantRam"]');
            const storage = row.querySelector('[name="variantStorage"]');
            const color = row.querySelector('[name="variantColorName"]');
            const price = row.querySelector('[name="variantSellingPrice"]');
            const priceError = row.querySelector('[data-variant-price-error]');
            const frontImage = row.querySelector('[name="variantImageFile"]');
            const backImage = row.querySelector('[name="variantBackImageFile"]');
            const existingFront = row.querySelector('[name="existingVariantImage"]');
            const existingBack = row.querySelector('[name="existingVariantBackImage"]');

            color.setCustomValidity('');
            price.setCustomValidity('');
            frontImage.setCustomValidity('');
            backImage.setCustomValidity('');
            if (priceError) priceError.textContent = '';

            const normalizedColor = color.value.trim().replace(/\s+/g, ' ').toLowerCase();
            const optionKey = `${ram.value}|${storage.value}|${normalizedColor}`;
            if (ram.value && storage.value && normalizedColor) {
                if (optionKeys.has(optionKey)) {
                    color.setCustomValidity('RAM, storage and color duplicate another variant.');
                } else {
                    optionKeys.add(optionKey);
                }
            }

            if (price.value !== '') {
                const priceValue = Number(price.value);
                let message = '';
                if (priceValue <= 0) {
                    message = `Variant ${index + 1}: Selling price must be greater than 0.`;
                } else if (priceValue > 500000000) {
                    message = `Variant ${index + 1}: Selling price cannot exceed 500,000,000 VND.`;
                }
                price.setCustomValidity(message);
                if (priceError) priceError.textContent = message;
            }

            const frontFile = frontImage.files[0];
            const backFile = backImage.files[0];
            const frontName = frontFile ? frontFile.name : existingFront.value;
            const backName = backFile ? backFile.name : existingBack.value;
            const validImageName = /^[a-z0-9][a-z0-9._-]*\.(webp|png|jpg|jpeg)$/i;

            if (!frontName) {
                frontImage.setCustomValidity(`Variant ${index + 1}: Front image is required.`);
            } else if (!validImageName.test(frontName)) {
                frontImage.setCustomValidity(`Variant ${index + 1}: Front image must be JPG, JPEG, PNG or WEBP.`);
            } else if (frontFile && frontFile.size > MAX_IMAGE_SIZE) {
                frontImage.setCustomValidity(`Variant ${index + 1}: Front image must be 5 MB or smaller.`);
            } else if (frontImageNames.has(frontName.toLowerCase())) {
                frontImage.setCustomValidity(`Variant ${index + 1}: Front image name duplicates another variant.`);
            } else {
                frontImageNames.add(frontName.toLowerCase());
            }

            if (!backName) {
                backImage.setCustomValidity(`Variant ${index + 1}: Back image is required.`);
            } else if (!validImageName.test(backName)) {
                backImage.setCustomValidity(`Variant ${index + 1}: Back image must be JPG, JPEG, PNG or WEBP.`);
            } else if (backFile && backFile.size > MAX_IMAGE_SIZE) {
                backImage.setCustomValidity(`Variant ${index + 1}: Back image must be 5 MB or smaller.`);
            } else if (frontName && frontName.toLowerCase() === backName.toLowerCase()) {
                backImage.setCustomValidity(`Variant ${index + 1}: Front image and back image must be different files.`);
            }

            totalUploadSize += frontFile ? frontFile.size : 0;
            totalUploadSize += backFile ? backFile.size : 0;

        });

        if (totalUploadSize > MAX_REQUEST_SIZE) {
            const firstFile = rows.querySelector('[name="variantImageFile"]');
            firstFile.setCustomValidity('The total upload size must not exceed 60 MB.');
        }
    }

    function fieldMessage(field) {
        if (field.validationMessage && field.validity.customError) {
            return field.validationMessage;
        }

        const row = field.closest('.variant-row');
        const rowIndex = row
                ? Array.from(rows.querySelectorAll('.variant-row')).indexOf(row) + 1
                : 0;
        const prefix = rowIndex ? `Variant ${rowIndex}: ` : '';

        switch (field.name) {
            case 'name':
                if (field.validity.valueMissing) return 'Product name is required.';
                if (field.validity.tooShort) return 'Product name must contain at least 2 characters.';
                if (field.validity.tooLong) return 'Product name cannot exceed 50 characters.';
                return 'Product name may contain letters, numbers, spaces and hyphens only.';
            case 'brandId':
                return 'Brand is required.';
            case 'categoryIds':
                return 'Select at least one category.';
            case 'releaseYear':
                return `Release year must be from 2007 to ${field.max}.`;
            case 'warrantyMonths':
                return 'Warranty period must be from 0 to 36 months.';
            case 'variantRam':
                return prefix + 'RAM is required.';
            case 'variantStorage':
                return prefix + 'Storage is required.';
            case 'variantColorName':
                if (field.validity.valueMissing) return prefix + 'Color name is required.';
                if (field.validity.tooLong) return prefix + 'Color name cannot exceed 50 characters.';
                return prefix + 'Color name may contain letters, spaces and hyphens only.';
            case 'variantSellingPrice':
                if (field.validity.valueMissing) return prefix + 'Selling price is required.';
                if (field.validity.badInput) return prefix + 'Selling price must be a number.';
                if (field.validity.rangeUnderflow) return prefix + 'Selling price must be greater than 0.';
                return prefix + 'Selling price cannot exceed 500,000,000 VND.';
            case 'variantImageFile':
                return prefix + 'Front image is required.';
            case 'variantBackImageFile':
                return prefix + 'Back image is required.';
            default:
                return 'Please check the highlighted field.';
        }
    }

    function showValidationSummary() {
        const invalidFields = Array.from(form.querySelectorAll(':invalid'));
        const messages = [];
        const uniqueMessages = new Set();

        form.querySelectorAll('.client-invalid').forEach(function (field) {
            field.classList.remove('client-invalid');
        });
        invalidFields.forEach(function (field) {
            field.classList.add('client-invalid');
            const message = fieldMessage(field);
            if (!uniqueMessages.has(message)) {
                uniqueMessages.add(message);
                messages.push(message);
            }
        });

        validationErrors.innerHTML = '';
        messages.forEach(function (message) {
            const item = document.createElement('li');
            item.textContent = message;
            validationErrors.appendChild(item);
        });
        validationSummary.hidden = messages.length === 0;

        if (messages.length > 0) {
            validationSummary.scrollIntoView({behavior: 'smooth', block: 'center'});
            validationSummary.focus({preventScroll: true});
        }
        return messages.length > 0;
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
        if (showValidationSummary()) {
            event.preventDefault();
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

    form.addEventListener('input', function (event) {
        event.target.classList.remove('client-invalid');
        validationSummary.hidden = true;
    });
    form.addEventListener('change', function (event) {
        event.target.classList.remove('client-invalid');
        validationSummary.hidden = true;
    });

    if (!rows.querySelector('.variant-row')) {
        addRow();
    }
    validateVariants();
})();
