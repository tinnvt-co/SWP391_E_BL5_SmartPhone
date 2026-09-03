(function () {
    // Tìm vùng Variant Editor; dừng ngay nếu file JS được tải ở trang không có Product Form.
    const editor = document.querySelector('[data-variant-editor]');
    if (!editor) {
        return;
    }

    // Giữ tham chiếu đến nơi chứa dòng, template dòng mới và nút Add variant.
    const rows = editor.querySelector('[data-variant-rows]');
    const template = document.getElementById('variantRowTemplate');
    const addButton = editor.querySelector('[data-add-variant]');

    // Sao chép mẫu sạch rồi chèn bản sao vào tbody để tạo một variant mới trong DOM.
    function addRow() {
        rows.appendChild(template.content.cloneNode(true));
    }

    addButton.addEventListener('click', addRow);

    // Bắt click từ tbody để nút Remove của cả dòng cũ và dòng mới đều hoạt động.
    rows.addEventListener('click', function (event) {
        const removeButton = event.target.closest('[data-remove-variant]');
        if (!removeButton) {
            return;
        }

        removeButton.closest('.variant-row').remove();
    });

    // Form Add chưa có variant thì tự tạo sẵn một dòng trống cho người dùng nhập.
    if (!rows.querySelector('.variant-row')) {
        addRow();
    }
})();
