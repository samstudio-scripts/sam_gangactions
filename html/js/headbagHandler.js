window.addEventListener('message', function (event) {
    var bag = document.getElementById('headbag');
    if (event.data.type === 'bagOn') {
        bag.style.display = 'block';
    } else if (event.data.type === 'bagOff') {
        bag.style.display = 'none';
    }
});
