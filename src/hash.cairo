from starkware.cairo.common.cairo_builtins import BitwiseBuiltin
from starkware.cairo.common.alloc import alloc
from src.byte_utils import felts_to_32_bit_word
from src.q_field import uint256_to_mod_Q
from starkware.cairo.common.serialize import serialize_word
from starkware.cairo.common.math import unsigned_div_rem
from starkware.cairo.common.cairo_blake2s.blake2s import blake2s
from starkware.cairo.common.uint256 import Uint256

func blake2s_hash_felts{bitwise_ptr : BitwiseBuiltin*, range_check_ptr, blake2s_ptr: felt*}(nums: felt*, n: felt) -> (output: felt):
    alloc_locals
    %{
        l = [memory[ids.nums + i] for i in range(ids.n)]

        import sys
        sys.path.insert(1, './python_bulletproofs')
        sys.path.insert(1, './python_bulletproofs/src')

        from utils.transcript import Transcript, mod_hash
    %}
    let (local words: felt *) = felts_to_32_bit_word{bitwise_ptr=bitwise_ptr, range_check_ptr=range_check_ptr}(nums, n)
    let (output_blake: Uint256) = blake2s{range_check_ptr=range_check_ptr, blake2s_ptr = blake2s_ptr}(words, n * 32)
    let (output_felt: felt) = uint256_to_mod_Q(output_blake)
    return (output=output_felt)
end

# func _concact_output{range_check_ptr}(output_blake: Uint256) -> (output: felt):
#     alloc_locals
#     let shifted = output_blake.high * 2 ** 32

#     let added = shifted + [outputs + i]
#     let (output) = _concact_output(added, outputs, i + 1)
#     return (output = output)
# end
