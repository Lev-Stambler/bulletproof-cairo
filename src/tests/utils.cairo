%builtins output range_check bitwise
from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.serialize import serialize_word
from starkware.cairo.common.cairo_builtins import BitwiseBuiltin
from src.byte_utils import felt_to_bytes, felts_to_bytes

# TODO: actually run
func test_felt_to_bytes{output_ptr : felt*, range_check_ptr: felt, bitwise_ptr: BitwiseBuiltin*}():
    alloc_locals
    let f = 123456
    let (outp) = felt_to_bytes(f)
    assert [outp] = 64
    assert [outp + 1] = 226
    assert [outp + 2] = 1
    assert [outp + 3] = 0
    assert [outp + 4] = 0
    return()
end

func test_felts_to_bytes{output_ptr : felt*, range_check_ptr: felt, bitwise_ptr: BitwiseBuiltin*}():
    alloc_locals
    let (inp) = alloc()
    assert [inp] = 123456
    assert [inp + 1] = 22222

    let (outp) = felts_to_bytes(inp, 2)
    assert [outp] = 64
    assert [outp + 1] = 226
    assert [outp + 2] = 1
    assert [outp + 3] = 0
    assert [outp + 4] = 0

    assert [outp + 24] = 206
    assert [outp + 24 + 1] = 86
    assert [outp + 24 + 2] = 0
    return()
end


func main{output_ptr : felt*, range_check_ptr: felt, bitwise_ptr: BitwiseBuiltin*}():
    alloc_locals
    
    test_felts_to_bytes()
    return()
end