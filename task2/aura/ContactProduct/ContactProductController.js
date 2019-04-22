/**
 * Created by Eugene on 20.04.2019.
 */
({
    init : function(cmp, event, helper) {
        const recordId = cmp.get('v.recordId');
        console.log('recordId: ', recordId);
        let action = cmp.get('c.getContactProductDetailsFromCase');
        action.setParams({ caseId : recordId });
        action.setCallback(this, function(a){
            var state = a.getState(); // get the response state
            if (state == 'SUCCESS') {

                console.log('a.getReturnValue()', a.getReturnValue());
                var productDetails = a.getReturnValue();
                cmp.set('v.productDetails', productDetails);
                cmp.set('v.currencyCode', helper.buildCurrencyCode(productDetails.Home_Country__c));
            }
        });
        $A.enqueueAction(action);
    }
})