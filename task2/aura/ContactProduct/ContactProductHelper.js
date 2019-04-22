/**
 * Created by Eugene on 20.04.2019.
 */
({
    buildCurrencyCode : function(homeCountry) {     
       return homeCountry && homeCountry === 'UK' ? 'GBP' : 'EUR';
    }
})