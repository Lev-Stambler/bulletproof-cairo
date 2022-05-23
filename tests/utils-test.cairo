%builtins output range_check bitwise
from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.cairo_builtins import BitwiseBuiltin
from src.byte_utils import felt_to_32_bit_word, felts_to_32_bit_word

func test_felt_to_32{output_ptr : felt*, range_check_ptr: felt, bitwise_ptr: BitwiseBuiltin*}():
    alloc_locals
    
    # TODO: add tests
    
    return()
end

func test_felts_to_bytes{output_ptr : felt*, range_check_ptr: felt, bitwise_ptr: BitwiseBuiltin*}():
    alloc_locals
    # TODO: add tests
    return()
end


func main{output_ptr : felt*, range_check_ptr: felt, bitwise_ptr: BitwiseBuiltin*}():
    alloc_locals
    
    test_felts_to_bytes()
    return()
end