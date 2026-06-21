window.addEventListener('message', function (event) {
    const bag = document.getElementById('headbag');

    if (event.data.type === 'bagOn') {
        const transparency = Number(event.data.transparency);
        const safeTransparency = Number.isFinite(transparency)
            ? Math.min(Math.max(transparency, 0), 100)
            : 0;

        bag.style.opacity = String(1 - safeTransparency / 100);
        bag.style.display = 'block';
    } else if (event.data.type === 'bagOff') {
        bag.style.display = 'none';
    }
});
