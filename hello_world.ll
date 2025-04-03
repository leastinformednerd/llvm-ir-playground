@format = private constant [4 x i8] c"%d\0a\00", align 1

define i32 @main() {
  start:
    br label %header

  header:
    %cur = phi i32 [10, %start], [%prev, %loop] 
    %_ = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @format, i32 0, i32 0), i32 %cur)
    br label %loop
    
  loop:
    %prev = sub i32 %cur, 1
    %cond = icmp eq i32 %prev, 0
    br i1 %cond, label %exit, label %header

  exit:
    ret i32 %cur
}

declare i32 @printf(i8*, ...)
