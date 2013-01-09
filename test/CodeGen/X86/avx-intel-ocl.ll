; RUN: llc < %s -mtriple=i686-apple-darwin -mcpu=corei7-avx -mattr=+avx | FileCheck -check-prefix=X32 %s
; RUN: llc < %s -mtriple=i386-pc-win32 -mcpu=corei7-avx -mattr=+avx | FileCheck -check-prefix=X32 %s
; RUN: llc < %s -mtriple=x86_64-win32 -mcpu=corei7-avx -mattr=+avx | FileCheck -check-prefix=WIN64 %s
; RUN: llc < %s -mtriple=x86_64-apple-darwin -mcpu=corei7-avx -mattr=+avx | FileCheck -check-prefix=X64 %s

declare <16 x float> @func_float16_ptr(<16 x float>, <16 x float> *)
declare <16 x float> @func_float16(<16 x float>, <16 x float>)
declare i32 @func_int(i32, i32)

; WIN64: testf16_inp
; WIN64: vaddps  {{.*}}, {{%ymm[0-1]}}
; WIN64: vaddps  {{.*}}, {{%ymm[0-1]}}
; WIN64: leaq    {{.*}}(%rsp), %rcx
; WIN64: call
; WIN64: ret

; X32: testf16_inp
; X32: movl    %eax, (%esp)
; X32: vaddps  {{.*}}, {{%ymm[0-1]}}
; X32: vaddps  {{.*}}, {{%ymm[0-1]}}
; X32: call
; X32: ret

; X64: testf16_inp
; X64: vaddps  {{.*}}, {{%ymm[0-1]}}
; X64: vaddps  {{.*}}, {{%ymm[0-1]}}
; X64: leaq    {{.*}}(%rsp), %rdi
; X64: call
; X64: ret

;test calling conventions - input parameters
define <16 x float> @testf16_inp(<16 x float> %a, <16 x float> %b) nounwind {
  %y = alloca <16 x float>, align 16
  %x = fadd <16 x float> %a, %b
  %1 = call intel_ocl_bicc <16 x float> @func_float16_ptr(<16 x float> %x, <16 x float>* %y) 
  %2 = load <16 x float>* %y, align 16
  %3 = fadd <16 x float> %2, %1
  ret <16 x float> %3
}

;test calling conventions - preserved registers

; preserved ymm6-ymm15
; WIN64: testf16_regs
; WIN64: call
; WIN64: vaddps  {{%ymm[6-7]}}, %ymm0, %ymm0
; WIN64: vaddps  {{%ymm[6-7]}}, %ymm1, %ymm1
; WIN64: ret

; preserved ymm8-ymm15
; X64: testf16_regs
; X64: call
; X64: vaddps  {{%ymm[8-9]}}, %ymm0, %ymm0
; X64: vaddps  {{%ymm[8-9]}}, %ymm1, %ymm1
; X64: ret

define <16 x float> @testf16_regs(<16 x float> %a, <16 x float> %b) nounwind {
  %y = alloca <16 x float>, align 16
  %x = fadd <16 x float> %a, %b
  %1 = call intel_ocl_bicc <16 x float> @func_float16_ptr(<16 x float> %x, <16 x float>* %y) 
  %2 = load <16 x float>* %y, align 16
  %3 = fadd <16 x float> %1, %b
  %4 = fadd <16 x float> %2, %3
  ret <16 x float> %4
}

