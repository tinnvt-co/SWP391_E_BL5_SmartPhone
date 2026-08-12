
document.querySelectorAll('[data-qty]').forEach(function(button){
    button.addEventListener('click',function(){
        var input=document.getElementById('qty');if(!input)return;
        var value=parseInt(input.value||'1',10);var max=parseInt(button.dataset.max||'999',10);
        input.value=button.dataset.qty==='plus'?Math.min(value+1,max):Math.max(value-1,1);
    });
});

function confirmDeactivate(type){return window.confirm('Deactivate this '+type+'? It will no longer appear on public screens.');}

var catalogForm=document.getElementById('catalogForm');
if(catalogForm){
    var searchInput=document.getElementById('productSearch');
    var brandFilter=document.getElementById('brandFilter');
    document.querySelectorAll('[data-brand]').forEach(function(button){
        button.addEventListener('click',function(){
            brandFilter.value=button.dataset.brand;
            catalogForm.requestSubmit();
        });
    });
    catalogForm.addEventListener('submit',function(event){
        searchInput.value=searchInput.value.trim().replace(/\s+/g,' ');
        searchInput.setCustomValidity('');
        if(searchInput.value.length>100){
            event.preventDefault();
            searchInput.setCustomValidity('Search keyword must not exceed 100 characters.');
            searchInput.reportValidity();
        }
    });
}
