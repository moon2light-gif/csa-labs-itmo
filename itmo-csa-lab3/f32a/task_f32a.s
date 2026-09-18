   .text
    .org 0x88
_start:
    lit 0xFFFFFFFF           \ Кладём число -1 на вершину dataStack
    @p 0x80                  \ Кладём на вершину стека число n, поданное на вход по адресу 0x80

    dup                     
    if zero_args             

    +                        \ dataStack.push(n - 1), при этом n и -1 из стека убираются

    sum_word_pstream         \ Вызов процедуры (returnStack.push(pc)), после которой в dataStack будет hw и lw

    \ К концу выполнения процедуры dataStack будет содержать следующее: hw -> lw 

    >r                       \ Отправляем значение lw -> на вершину returnStack
    !p 0x84                  \ Отправляем значение hw с вершины dataStack по адресу вывода
    r>                       \ lw с вершины returnStack -> вершина dataStack
    !p 0x84                  \ Отправляем значение lw с вершины dataStack по адресу вывода

end:
    halt                     \ Останов

zero_args:
    lit 0x00
    lit 0x00 
    !p 0x84
    !p 0x84 
    halt                     \ Останов

sum_word_pstream:
    >r                       \ Убираем n-1 c вершины dataStack и кладём в returnStack
    lit 0x00                 \ Значение hw -> на вершину dataStack
    lit 0x00                 \ Значение lw -> на вершину dataStack

    lit 0x01
    eam                      \ Включаем сложение с C флагом

function_loop:
    @p 0x80                  \ Кладём на вершину стека число из массива поданных 32-битных чисел
    dup                      \ Делаем дубликат числа, добавляя его на вершину dataStack
    -if positive_num         \ Если поданное число >=0 - переходим к метке (при этом убирается число с вершины dataStack)
    lit 0xFFFFFFFF           \ Иначе - число отрицательное, значит расширяем его 'hw' единицами
    main_process ;           \ Прыжок к метке

positive_num:
    lit 0x00                 \ Расширяем знак нулями

main_process:
    a!                       \ Сохраняем расширение знака поданного числа в регистр A
    >r                       \ Поданное число -> на вершину returnStack
    >r                       \ lw -> на вершину returnStack

    a                        \ Возвращаем на вершину dataStack расширение знака числа (прямо над hw)
    r>                       \ Возвращаем на вершину dataStack lw
    r>                       \ Возвращаем на вершину dataStack 32-битное число

    +                        \ Складываем 32-битное число и lw, результат -> вершина dataStack (EAM == 1)
    a!                       \ Кладём значение новое lw временно в регистр A (не сбрасывает Carry flag)

    +                        \ Складываем значение hw с расширением знака поданного числа, используя флаг С
    a                        \ Возвращаем значение lw из регистра A на вершину dataStack

    next function_loop       \ R <- R - 1, pc <- function_loop (если R==0, то returnStack.pop())
    ;                        \ Возврат из процедуры