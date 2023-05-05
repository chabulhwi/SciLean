import Lean

open Lean System IO 

register_option profile_file : Bool :=  {
  defValue := true
  group    := ""
  descr    := "Option to disable all #profile_file commands. This option is used when profiling so we do no start profiling while profiling."
}

def profileFile (file : FilePath) (flame : FilePath := "/home/tskrivan/Documents/Flame/build/bin/flame") : IO Unit := do

  let compile_output ← IO.Process.output {
    cmd := "lake"
    args := #["env", "lean", "-D", "trace.profiler=true", "-D", "pp.oneline=true", file.toString]
  }

  if compile_output.exitCode != 0 then
    throw (IO.Error.userError s!"Error: Failed to compile {file}\n\n{compile_output.stderr}")

  let flame_run ← Process.spawn {
    stdin := .piped
    stdout := .piped
    stderr := .piped
    cmd := flame.toString
    args := #[compile_output.stdout]
  }
  let (stdin, child) ← flame_run.takeStdin
  stdin.putStr compile_output.stdout
  stdin.flush
  let stdout ← IO.asTask child.stdout.readToEnd Task.Priority.dedicated
  let stderr ← child.stderr.readToEnd
  let exitCode ← child.wait
  let stdout ← IO.ofExcept stdout.get

  if exitCode != 0 then
    throw (IO.Error.userError s!"Error: Failed to run flame\n\n{stderr}")

  let speedscope_run ← Process.spawn {
    stdin := .piped
    stdout := .piped
    stderr := .piped
    cmd := "speedscope"
    args := #["-"]
  }
  let (stdin, child) ← speedscope_run.takeStdin
  stdin.putStr stdout
  stdin.flush
  let stdout ← IO.asTask child.stdout.readToEnd Task.Priority.dedicated
  let stderr ← child.stderr.readToEnd
  let exitCode ← child.wait
  let stdout ← IO.ofExcept stdout.get

  if exitCode != 0 then
    throw (IO.Error.userError s!"Error: Failed to run speedscope\n\n{stderr}")



elab " #profile_file " path:ident : command => do

  -- let doRun ← getBoolOption `profile_file

  -- if doRun then

    let file := (← IO.currentDir) / (path.getId.toString.replace "." FilePath.pathSeparator.toString ++ ".lean")
    profileFile file


elab " #profile_this_file " : command => do

  -- let doRun ← getBoolOption `profile_file

  -- if doRun then
    let ctx ← readThe Elab.Command.Context
    profileFile ctx.fileName
