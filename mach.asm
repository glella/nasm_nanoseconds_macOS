; ----------------------------------------------------------------------------------------
; Testing mach_absolute_time
; nasm -fmacho64 mach.asm && gcc timebase.c -o mach mach.o
; ----------------------------------------------------------------------------------------

    global      _main
    extern      _printf
    extern      _mach_absolute_time
    extern      _timebase
    extern      _nanosleep
    default     rel

section .text

_main: 
    push        rbx                     ; aligns the stack x C calls

    ; start measurement
    call        _mach_absolute_time     ; get the absolute time hardware dependant
    mov         [start], rax            ; save start in start
    ; print start
    lea         rdi, [time_absolute]
    mov         rsi, rax
    call        _printf

    ; do some time intensive stuff - This simulates 1 sec work
    lea         rdi, [timeval]
    call        _nanosleep

    ; end measurement 
    call        _mach_absolute_time
    mov         [end], rax
    ; print end
    lea         rdi, [time_absolute]
    mov         rsi, rax
    call        _printf

    ; calc elapsed
    mov         r10d, [end]
    mov         r11d, [start]
    sub         r10d, r11d              ; r10d = end - start
    mov         [diff], r10d            ; copy to diff
    mov         rax, [diff]             ; diff to rax to print as int 

    ; print elapsed
    lea         rdi, [diff_absolute]
    mov         rsi, [diff]
    call        _printf

    ; get conversion ratio from C function
    call        _timebase               ; get conversion ratio to nanoseconds into xmm0    
    cvtsi2sd    xmm1, [diff]            ; load diff from mach_absolute time in [diff]
                                        ; if you do it before register gets cleared
    ; calc nanoseconds - xmm0 ends with nanoseconds
    ; in my hardware ratio is 1.0 so mach_absolute_time diff = nanoseconds
    mulsd       xmm0, xmm1              ; ratio * diff -> xmm0
    cvtsd2si    rax, xmm0               ; convert float to int
    mov         [result], rax           ; save to result

    ; print nanoseconds as int
    lea         rdi, [nanosecs_calc]
    mov         rsi, [result]
    call        _printf
    
    pop         rbx                     ; undoes the stack alignment push
    ret

section .data

; lazy way to set up 1 sec wait
timeval:
    tv_sec      dq 1
    tv_usec     dq 0

time_absolute:  db "mach_absoute_time: %ld", 10, 0
diff_absolute:  db "absoute_time diff: %ld", 10, 0
nanosecs_calc:  db "nanoseconds:       %ld", 10, 0

; should use registers but for clarity
start:          dq 0
end:            dq 0
diff:           dq 0
result:         dq 0
