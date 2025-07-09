import Principal "mo:base/Principal";
import Text "mo:base/Text";
import Array "mo:base/Array";
import Nat "mo:base/Nat";
import Time "mo:base/Time";
import List "mo:base/List";

actor {
  type Member = {
    principal: Principal;
    name: Text;
  };

  type Group = {
    id: Nat;
    name: Text;
    members: [Member];
    contributionAmount: Nat;
    rotationOrder: [Principal];
    currentPayoutIndex: Nat;
    createdAt: Time.Time;
  };

  private stable var groups: List.List<Group> = List.nil();
  private stable var nextGroupId: Nat = 0;

  public shared ({caller}) func createGroup(name: Text, members: [Member], contributionAmount: Nat) : async Nat {
    // Explicitly use caller to avoid warning
    let creator = caller; // Store caller to ensure compiler recognizes usage
    if (Principal.isAnonymous(creator)) {
      return 0; // Indicate failure for anonymous callers
    };
    let group = {
      id = nextGroupId;
      name = name;
      members = members;
      contributionAmount = contributionAmount;
      rotationOrder = Array.map<Member, Principal>(members, func(m) { m.principal });
      currentPayoutIndex = 0;
      createdAt = Time.now();
    };
    groups := List.push(group, groups);
    nextGroupId += 1;
    group.id
  };

  public query func getGroups() : async [Group] {
    List.toArray(groups)
  };

  public query func getGroup(id: Nat) : async ?Group {
    List.find(groups, func(g: Group) : Bool { g.id == id })
  };

  public shared ({caller}) func updatePayoutIndex(groupId: Nat) : async Bool {
    // Explicitly use caller to avoid warning
    let updater = caller; // Store caller to ensure compiler recognizes usage
    if (Principal.isAnonymous(updater)) {
      return false;
    };
    switch (List.find(groups, func(g: Group) : Bool { g.id == groupId })) {
      case null { return false };
      case (?group) {
        // Check if caller is a member
        let isMember = Array.find<Member>(group.members, func(m) { m.principal == updater }) != null;
        if (not isMember) {
          return false;
        };
        let updatedGroup = {
          id = group.id;
          name = group.name;
          members = group.members;
          contributionAmount = group.contributionAmount;
          rotationOrder = group.rotationOrder;
          currentPayoutIndex = group.currentPayoutIndex + 1;
          createdAt = group.createdAt;
        };
        groups := List.filter(groups, func(g: Group) : Bool { g.id != groupId });
        groups := List.push(updatedGroup, groups);
        true
      };
    }
  };
}