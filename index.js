var osa = require('osa')
var etsyAuth = require('./etsyAuth')
var thingsBridge = require('./thingsBridge')

function ordersCallback(error, data, response) {
  if (error) throw new Error(error);
  var body = JSON.parse(data);
  body["results"].forEach(parseOrder);
}

function transactionsCallback(error, data, response) {
  if (error) throw new Error(error);
  var body = JSON.parse(data);
  console.log("Found " + body["count"] + " transactions")
  body["results"].forEach(parseTransaction);
}


function parseOrder(order) {
  console.log("Making project for " + order["name"])
  osa(thingsBridge.makeProject, order, thingsBridge.osaHandler)

  etsyAuth.fetchTransactions(order["receipt_id"], transactionsCallback)

}

function parseTransaction(transaction) {
  var toDoName = transaction["title"]

  transaction["variations"].forEach(function (variation) {
    toDoName += ", " + variation["formatted_value"]
  })

  console.log("Creating todo for transaction: " + toDoName)
  osa(thingsBridge.makeToDo, transaction, thingsBridge.osaHandler)

}


console.log("Fetching Open Orders at " + new Date().toString())
etsyAuth.fetchOpenOrders(ordersCallback)
