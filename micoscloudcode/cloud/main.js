Parse.Cloud.job("check", function (request, status) {
  var notificationClass = Parse.Object.extend("Notifications");
  var notificationQuery = new Parse.Query(notificationClass);
  notificationQuery.equalTo("Sent", false);
  notificationQuery.find().then(function(qresults) {
    for (var i = 0; i < (qresults.length); i++) {
      var notification = qresults[i];
      var legacy = notification.get('Legacy');
      var arcs = notification.get('Arcs');
      var message = notification.get('Message');
      var fromUser = notification.get('fromUser');
      var toUser = notification.get('toUser');
      var awardee = notification.get('Awardee');
      var awarder = notification.get('Awarder');
      var sendToAll = true

      var legacyClass = Parse.Object.extend("Legacies");
      var legacyQuery = new Parse.Query(legacyClass);
      legacyQuery.equalTo("Name", legacy);
      legacyQuery.find().then(function(results) {
        var theLegacy = results[0];
        theLegacy.increment("TotalArcs", arcs)
        theLegacy.save();
      });

      var installationQuery = new Parse.Query(Parse.Installation);
      if (sendToAll == false) {
        installationQuery.equalTo("user", toUser)
      };
      //installationQuery.equalTo("Legac")
      Parse.Push.send({
        where: installationQuery,
        data: {
          alert: (String(arcs) + " Arcs to " + String(legacy) + " for " + String(awardee) + " " + String(message))
        }
      });
    }
  });
  //status.success("meh")
});
