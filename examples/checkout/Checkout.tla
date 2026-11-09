---- MODULE Checkout ----
\* A checkout page. Pressing "Pay" sends a request. The server handles it in
\* two steps, like many real handlers do:
\*   1. load the order and check it is still unpaid;
\*   2. charge the card and mark the order paid.
\* Two requests (a double-click, or a retry) can interleave between 1 and 2.
EXTENDS Naturals

Requests == {1, 2}

VARIABLES
  order,    \* "unpaid" | "paid" | "failed"
  charges,  \* how many times the card was charged
  req       \* each request: "idle" | "checked" (passed step 1) | "done"

vars == <<order, charges, req>>

Init ==
  /\ order = "unpaid"
  /\ charges = 0
  /\ req = [r \in Requests |-> "idle"]

\* Step 1: the request loads the order and sees that it is unpaid.
YouPressPay(r) ==
  /\ req[r] = "idle"
  /\ order = "unpaid"
  /\ req' = [req EXCEPT ![r] = "checked"]
  /\ UNCHANGED <<order, charges>>

\* Step 2: charge the card. It does not look at the order again.
ChargeSucceeds(r) ==
  /\ req[r] = "checked"
  /\ charges' = charges + 1
  /\ order' = "paid"
  /\ req' = [req EXCEPT ![r] = "done"]

ChargeFails(r) ==
  /\ req[r] = "checked"
  /\ order' = IF order = "paid" THEN "paid" ELSE "failed"
  /\ req' = [req EXCEPT ![r] = "done"]
  /\ UNCHANGED charges

\* After a failed charge, the page lets you try again.
YouTryAgain ==
  /\ order = "failed"
  /\ order' = "unpaid"
  /\ req' = [r \in Requests |-> IF req[r] = "done" THEN "idle" ELSE req[r]]
  /\ UNCHANGED charges

\* Nothing left to do: the order is paid, or both requests are used up.
Done ==
  /\ \A r \in Requests : req[r] # "checked"
  /\ order # "failed"
  /\ \/ order = "paid"
     \/ \A r \in Requests : req[r] = "done"
  /\ UNCHANGED vars

Next ==
  \/ \E r \in Requests : YouPressPay(r)
  \/ \E r \in Requests : ChargeSucceeds(r)
  \/ \E r \in Requests : ChargeFails(r)
  \/ YouTryAgain
  \/ Done

Spec == Init /\ [][Next]_vars

\* ---- Rules ----

\* The card is never charged more than once for one order.
ChargedAtMostOnce == charges <= 1

\* A paid order was charged.
PaidMeansCharged == order = "paid" => charges >= 1
====
