import SciLean

open SciLean

variable (a : Nat)

/--
info: let x := a + a;
a + (a + x) : ℕ
-/
#guard_msgs in
#check
  (a +
    (a +
    let x := a + a
    x))
  rewrite_by
    simp (config:={zeta:=false,singlePass:=true}) [Tactic.lift_lets_simproc]
