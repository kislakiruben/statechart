// How the chart names states and arrows: in the shopper's words, not the
// variable names. `v` holds the model's variables; a TLA+ function such as
// `req` arrives as an object with keys 1 and 2.

type V = { order: string; charges: number; req: Record<string, string> };

export const title = "Checkout: pressing Pay";

const inFlight = (v: V) => Object.values(v.req).filter((s) => s === "checked").length;

export const state = (v: V) => {
  if (v.order === "paid") return v.charges > 1 ? "Paid, charged twice" : "Paid";
  const n = inFlight(v);
  if (v.order === "failed") return n ? "Payment failed, other request still paying" : "Payment failed";
  if (n === 0) return "Unpaid";
  return n === 1 ? "Paying" : "Paying (two requests)";
};

export const group = (v: V) => (v.order === "paid" ? "done" : v.order === "failed" ? "problem" : "paying");

export const colors = { paying: "blue", done: "teal", problem: "orange" };

export const step = (action: string) =>
  ({
    YouPressPay: "you press Pay",
    ChargeSucceeds: "the charge goes through",
    ChargeFails: "the charge fails",
    YouTryAgain: "you try again",
    Done: null, // the end state stays put; no arrow needed
  })[action] ?? action;
