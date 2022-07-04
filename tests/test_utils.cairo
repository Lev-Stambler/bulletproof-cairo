%builtins range_check bitwise
from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.cairo_builtins import BitwiseBuiltin
from src.byte_utils import felts_to_32_bit_word

func test_felts_to_32{range_check_ptr: felt, bitwise_ptr: BitwiseBuiltin*}(n: felt):
    alloc_locals
    local l: felt*
    %{
        import random
        random.seed(4132)
        ids.l = l = segments.add()
        ls_py = []
        for i in range(ids.n):
            r = random.randrange(0, PRIME)
            memory[l + i] = r
            ls_py.append(r)
    %}
    let (words: felt*) = felts_to_32_bit_word(l, n) 
    %{
        bs = bytes([])
        for e in ls_py:
            bs += e.to_bytes(8 * 4, 'little')
        for i in range(0, len(bs) // 4):
            words = ids.words
            py_word = int.from_bytes(bs[i*4:(i+1)*4], 'little')
            assert py_word == memory[words + i]
    %}
    
    return()
end


func main{range_check_ptr: felt, bitwise_ptr: BitwiseBuiltin*}():
    alloc_locals
    
    test_felts_to_32(6)
    return()
end
