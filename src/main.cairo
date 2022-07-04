%lang starknet
%builtins pedersen range_check
from starkware.cairo.common.math import assert_nn
from starkware.cairo.common.cairo_builtins import HashBuiltin

@constructor
func constructor{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    return ()
end
