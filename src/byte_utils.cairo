from starkware.cairo.common.cairo_builtins import BitwiseBuiltin
from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.bitwise import bitwise_and, bitwise_not
from starkware.cairo.common.math_cmp import is_le_felt

# Returns 24 bytes, little endian, representing the input felt
func felt_to_bytes{bitwise_ptr : BitwiseBuiltin*, range_check_ptr}(
    input: felt
) -> (output: felt*):
    let (ptr) = alloc()

    let (ptr) = _felt_to_bytes(input, ptr, 0)
    return (output = ptr)
end

func _felt_to_bytes{bitwise_ptr : BitwiseBuiltin*, range_check_ptr}(
    input: felt,
    output: felt*,
    i: felt
) -> (output: felt*):
    alloc_locals
    if i == 24:
        return (output = output)
    end

    let (anded) = bitwise_and{bitwise_ptr=bitwise_ptr}(input, 255)
    assert [output + i] = anded
    let (local lt) = is_le_felt{range_check_ptr=range_check_ptr}(2 ** 8, input)
    if lt == 1:
        # TODO: this is not how bit shift works...
        # TODO: sep shift fn
        # This can be a constant
        let (mask) = bitwise_not(255)
        let (masked) = bitwise_and(mask, input)
        let new_input = masked / 2 ** 8
        let (output) = _felt_to_bytes{bitwise_ptr=bitwise_ptr, range_check_ptr=range_check_ptr}(new_input, output, i + 1)
        return (output = output)
    else:
        let (output) = _felt_to_bytes(0, output, i + 1)
        return (output = output)
    end 
end