%option_i32 = type { i32, i8 }
%next_fn_type = type %option_i32 (ptr)*
%iter_vtable = type { i64, %next_fn_type }
%dyn_iter_inner = type opaque
%dyn_iter = type { %iter_vtable*, %dyn_iter_inner }
%procedure = type void (i32)*

%counter_iter = type { i32, i32 };
%vtabled_counter = type {%iter_vtable*, %counter_iter}
@COUNTER_VTABLE = global %iter_vtable { i64 8, ptr @counter_iter_next }

define %option_i32 @iter_dyn(%dyn_iter_inner*, %iter_vtable*) {
  %func.ptr = getelementptr inbounds %iter_vtable, ptr %1, i32 0, i32 1
  %func = load ptr, ptr %func.ptr
  %result = call %option_i32 (ptr) %func(ptr %0)
  
  ret %option_i32 %result
}

define %option_i32 @counter_iter_next(%counter_iter*) {
  %cur.ptr = getelementptr inbounds %counter_iter, ptr %0, i32 0, i32 0
  %cur = load i32, ptr %cur.ptr
  %max.ptr = getelementptr inbounds %counter_iter, ptr %0, i32 0, i32 1
  %max = load i32, ptr %max.ptr

  %cond = icmp eq i32 %cur, %max
  br i1 %cond, label %exhausted, label %incremented

  incremented:
    %succ = add i32 %cur, 1
    store i32 %succ, ptr %cur.ptr
    %return_val.0 = insertvalue %option_i32 poison, i32 %cur, 0
    %return_val.1 = insertvalue %option_i32 %return_val.0, i8 1, 1
    ret %option_i32 %return_val.1

  exhausted:
    ret %option_i32 { i32 0, i8 0 }
}

define void @for_each(%dyn_iter*, %procedure) {
  br label %header
  header:
    %vtable.ptr.ptr = getelementptr inbounds {ptr, i8}, ptr %0, i32 0, i32 0
    %vtable.ptr = load ptr, ptr %vtable.ptr.ptr
    %body.ptr = getelementptr inbounds {ptr, i8}, ptr %0, i32 0, i32 1
    %next = call %option_i32 (ptr, ptr) @iter_dyn(ptr %body.ptr, ptr %vtable.ptr)
    %next.ptr = alloca %option_i32
    store %option_i32 %next, ptr %next.ptr
    %tag.ptr = getelementptr inbounds %option_i32, ptr %next.ptr, i32 0, i32 1
    %tag = load i8, ptr %tag.ptr
    %is_some = icmp eq i8 %tag, 1
    br i1 %is_some, label %body, label %exit

  body:
    %val.ptr = getelementptr inbounds %option_i32, ptr %next.ptr, i32 0, i32 0
    %val = load i32, ptr %val.ptr
    call void (i32) %1 (i32 %val)
    br label %header
  exit:
    ret void
}

define void @print_i32(i32) {
  call i32 (i8*, ...) @printf(i8* getelementptr ([4 x i8], ptr @format_str, i32 0), i32 %0)
  ret void
}

define void @print_addr(ptr) {
  call i32 (i8*, ...) @printf(i8* getelementptr ([6 x i8], ptr @ptr_fmt, i32 0), ptr %0)
  ret void
}

define i32 @main() {
  %counter.0 = insertvalue %vtabled_counter poison, %iter_vtable* @COUNTER_VTABLE, 0
  %counter.inner1 = insertvalue %counter_iter poison, i32 0, 0
  %counter.inner2 = insertvalue %counter_iter %counter.inner1, i32 10, 1
  %counter.complete = insertvalue %vtabled_counter %counter.0, %counter_iter %counter.inner2, 1
  %counter_ptr = alloca {ptr, %counter_iter}, align 8
  store %vtabled_counter %counter.complete, ptr %counter_ptr
  call void (ptr, ptr) @for_each(ptr %counter_ptr, ptr @print_i32)
  
  ret i32 0
}

declare i32 @printf(i8*, ...)
@format_str = private constant [4 x i8] c"%d\0a\00", align 1
@ptr_fmt = private constant [6 x i8] c"0x%x\0a\00", align 1
