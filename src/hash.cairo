from starkware.cairo.common.cairo_builtins import BitwiseBuiltin
from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.cairo_blake2s.blake2s import blake2s
from src.byte_utils import felts_to_bytes

# Returns 8 32-bit felt pointers (little endian... hmmm need to think about)
func blake_hash_felts{bitwise_ptr : BitwiseBuiltin*, range_check_ptr, blake2s_ptr: felt*}(nums: felt*, n: felt) -> (output: felt*):
    alloc_locals
    let (local bytes: felt *) = felts_to_bytes{bitwise_ptr=bitwise_ptr, range_check_ptr=range_check_ptr}(nums, n)
    let (output: felt *) = blake2s{range_check_ptr=range_check_ptr, blake2s_ptr = blake2s_ptr}(bytes, n * 24)
    return (output = output)
end
