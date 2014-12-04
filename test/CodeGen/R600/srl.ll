;RUN: llc < %s -march=r600 -mcpu=redwood | FileCheck --check-prefix=EG-CHECK %s
;RUN: llc < %s -march=r600 -mcpu=verde -verify-machineinstrs | FileCheck --check-prefix=SI-CHECK %s

;EG-CHECK: {{^}}lshr_v2i32:
;EG-CHECK: LSHR {{\*? *}}T{{[0-9]+\.[XYZW], T[0-9]+\.[XYZW], T[0-9]+\.[XYZW]}}
;EG-CHECK: LSHR {{\*? *}}T{{[0-9]+\.[XYZW], T[0-9]+\.[XYZW], T[0-9]+\.[XYZW]}}

;SI-CHECK: {{^}}lshr_v2i32:
;SI-CHECK: v_lshr_b32_e32 v{{[0-9]+, v[0-9]+, v[0-9]+}}
;SI-CHECK: v_lshr_b32_e32 v{{[0-9]+, v[0-9]+, v[0-9]+}}

define void @lshr_v2i32(<2 x i32> addrspace(1)* %out, <2 x i32> addrspace(1)* %in) {
  %b_ptr = getelementptr <2 x i32> addrspace(1)* %in, i32 1
  %a = load <2 x i32> addrspace(1) * %in
  %b = load <2 x i32> addrspace(1) * %b_ptr
  %result = lshr <2 x i32> %a, %b
  store <2 x i32> %result, <2 x i32> addrspace(1)* %out
  ret void
}


;EG-CHECK: {{^}}lshr_v4i32:
;EG-CHECK: LSHR {{\*? *}}T{{[0-9]+\.[XYZW], T[0-9]+\.[XYZW], T[0-9]+\.[XYZW]}}
;EG-CHECK: LSHR {{\*? *}}T{{[0-9]+\.[XYZW], T[0-9]+\.[XYZW], T[0-9]+\.[XYZW]}}
;EG-CHECK: LSHR {{\*? *}}T{{[0-9]+\.[XYZW], T[0-9]+\.[XYZW], T[0-9]+\.[XYZW]}}
;EG-CHECK: LSHR {{\*? *}}T{{[0-9]+\.[XYZW], T[0-9]+\.[XYZW], T[0-9]+\.[XYZW]}}

;SI-CHECK: {{^}}lshr_v4i32:
;SI-CHECK: v_lshr_b32_e32 v{{[0-9]+, v[0-9]+, v[0-9]+}}
;SI-CHECK: v_lshr_b32_e32 v{{[0-9]+, v[0-9]+, v[0-9]+}}
;SI-CHECK: v_lshr_b32_e32 v{{[0-9]+, v[0-9]+, v[0-9]+}}
;SI-CHECK: v_lshr_b32_e32 v{{[0-9]+, v[0-9]+, v[0-9]+}}

define void @lshr_v4i32(<4 x i32> addrspace(1)* %out, <4 x i32> addrspace(1)* %in) {
  %b_ptr = getelementptr <4 x i32> addrspace(1)* %in, i32 1
  %a = load <4 x i32> addrspace(1) * %in
  %b = load <4 x i32> addrspace(1) * %b_ptr
  %result = lshr <4 x i32> %a, %b
  store <4 x i32> %result, <4 x i32> addrspace(1)* %out
  ret void
}

;EG-CHECK: {{^}}lshr_i64:
;EG-CHECK: SUB_INT {{\*? *}}[[COMPSH:T[0-9]+\.[XYZW]]], {{literal.[xy]}}, [[SHIFT:T[0-9]+\.[XYZW]]]
;EG-CHECK: LSHL {{\* *}}[[TEMP:T[0-9]+\.[XYZW]]], [[OPHI:T[0-9]+\.[XYZW]]], {{[[COMPSH]]|PV.[XYZW]}}
;EG-CHECK: LSHL {{\*? *}}[[OVERF:T[0-9]+\.[XYZW]]], {{[[TEMP]]|PV.[XYZW]}}, 1
;EG_CHECK-DAG: ADD_INT {{\*? *}}[[BIGSH:T[0-9]+\.[XYZW]]], [[SHIFT]], literal
;EG-CHECK-DAG: LSHR {{\*? *}}[[LOSMTMP:T[0-9]+\.[XYZW]]], [[OPLO:T[0-9]+\.[XYZW]]], [[SHIFT]]
;EG-CHECK-DAG: OR_INT {{\*? *}}[[LOSM:T[0-9]+\.[XYZW]]], {{[[LOSMTMP]]|PV.[XYZW]}}, {{[[OVERF]]|PV.[XYZW]}}
;EG-CHECK-DAG: LSHR {{\*? *}}[[HISM:T[0-9]+\.[XYZW]]], [[OPHI]], {{PS|[[SHIFT]]}}
;EG-CHECK-DAG: LSHR {{\*? *}}[[LOBIG:T[0-9]+\.[XYZW]]], [[OPHI]], {{PS|[[SHIFT]]}}
;EG-CHECK-DAG: SETGT_UINT {{\*? *}}[[RESC:T[0-9]+\.[XYZW]]], [[SHIFT]], literal
;EG-CHECK-DAG: CNDE_INT {{\*? *}}[[RESLO:T[0-9]+\.[XYZW]]], {{T[0-9]+\.[XYZW]}}
;EG-CHECK-DAG: CNDE_INT {{\*? *}}[[RESHI:T[0-9]+\.[XYZW]]], {{T[0-9]+\.[XYZW], .*}}, 0.0

