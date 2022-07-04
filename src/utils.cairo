%builtins range_check bitwise
from src.cairo_blake2s.blake2s import INSTANCE_SIZE, blake2s, finalize_blake2s

# Take in an array of felt items and break them up each felt into 32 little endian bytes
# Then, feed the bytes into blake2s
func blake_2_mod_felt_p{range_check_ptr, blake2s_ptr: felt*}(inputs: felt*, n_items: felt) -> (output: felt):
    # Break 
    return (output = 0)
end
