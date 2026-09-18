    .data
    
    .org 0x00
input_address:  .word 0x80
output_address: .word 0x84
n:              .word 0x00
k:              .word 0x00


    .text
    .org    0x88

_start:

    lit     0xFFFFFFFF           \ Кладем на вершину datastack
    !p      n              \ Кладем то, что в datastack в n
    @p      0x09
    !p      k

end:
    halt