; test calling conventions - prolog and epilog
; WIN64: vmovaps {{%ymm([6-9]|1[0-5])}}, {{.*(%rsp).*}}     # 32-byte Spill
; WIN64: vmovaps {{%ymm([6-9]|1[0-5])}}, {{.*(%rsp).*}}     # 32-byte Spill
; WIN64: vmovaps {{%ymm([6-9]|1[0-5])}}, {{.*(%rsp).*}}     # 32-byte Spill
; WIN64: vmovaps {{%ymm([6-9]|1[0-5])}}, {{.*(%rsp).*}}     # 32-byte Spill
; WIN64: vmovaps {{%ymm([6-9]|1[0-5])}}, {{.*(%rsp).*}}     # 32-byte Spill
; WIN64: vmovaps {{%ymm([6-9]|1[0-5])}}, {{.*(%rsp).*}}     # 32-byte Spill
; WIN64: vmovaps {{%ymm([6-9]|1[0-5])}}, {{.*(%rsp).*}}     # 32-byte Spill
; WIN64: vmovaps {{%ymm([6-9]|1[0-5])}}, {{.*(%rsp).*}}     # 32-byte Spill
; WIN64: vmovaps {{%ymm([6-9]|1[0-5])}}, {{.*(%rsp).*}}     # 32-byte Spill
; WIN64: vmovaps {{%ymm([6-9]|1[0-5])}}, {{.*(%rsp).*}}     # 32-byte Spill
; WIN64: call
; WIN64: vmovaps {{.*(%rsp).*}}, {{%ymm([6-9]|1[0-5])}}     # 32-byte Reload
; WIN64: vmovaps {{.*(%rsp).*}}, {{%ymm([6-9]|1[0-5])}}     # 32-byte Reload
; WIN64: vmovaps {{.*(%rsp).*}}, {{%ymm([6-9]|1[0-5])}}     # 32-byte Reload
; WIN64: vmovaps {{.*(%rsp).*}}, {{%ymm([6-9]|1[0-5])}}     # 32-byte Reload
; WIN64: vmovaps {{.*(%rsp).*}}, {{%ymm([6-9]|1[0-5])}}     # 32-byte Reload
; WIN64: vmovaps {{.*(%rsp).*}}, {{%ymm([6-9]|1[0-5])}}     # 32-byte Reload
; WIN64: vmovaps {{.*(%rsp).*}}, {{%ymm([6-9]|1[0-5])}}     # 32-byte Reload
; WIN64: vmovaps {{.*(%rsp).*}}, {{%ymm([6-9]|1[0-5])}}     # 32-byte Reload
; WIN64: vmovaps {{.*(%rsp).*}}, {{%ymm([6-9]|1[0-5])}}     # 32-byte Reload
; WIN64: vmovaps {{.*(%rsp).*}}, {{%ymm([6-9]|1[0-5])}}     # 32-byte Reload

; X64: vmovups {{%ymm([8-9]|1[0-5])}}, {{.*}}(%rsp)  ## 32-byte Folded Spill
; X64: vmovups {{%ymm([8-9]|1[0-5])}}, {{.*}}(%rsp)  ## 32-byte Folded Spill
; X64: vmovups {{%ymm([8-9]|1[0-5])}}, {{.*}}(%rsp)  ## 32-byte Folded Spill
; X64: vmovups {{%ymm([8-9]|1[0-5])}}, {{.*}}(%rsp)  ## 32-byte Folded Spill
; X64: vmovups {{%ymm([8-9]|1[0-5])}}, {{.*}}(%rsp)  ## 32-byte Folded Spill
; X64: vmovups {{%ymm([8-9]|1[0-5])}}, {{.*}}(%rsp)  ## 32-byte Folded Spill
; X64: vmovups {{%ymm([8-9]|1[0-5])}}, {{.*}}(%rsp)  ## 32-byte Folded Spill
; X64: vmovups {{%ymm([8-9]|1[0-5])}}, {{.*}}(%rsp)  ## 32-byte Folded Spill
; X64: call
; X64: vmovups {{.*}}(%rsp), {{%ymm([8-9]|1[0-5])}} ## 32-byte Folded Reload
; X64: vmovups {{.*}}(%rsp), {{%ymm([8-9]|1[0-5])}} ## 32-byte Folded Reload
; X64: vmovups {{.*}}(%rsp), {{%ymm([8-9]|1[0-5])}} ## 32-byte Folded Reload
; X64: vmovups {{.*}}(%rsp), {{%ymm([8-9]|1[0-5])}} ## 32-byte Folded Reload
; X64: vmovups {{.*}}(%rsp), {{%ymm([8-9]|1[0-5])}} ## 32-byte Folded Reload
; X64: vmovups {{.*}}(%rsp), {{%ymm([8-9]|1[0-5])}} ## 32-byte Folded Reload
; X64: vmovups {{.*}}(%rsp), {{%ymm([8-9]|1[0-5])}} ## 32-byte Folded Reload
; X64: vmovups {{.*}}(%rsp), {{%ymm([8-9]|1[0-5])}} ## 32-byte Folded Reload
define intel_ocl_bicc <16 x float> @test_prolog_epilog(<16 x float> %a, <16 x float> %b) nounwind {
   %c = call <16 x float> @func_float16(<16 x float> %a, <16 x float> %b)
   ret <16 x float> %c
}

; test functions with integer parameters
; pass parameters on stack for 32-bit platform
; X32: movl {{.*}}, 4(%esp)
; X32: movl {{.*}}, (%esp)
; X32: call
; X32: addl {{.*}}, %eax

; pass parameters in registers for 64-bit platform
; X64: leal {{.*}}, %edi
; X64: movl {{.*}}, %esi
; X64: call
; X64: addl {{.*}}, %eax
define i32 @test_int(i32 %a, i32 %b) nounwind {
    %c1 = add i32 %a, %b
	%c2 = call intel_ocl_bicc i32 @func_int(i32 %c1, i32 %a)
    %c = add i32 %c2, %b
	ret i32 %c
}