
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

document.querySelectorAll('[data-variant-picker]').forEach(function(picker){
    var selectedMemory=(picker.querySelector('[data-memory].active')||{}).dataset?.memory;
    var selectedColor=(picker.querySelector('[data-color].active')||{}).dataset?.color;
    var variants=Array.from(picker.querySelectorAll('[data-variant]'));
    function chooseVariant(){
        var variant=variants.find(function(item){return item.dataset.memory===selectedMemory&&item.dataset.color===selectedColor;});
        if(!variant){variant=variants.find(function(item){return item.dataset.memory===selectedMemory;});}
        if(!variant)return;
        selectedColor=variant.dataset.color;
        picker.querySelectorAll('[data-color]').forEach(function(button){button.classList.toggle('active',button.dataset.color===selectedColor);});
        var price=picker.querySelector('[data-variant-price]');
        if(price)price.textContent=new Intl.NumberFormat('vi-VN').format(Number(variant.dataset.price))+' ₫';
        var image=picker.querySelector('[data-variant-image]');
        if(image&&variant.dataset.image)image.src=variant.dataset.image;
        var colorName=picker.querySelector('[data-color-name]');
        if(colorName)colorName.textContent=selectedColor;
        var stock=Number(variant.dataset.stock||0);
        var stockLabel=picker.querySelector('[data-stock-label]');
        if(stockLabel){stockLabel.textContent=stock>0?'In stock ('+stock+')':'Out of stock';stockLabel.classList.toggle('danger',stock===0);}
        var quantityPlus=picker.querySelector('[data-qty="plus"]');
        if(quantityPlus)quantityPlus.dataset.max=String(stock);
        var cartButton=picker.querySelector('[data-cart-button]');
        if(cartButton)cartButton.disabled=stock===0;
    }
    picker.querySelectorAll('[data-memory]').forEach(function(button){button.addEventListener('click',function(){selectedMemory=button.dataset.memory;picker.querySelectorAll('[data-memory]').forEach(function(item){item.classList.toggle('active',item===button);});chooseVariant();});});
    picker.querySelectorAll('[data-color]').forEach(function(button){button.addEventListener('click',function(){selectedColor=button.dataset.color;chooseVariant();});});
    chooseVariant();
});
