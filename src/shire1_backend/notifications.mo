import Text "mo:base/Text";
import Time "mo:base/Time";
import List "mo:base/List";

actor {
  type Notification = {
    user: Principal;
    message: Text;
    timestamp: Time.Time;
  };

  private stable var notifications: List.List<Notification> = List.nil();

  public shared func sendNotification(user: Principal, message: Text) : async () {
    let notification = {
      user = user;
      message = message;
      timestamp = Time.now();
    };
    notifications := List.push(notification, notifications);
  };

  public query func getNotifications(user: Principal) : async [Notification] {
    let userNotifications = List.filter(notifications, func(n: Notification) : Bool { n.user == user });
    List.toArray(userNotifications)
  };
}