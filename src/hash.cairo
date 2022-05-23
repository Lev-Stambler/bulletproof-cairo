from starkware.cairo.common.cairo_builtins import BitwiseBuiltin
from starkware.cairo.common.alloc import alloc
from src.byte_utils import felts_to_32_bit_word
from starkware.cairo.common.serialize import serialize_word
from starkware.cairo.common.math import unsigned_div_rem
from src.math_utils import remainder, felt_to_bigint
from src.blake2s import blake2s
from common_ec_cairo.ec.bigint import BigInt3

# TODO: update to work with BigInt3s...
func blake2s_hash_felts{output_ptr : felt*, bitwise_ptr : BitwiseBuiltin*, range_check_ptr, blake2s_ptr: felt*}(nums: felt*, n: felt) -> (output: BigInt3):
    alloc_locals
    let (local words: felt *) = felts_to_32_bit_word{bitwise_ptr=bitwise_ptr, range_check_ptr=range_check_ptr}(nums, n)
    let (output_blake: felt *) = blake2s{range_check_ptr=range_check_ptr, blake2s_ptr = blake2s_ptr}(words, n * 32)
    let (final_ret: felt) = _concact_output{output_ptr=output_ptr, range_check_ptr=range_check_ptr}(0, output_blake, 0)

    let (output: BigInt3) = felt_to_bigint(final_ret)
    return (output = output)
end

func _concact_output{output_ptr : felt*, range_check_ptr}(inp: felt, outputs: felt*, i: felt) -> (output: felt):
    alloc_locals
    if i == 8:
        return (output = inp)
    end

    let shifted = inp * 2 ** 32

    let added = shifted + [outputs + i]
    let (output) = _concact_output(added, outputs, i + 1)
    return (output = output)
end
