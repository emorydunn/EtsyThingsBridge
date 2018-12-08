var OAuth = require('OAuth');
var oauthKeys = require("./keys.json");

var oauth = new OAuth.OAuth(
  'https://openapi.etsy.com/v2/oauth/request_token?scope=listings_r',
  'https://openapi.etsy.com/v2/oauth/access_token?scope=listings_r',
  oauthKeys.consumerKey,
  oauthKeys.consumerSecret,
  '1.0A',
  null,
  'HMAC-SHA1'
);

function fetchOpenOrders(callback) {
    oauth.get(
    'https://openapi.etsy.com/v2/shops/' + oauthKeys.storeName + '/receipts/open',
    oauthKeys.token,
    oauthKeys.tokenSecret,
    callback);
}

function fetchTransactions(orderID, callback) {
  oauth.get(
    'https://openapi.etsy.com/v2/receipts/' + orderID + '/transactions',
    oauthKeys.token,
    oauthKeys.tokenSecret,
    callback);
}


module.exports = {
  fetchOpenOrders: fetchOpenOrders,
  fetchTransactions: fetchTransactions
};