;SI-CHECK: {{^}}lshr_i64:
;SI-CHECK: v_lshr_b64 {{v\[[0-9]+:[0-9]+\], v\[[0-9]+:[0-9]+\], v[0-9]+}}

define void @lshr_i64(i64 addrspace(1)* %out, i64 addrspace(1)* %in) {
  %b_ptr = getelementptr i64 addrspace(1)* %in, i64 1
  %a = load i64 addrspace(1) * %in
  %b = load i64 addrspace(1) * %b_ptr
  %result = lshr i64 %a, %b
  store i64 %result, i64 addrspace(1)* %out
  ret void
}

;EG-CHECK: {{^}}lshr_v2i64:
;EG-CHECK-DAG: SUB_INT {{\*? *}}[[COMPSHA:T[0-9]+\.[XYZW]]], {{literal.[xy]}}, [[SHA:T[0-9]+\.[XYZW]]]
;EG-CHECK-DAG: SUB_INT {{\*? *}}[[COMPSHB:T[0-9]+\.[XYZW]]], {{literal.[xy]}}, [[SHB:T[0-9]+\.[XYZW]]]
;EG-CHECK-DAG: LSHL {{\*? *}}[[COMPSHA]]
;EG-CHECK-DAG: LSHL {{\*? *}}[[COMPSHB]]
;EG-CHECK-DAG: LSHL {{.*}}, 1
;EG-CHECK-DAG: LSHL {{.*}}, 1
;EG-CHECK-DAG: LSHR {{.*}}, [[SHA]]
;EG-CHECK-DAG: LSHR {{.*}}, [[SHB]]
;EG-CHECK-DAG: LSHR {{.*}}, [[SHA]]
;EG-CHECK-DAG: LSHR {{.*}}, [[SHB]]
;EG-CHECK-DAG: OR_INT
;EG-CHECK-DAG: OR_INT
;EG-CHECK-DAG: ADD_INT  {{\*? *}}[[BIGSHA:T[0-9]+\.[XYZW]]]{{.*}}, literal
;EG-CHECK-DAG: ADD_INT  {{\*? *}}[[BIGSHB:T[0-9]+\.[XYZW]]]{{.*}}, literal
;EG-CHECK-DAG: LSHR
;EG-CHECK-DAG: LSHR
;EG-CHECK-DAG: SETGT_UINT {{\*? *T[0-9]\.[XYZW]}}, [[SHA]], literal
;EG-CHECK-DAG: SETGT_UINT {{\*? *T[0-9]\.[XYZW]}}, [[SHB]], literal
;EG-CHECK-DAG: CNDE_INT {{.*}}, 0.0
;EG-CHECK-DAG: CNDE_INT {{.*}}, 0.0
;EG-CHECK-DAG: CNDE_INT
;EG-CHECK-DAG: CNDE_INT

;SI-CHECK: {{^}}lshr_v2i64:
;SI-CHECK: v_lshr_b64 {{v\[[0-9]+:[0-9]+\], v\[[0-9]+:[0-9]+\], v[0-9]+}}
;SI-CHECK: v_lshr_b64 {{v\[[0-9]+:[0-9]+\], v\[[0-9]+:[0-9]+\], v[0-9]+}}

define void @lshr_v2i64(<2 x i64> addrspace(1)* %out, <2 x i64> addrspace(1)* %in) {
  %b_ptr = getelementptr <2 x i64> addrspace(1)* %in, i64 1
  %a = load <2 x i64> addrspace(1) * %in
  %b = load <2 x i64> addrspace(1) * %b_ptr
  %result = lshr <2 x i64> %a, %b
  store <2 x i64> %result, <2 x i64> addrspace(1)* %out
  ret void
}


