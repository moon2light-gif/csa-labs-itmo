    .data
    .org 0x20                       ; С 0x00 по 0x1F будет храниться строка
input_addr:     .word 0x80
output_addr:    .word 0x84
buf_size:       .byte 0x20
string_end:     .byte 0x0A          ; Конец строки, представленный как '\n'


    .text
    .org 0x88
_start:
    lui t0, %hi(input_addr)         ; Загружаем в регистр t0 старшие 20 бит input_addr
    addi t0, t0, %lo(input_addr)    ; Теперь в t0 адрес, по которому расположено значение 0x80
    lw t0, 0(t0)                    ; Загружаем в t0: M[0 + t0] = 0x80

    lui t1, %hi(output_addr)
    addi t1, t1, %lo(output_addr)
    lw t1, 0(t1)                    ; Теперь в регистре t1 лежит значение адреса выхода: 0x84

    ; s1 -- '\n'
    ; s2 -- хранит адреса для обхода накопленного массива букв
    ; t0 -- адрес ячейки ввода 0x80
    ; t1 -- адрес ячейки вывода 0x84
    ; t3 -- хранит букву на каждом этапе

    ; Вызов функции reverse_string_pstr

end:
    halt

reverse_string_pstr:
    lb s1, 0(string_end)            ; Загружаем в регистр s1 значение M[0 + string_end] - 0x0A
    mv t4, zero                     ; Копируем значение 0x00 в регистр t4 (t4 будет нужен для обхода массива накопленных букв)
    
    ; вызываем read_line
    jal ra, read_line

    sb t4, 0(t1)                    ; Сначала выводим значение счётчика 

    ; вызываем reverse_process
    
    ; Метод, который вызывает метод read_line, потом результат метода переворачивает и вызывается в _start

word_end:  
    ; Тут печатаем знаки '_' до того момента, пока длина строки не станет 0x20

read_line:
    lb t3, 0(t0)                        ; Загружаем в регистр t3 значение в M[0+t0] (одна буква со входа)
    beq t3, s1, exit_read_line        ; Если значение в t3 равно '\n', переходим к reverse_process
    sb t3, 0(t4)                        ; Сохраняем прочитанную букву в M[t4]
    addi t4, t4, 1                      

    j read_line

exit_read_line:
    jr <rs>                             ; pc <- значение регистра

reverse_process:
    beqz t4, exit_reverse_process
    addi t4, t4, -1

    lb t3, 0(t4)                       ; Загружаем в регистр t3 значение M[0+t4]
    sb t3, 0(t1)                       ; Сохраняем значение t3 в M[0x84+0]
    
    j while

exit_reverse_process:
    ret










