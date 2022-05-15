import SciLean.Mechanics
import SciLean.Operators.ODE
import SciLean.Solver 
import SciLean.Tactic.LiftLimit
import SciLean.Tactic.FinishImpl
import SciLean.Data.PowType
import SciLean.Core.Extra
import SciLean.Functions

open SciLean

set_option synthInstance.maxSize 2048
set_option synthInstance.maxHeartbeats 500000
set_option maxHeartbeats 500000

def LennardJones (ε minEnergy : ℝ) (radius : ℝ) (x : ℝ^(3:ℕ)) : ℝ :=
  let x' := ∥1/radius * x∥^{-6, ε}
  4 * minEnergy * x' * (x' - 1)
argument x [Fact (ε≠0)]
  isSmooth, diff, hasAdjDiff, adjDiff

def Coloumb (ε strength mass : ℝ) (x : ℝ^(3:ℕ)) : ℝ := - strength * mass * ∥x∥^{-1,ε}
-- argument mass
--   isSmooth, diff, hasAdjDiff, adjDiff
argument x [Fact (ε≠0)]
  isSmooth, diff, hasAdjDiff, adjDiff

set_option trace.Meta.Tactic.simp.rewrite true in 
example (n : ℕ) [Fact (n≠0)] 
  : (δ† λ (x : (ℝ^(3:ℕ))^n) (i j : Idx n) => x[j]) 
    =
    λ x dx' => PowType.intro (∑ j, dx' j) := 
by
  simp; done

-- SciLean.diag.arg_x_i_j.adjDiff_simp, failed to synthesize instance SciLean.IsSmooth (Coloumb ε C)

-- @[simp low-2]
-- theorem hoho
--   {X Y Z : Type} [SemiHilbert X] [SemiHilbert Y] [SemiHilbert Z] 
--   {ι κ : Type} [Enumtype ι] [Enumtype κ] [Nonempty ι] [Nonempty κ]
--   (f : X → ι → κ → Y →  Z) [IsSmooth f]
--   [∀ y, HasAdjDiff λ x i j => f x i j y]
--   [∀ x, HasAdjDiff λ y i j => f x i j y]
--   (g : X → ι → κ → Y) [HasAdjDiff g]
--   : δ† (λ x i j => f x i j (g x i j) )
--     = 
--     λ x dx' => 
--       (δ† (hold λ x' i j => f x' i j (g x i j)) x dx')
--       +
--       (δ† g x) (λ i j => (δ† (λ y => f x i j y) (g x i j) (dx' i j)))
-- := by 
--   funext x dx';
--   -- conv => 
--   --   lhs
--   --   simp
--   --   -- rw[subst.arg_x.adjDiff_simp]
--   -- simp [sum_of_linear, sum_into_lambda, sum_of_add]
--   admit


set_option trace.Meta.Tactic.simp.rewrite true in 
-- set_option trace.Meta.Tactic.simp.discharge true in 
def H (n : ℕ) (ε : ℝ) (C LJ : ℝ) (r m : Idx n → ℝ) (x p : (ℝ^(3:ℕ))^n) : ℝ :=
  ∑ i j, Coloumb ε C (m i * m j) (x[i] - x[j])
         +
         LennardJones ε LJ (r i + r j) (x[i] - x[j])
-- argument p [Fact (n≠0)] [Fact (ε≠0)]
--   isSmooth, diff, hasAdjDiff, adjDiff
argument x [Fact (n≠0)] [Fact (ε≠0)]
  -- isSmooth, diff, hasAdjDiff, 
  adjDiff by
    simp[H]; unfold hold; simp
    simp [sum_into_lambda]
    simp [← sum_of_add]
    
-- def H (n : Nat) (ε : ℝ) (m : Idx n → ℝ) (x p : ((ℝ^(3:Nat))^n)) : ℝ := 
--   (∑ i, (1/(2*m i)) * ∥p[i]∥²)
--   +
--   (∑ i j, (m i*m j) * ∥x[i] - x[j]∥^{(-1:ℝ),ε})
-- argument p [Fact (ε≠0)] [Fact (n≠0)]
--   isSmooth, hasAdjDiff, adjDiff
-- argument x [Fact (ε≠0)] [Fact (n≠0)]
--   isSmooth, hasAdjDiff,
--   adjDiff by
--     simp[H]
--     simp [sum_into_lambda]
--     simp [← sum_of_add]
    
-- def solver (steps : ℕ) (n : Nat) [Fact (n≠0)] (ε : ℝ) [Fact (ε≠0)] (m : Idx n → ℝ)
--   : Impl (ode_solve (HamiltonianSystem (H n ε m))) :=
-- by
--   -- Unfold Hamiltonian definition and compute gradients
--   simp[HamiltonianSystem]
  
--   -- Apply RK4 method
--   rw [ode_solve_fixed_dt runge_kutta4_step]
--   lift_limit steps "Number of ODE solver steps."; admit; simp
   
--   finish_impl