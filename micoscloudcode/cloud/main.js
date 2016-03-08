Parse.Cloud.job("check", function (request, status) {
  var promises = [];
  var notificationClass = Parse.Object.extend("Notifications");
  var notificationQuery = new Parse.Query(notificationClass);
  notificationQuery.equalTo("Sent", false);
  notificationQuery.limit = 1000;
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
      var notify = notification.get('Notify');
      notification.set('Sent', true);
      notification.save();


      var legacyClass = Parse.Object.extend("Legacies");
      var legacyQuery = new Parse.Query(legacyClass);
      legacyQuery.equalTo("Name", legacy);
      legacyQuery.find().then(function(results) {
        var theLegacy = results[0];
        var emoji = theLegacy.get("Emoji");
        theLegacy.increment("TotalArcs", arcs);
        theLegacy.save();
      });

      var installationQuery = new Parse.Query(Parse.Installation);
      if (notify == 0) {
        installationQuery.equalTo("user", toUser)
      };
      if (notify == 1) {
        installationQuery.equalTo("legacy", legacy)
      }
      //installationQuery.equalTo("Legac")
      promises.push(Parse.Push.send({
        where: installationQuery,
        data: {
          alert: (String(emoji) + " " + String(awarder) + ": " + String(arcs.toFixed(1)) + " Arcs to " + String(legacy) + "'s " + String(awardee) + " - " + String(message)),
          badge: "Increment"
        }
      }));
    }
  });
    Parse.Promise.when(promises).then(function() {
      //  status.success("Promises yay!")
    })
});
