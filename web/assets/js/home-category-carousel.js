(() => {
    // Tìm carousel category trên trang chủ; không có thì dừng để tránh lỗi JS.
    const carousel = document.querySelector("[data-category-carousel]");
    if (!carousel) {
        return;
    }

    // Lấy vùng cuộn ngang và hai nút điều hướng.
    const track = carousel.querySelector("[data-category-track]");
    const previousButton = carousel.querySelector("[data-category-previous]");
    const nextButton = carousel.querySelector("[data-category-next]");

    // Khóa Previous ở đầu và Next ở cuối vùng cuộn.
    const updateButtons = () => {
        const maximumScroll = track.scrollWidth - track.clientWidth;
        previousButton.disabled = track.scrollLeft <= 2;
        nextButton.disabled = track.scrollLeft >= maximumScroll - 2;
    };

    // Cuộn ngang một chiều rộng màn hình; -1 là lùi, 1 là tiến.
    const move = (direction) => {
        track.scrollBy({
            left: direction * track.clientWidth,
            behavior: "smooth"
        });
    };

    // Gắn sự kiện điều hướng và tính lại trạng thái nút khi cuộn/đổi kích thước.
    previousButton.addEventListener("click", () => move(-1));
    nextButton.addEventListener("click", () => move(1));
    track.addEventListener("scroll", updateButtons, {passive: true});
    window.addEventListener("resize", updateButtons);
    updateButtons();
})();
