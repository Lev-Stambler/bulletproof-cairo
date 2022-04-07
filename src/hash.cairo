from starkware.cairo.common.cairo_builtins import BitwiseBuiltin
from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.cairo_blake2s.blake2s import blake2s
from src.byte_utils import felts_to_32_bit_word
from starkware.cairo.common.serialize import serialize_word

func blake2s_hash_felts{output_ptr : felt*, bitwise_ptr : BitwiseBuiltin*, range_check_ptr, blake2s_ptr: felt*}(nums: felt*, n: felt) -> (output: felt):
    alloc_locals
    let (local words: felt *) = felts_to_32_bit_word{bitwise_ptr=bitwise_ptr, range_check_ptr=range_check_ptr}(nums, n)
    let (output: felt *) = blake2s{range_check_ptr=range_check_ptr, blake2s_ptr = blake2s_ptr}(words, n * 24)
    let (final_ret: felt) = _concact_output(0, output, 0)
    return (output = final_ret)
end

func _concact_output{output_ptr : felt*}(inp: felt, outputs: felt*, i: felt) -> (output: felt):
    if i == 8:
        return (output = inp)
    end
    let (r) = _concact_output(inp * 2 ** 32 + [outputs + i], outputs, i + 1)
    return (output = r)
end
