  .data

    .org    0x00
input_address:   .word  0x80
output_address:  .word  0x84

    .text

    .org    0x88
_start:
    lit 0xFFFFFFFF           \ Кладём число -1 на вершину dataStack
    @p input_address         \ Кладём на вершину стека число n, поданное на вход по адресу 0x80

    +                        \ dataStack.push(n - 1), при этом n и -1 из стека убираются

    sum_word_pstream         \ Вызов процедуры (returnStack.push(pc)), после которой в dataStack будет hw и lw

    !p output_address        \ Отправляем значение lw с вершины dataStack по адресу вывода
    !p output_address        \ Отправляем значение hw с вершины dataStack по адресу вывода
end:
    halt                     \ Останов

sum_word_pstream:
    >r                       \ Убираем n-1 c вершины dataStack и кладём в returnStack
    lit 0x00                 \ Значение hw
    lit 0x00                 \ Значение lw

function_loop:
    @p input_address         \ Кладём на вершину стека число из массива поданных чисел
    +                        \ Складываем два числа из верхних ячеек стека и результат кладём на вершину стека (dataStack.push(dataStack.pop() + dataStack.pop()))
    >r                       \ Кладём значение lw временно на вершину returnStack

    lit 0x00                 \ Промежуточное значение для сложения с Carry flag
    >r

    lit 0x01               
    eam                      \ Включаем сложение с C флагом

    r>
    +                        \ Складываем значение hw с флагом С

    r>                       \ Возвращаем значение hw из returnStack на вершину dataStack

    next function_loop       \ R <- R - 1, pc <- function_loop (если R==0, то returnStack.pop())
    ;                        \ Возврат из процедуры