;EG-CHECK: {{^}}lshr_v4i64:
;EG-CHECK-DAG: SUB_INT {{\*? *}}[[COMPSHA:T[0-9]+\.[XYZW]]], {{literal.[xy]}}, [[SHA:T[0-9]+\.[XYZW]]]
;EG-CHECK-DAG: SUB_INT {{\*? *}}[[COMPSHB:T[0-9]+\.[XYZW]]], {{literal.[xy]}}, [[SHB:T[0-9]+\.[XYZW]]]
;EG-CHECK-DAG: SUB_INT {{\*? *}}[[COMPSHC:T[0-9]+\.[XYZW]]], {{literal.[xy]}}, [[SHC:T[0-9]+\.[XYZW]]]
;EG-CHECK-DAG: SUB_INT {{\*? *}}[[COMPSHD:T[0-9]+\.[XYZW]]], {{literal.[xy]}}, [[SHD:T[0-9]+\.[XYZW]]]
;EG-CHECK-DAG: LSHL {{\*? *}}[[COMPSHA]]
;EG-CHECK-DAG: LSHL {{\*? *}}[[COMPSHB]]
;EG-CHECK-DAG: LSHL {{\*? *}}[[COMPSHC]]
;EG-CHECK-DAG: LSHL {{\*? *}}[[COMPSHD]]
;EG-CHECK-DAG: LSHL {{.*}}, 1
;EG-CHECK-DAG: LSHL {{.*}}, 1
;EG-CHECK-DAG: LSHL {{.*}}, 1
;EG-CHECK-DAG: LSHL {{.*}}, 1
;EG-CHECK-DAG: LSHR {{.*}}, [[SHA]]
;EG-CHECK-DAG: LSHR {{.*}}, [[SHB]]
;EG-CHECK-DAG: LSHR {{.*}}, [[SHC]]
;EG-CHECK-DAG: LSHR {{.*}}, [[SHD]]
;EG-CHECK-DAG: LSHR {{.*}}, [[SHA]]
;EG-CHECK-DAG: LSHR {{.*}}, [[SHB]]
;EG-CHECK-DAG: LSHR {{.*}}, [[SHC]]
;EG-CHECK-DAG: LSHR {{.*}}, [[SHD]]
;EG-CHECK-DAG: OR_INT
;EG-CHECK-DAG: OR_INT
;EG-CHECK-DAG: OR_INT
;EG-CHECK-DAG: OR_INT
;EG-CHECK-DAG: ADD_INT  {{\*? *}}[[BIGSHA:T[0-9]+\.[XYZW]]]{{.*}}, literal
;EG-CHECK-DAG: ADD_INT  {{\*? *}}[[BIGSHB:T[0-9]+\.[XYZW]]]{{.*}}, literal
;EG-CHECK-DAG: ADD_INT  {{\*? *}}[[BIGSHC:T[0-9]+\.[XYZW]]]{{.*}}, literal
;EG-CHECK-DAG: ADD_INT  {{\*? *}}[[BIGSHD:T[0-9]+\.[XYZW]]]{{.*}}, literal
;EG-CHECK-DAG: LSHR
;EG-CHECK-DAG: LSHR
;EG-CHECK-DAG: LSHR
;EG-CHECK-DAG: LSHR
;EG-CHECK-DAG: LSHR
;EG-CHECK-DAG: LSHR
;EG-CHECK-DAG: SETGT_UINT {{\*? *T[0-9]\.[XYZW]}}, [[SHA]], literal
;EG-CHECK-DAG: SETGT_UINT {{\*? *T[0-9]\.[XYZW]}}, [[SHB]], literal
;EG-CHECK-DAG: SETGT_UINT {{\*? *T[0-9]\.[XYZW]}}, [[SHC]], literal
;EG-CHECK-DAG: SETGT_UINT {{\*? *T[0-9]\.[XYZW]}}, [[SHD]], literal
;EG-CHECK-DAG: CNDE_INT {{.*}}, 0.0
;EG-CHECK-DAG: CNDE_INT {{.*}}, 0.0
;EG-CHECK-DAG: CNDE_INT {{.*}}, 0.0
;EG-CHECK-DAG: CNDE_INT {{.*}}, 0.0
;EG-CHECK-DAG: CNDE_INT
;EG-CHECK-DAG: CNDE_INT
;EG-CHECK-DAG: CNDE_INT
;EG-CHECK-DAG: CNDE_INT

;SI-CHECK: {{^}}lshr_v4i64:
;SI-CHECK: v_lshr_b64 {{v\[[0-9]+:[0-9]+\], v\[[0-9]+:[0-9]+\], v[0-9]+}}
;SI-CHECK: v_lshr_b64 {{v\[[0-9]+:[0-9]+\], v\[[0-9]+:[0-9]+\], v[0-9]+}}
;SI-CHECK: v_lshr_b64 {{v\[[0-9]+:[0-9]+\], v\[[0-9]+:[0-9]+\], v[0-9]+}}
;SI-CHECK: v_lshr_b64 {{v\[[0-9]+:[0-9]+\], v\[[0-9]+:[0-9]+\], v[0-9]+}}

define void @lshr_v4i64(<4 x i64> addrspace(1)* %out, <4 x i64> addrspace(1)* %in) {
  %b_ptr = getelementptr <4 x i64> addrspace(1)* %in, i64 1
  %a = load <4 x i64> addrspace(1) * %in
  %b = load <4 x i64> addrspace(1) * %b_ptr
  %result = lshr <4 x i64> %a, %b
  store <4 x i64> %result, <4 x i64> addrspace(1)* %out
  ret void
}
