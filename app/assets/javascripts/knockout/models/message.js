function Message(message) {
  var self = this;
  self.body = ko.observable(message.body);
  self.to_user = ko.observable(message.to_user);
  self.from_user = ko.observable(message.from_user);
  self.created_at = ko.observable(message.created_at);
  self.time_ago = ko.computed(function() {
    ViewModel.now();
    return moment(self.created_at).fromNow();
  });
}
