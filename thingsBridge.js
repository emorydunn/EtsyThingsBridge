var osa = require('osa')

function makeProject(order) {
  var things = Application("Things");
  things.includeStandardAdditions = true;
  var etsyArea = things.areas.byName("Etsy")

  // Check for existing projects
  if (things.projects.where({notes: {'_contains': order["receipt_id"]}}).length != 0) {
    return
  }

  newProject = things.Project({
    name: order["name"],
    area: etsyArea,
    dueDate: new Date(order["shipped_date"]*1000),
    notes: order["receipt_id"]
  })

  things.projects.push(newProject)

}

function makeToDo(transaction) {
  var things = Application("Things");
  things.includeStandardAdditions = true;
  var projects = things.projects.where({notes: {'_contains': transaction["receipt_id"]}})

  // Get project for todo
  if (projects.length == 0) {
    console.log("Could not find project for " + transaction["receipt_id"])
    return
  }
  // Check for existing todos
  if (things.toDos.where({notes: {'_contains': transaction["transaction_id"]}}).length != 0) {
    return
  }


  var project = projects[0]
  var toDoName = transaction["title"]  // base name

  // Add variations
  transaction["variations"].forEach(function (variation) {
    toDoName += ", " + variation["formatted_value"]
  })

  newToDo = things.ToDo({
    name: toDoName,
    project: project,
    notes: transaction["transaction_id"]
  })

  things.projects.push(newToDo)

}


function osaHandler(error, result, log) {
  if (error) throw new Error(error);
}


module.exports = {
  makeProject: makeProject,
  makeToDo: makeToDo,
  osaHandler: osaHandler
};
