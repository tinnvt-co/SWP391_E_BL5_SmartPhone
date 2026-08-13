
document.querySelectorAll('[data-qty]').forEach(function(button){
    button.addEventListener('click',function(){
        var input=document.getElementById('qty');if(!input)return;
        var value=parseInt(input.value||'1',10);var max=parseInt(button.dataset.max||'999',10);
        input.value=button.dataset.qty==='plus'?Math.min(value+1,max):Math.max(value-1,1);
    });
});

document.addEventListener('click',function(event){
    var card=event.target.closest('[data-detail-url]');
    if(!card)return;
    if(event.target.closest('a,button,input,select,textarea,label'))return;
    window.location.href=card.dataset.detailUrl;
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

document.querySelectorAll('[data-order-update-inline]').forEach(function(button){
    var raw=button.dataset.orderUpdateInline;
    var id=button.dataset.orderUpdateInline;
    var form=document.querySelector('[data-order-form="'+id+'"]');
    if(!form)return;
    button.addEventListener('click',function(){
        var open=form.classList.toggle('open');
        button.textContent=open?'Close':'Update';
    });
});
document.addEventListener('click',function(event){
    document.querySelectorAll('.order-update-form.open').forEach(function(form){
        var wrap=form.parentElement;
        if(!wrap.contains(event.target)){
            form.classList.remove('open');
            var btn=wrap.querySelector('[data-order-update-inline]');
            if(btn)btn.textContent='Update';
        }
    });
});
(function(){
    var STEP_LABELS=['CONFIRMED','PROCESSING','SHIPPING','DELIVERED'];
    var STEP_DESCS=['Confirmed','Processing','Shipping','Delivered'];
    var STATUS_CODES=['CONFIRMED','PROCESSING','SHIPPING','DELIVERED'];
    var STATUS_DESCS={CONFIRMED:'Confirmed by staff',PROCESSING:'Preparing your order',SHIPPING:'In transit to customer',DELIVERED:'Delivered successfully'};
    var modal=document.getElementById('orderUpdateModal');
    if(!modal)return;
    var codeEl=document.getElementById('modalOrderCode');
    var custEl=document.getElementById('modalOrderCustomer');
    var idEl=document.getElementById('modalOrderId');
    var stepperEl=document.getElementById('modalStepper');
    var gridEl=document.getElementById('modalStatusGrid');
    var submitBtn=document.getElementById('modalSubmit');
    function open(data){
        codeEl.textContent=data.code||'--';
        custEl.textContent=(data.customer||'--')+(data.total?' Â· '+data.total+'â‚«':'');
        idEl.value=data.id||'';
        var current=(data.status||'').toUpperCase();
        var stepIndex=STEP_LABELS.indexOf(current);
        stepperEl.innerHTML='';
        STEP_LABELS.forEach(function(label,i){
            var item=document.createElement('div');
            var state=i<stepIndex?'done':(i===stepIndex?'current':'future');
            item.className='order-stepper-item '+state;
            item.innerHTML='<div class="order-stepper-dot">'+(i+1)+'</div><div class="order-stepper-label">'+STEP_DESCS[i]+'</div>';
            stepperEl.appendChild(item);
        });
        gridEl.innerHTML='';
        STATUS_CODES.forEach(function(code){
            var option=document.createElement('label');
            option.className='order-status-option';
            option.innerHTML='<input type="radio" name="status" value="'+code+'"'+(code===current?' checked':'')+'><span class="order-status-option-dot"></span><div class="order-status-option-info"><span class="order-status-option-code">'+code.replace(/_/g,' ')+'</span><span class="order-status-option-desc">'+STATUS_DESCS[code]+'</span></div>';
            gridEl.appendChild(option);
        });
        submitBtn.disabled=true;
        gridEl.querySelectorAll('input[type=radio]').forEach(function(radio){
            radio.addEventListener('change',function(){
                submitBtn.disabled=radio.value===current;
                submitBtn.textContent=radio.value===current?'No Changes':'Confirm Update';
            });
        });
        modal.hidden=false;
        document.body.classList.add('modal-open');
    }
    function close(){
        modal.hidden=true;
        document.body.classList.remove('modal-open');
    }
    document.addEventListener('click',function(event){
        var trigger=event.target.closest('[data-order-update]');
        if(trigger){event.preventDefault();
            var data={
                id:trigger.dataset.orderId,
                code:trigger.dataset.orderCode,
                status:trigger.dataset.orderStatus,
                customer:trigger.dataset.orderCustomer,
                total:trigger.dataset.orderTotal,
                method:trigger.dataset.orderMethod,
                type:trigger.dataset.orderType
            };
            open(data);
            return;
        }
        if(event.target.closest('[data-modal-close]')){event.preventDefault();close();}
    });
    document.addEventListener('keydown',function(event){
        if(event.key==='Escape'&&!modal.hidden){close();}
    });
})();
(function(){
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
            if(price)price.textContent=new Intl.NumberFormat('vi-VN').format(Number(variant.dataset.price))+' đ';
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
})();

