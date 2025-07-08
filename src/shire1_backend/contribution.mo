import Principal "mo:base/Principal";
import Text "mo:base/Text";
import Nat "mo:base/Nat";
import Time "mo:base/Time";
import List "mo:base/List";

actor {
  type Contribution = {
    groupId: Nat;
    payer: Principal;
    amount: Nat;
    timestamp: Time.Time;
    proofHash: ?Text; // IPFS hash for payment proof
  };

  private stable var contributions: List.List<Contribution> = List.nil();

  public shared ({caller}) func recordContribution(groupId: Nat, amount: Nat, proofHash: ?Text) : async () {
    let contribution = {
      groupId = groupId;
      payer = caller;
      amount = amount;
      timestamp = Time.now();
      proofHash = proofHash;
    };
    contributions := List.push(contribution, contributions);
  };

  public query func getContributions(groupId: Nat) : async [Contribution] {
    let groupContributions = List.filter(contributions, func(c: Contribution) : Bool { c.groupId == groupId });
    List.toArray(groupContributions)
  };
}