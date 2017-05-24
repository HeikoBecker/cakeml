structure riscv_compileLib =
struct

open HolKernel boolLib bossLib

val _ = ParseExtras.temp_loose_equality()

open riscv_targetLib asmLib;
open backendComputeLib;
open configTheory

val cmp = wordsLib.words_compset ()
val () = computeLib.extend_compset
    [computeLib.Extenders
      [backendComputeLib.add_backend_compset
      ,riscv_targetLib.add_riscv_encode_compset
      ,asmLib.add_asm_compset
      ],
     computeLib.Defs
      [configTheory.riscv_compiler_config_def
      ,configTheory.riscv_names_def]
    ] cmp

val eval = computeLib.CBV_CONV cmp

end
