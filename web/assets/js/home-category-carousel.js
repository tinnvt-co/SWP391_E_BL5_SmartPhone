(() => {
    const carousel = document.querySelector("[data-category-carousel]");
    if (!carousel) {
        return;
    }

    const track = carousel.querySelector("[data-category-track]");
    const previousButton = carousel.querySelector("[data-category-previous]");
    const nextButton = carousel.querySelector("[data-category-next]");

    const updateButtons = () => {
        const maximumScroll = track.scrollWidth - track.clientWidth;
        previousButton.disabled = track.scrollLeft <= 2;
        nextButton.disabled = track.scrollLeft >= maximumScroll - 2;
    };

    const move = (direction) => {
        track.scrollBy({
            left: direction * track.clientWidth,
            behavior: "smooth"
        });
    };

    previousButton.addEventListener("click", () => move(-1));
    nextButton.addEventListener("click", () => move(1));
    track.addEventListener("scroll", updateButtons, {passive: true});
    window.addEventListener("resize", updateButtons);
    updateButtons();
})();
