function User(user) {
  var self = this;
  self.id = ko.observable(user.id);
  self.username = ko.observable(user.username);
  self.is_available = ko.observable(user.is_available);
  self.is_online = ko.observable(user.is_online);
}
