(function tryExecute(){
    try {
        console.log('Attempting execution');
    } catch(e) {
        setTimeout(tryExecute, 100);
    }
})();
