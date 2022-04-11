%builtins output range_check bitwise

from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.cairo_blake2s.blake2s import INSTANCE_SIZE, blake2s, finalize_blake2s
from starkware.cairo.common.cairo_builtins import BitwiseBuiltin
from src.hash import blake2s_hash_felts
from src.constants import P224_Order


func test_run_blake2s_and_finalize{output_ptr: felt*, range_check_ptr, bitwise_ptr : BitwiseBuiltin*}():
    alloc_locals
    let (local blake2s_ptr_start) = alloc()
    let blake2s_ptr = blake2s_ptr_start
    let (felts) = alloc()

    assert [felts] = 123454321
    assert [felts + 1] = 23454321
    assert [felts + 2] = 3454321
    assert [felts + 3] = 454321

    %{
        import sys

        sys.path.insert(1, './python_bulletproofs')
        sys.path.insert(1, './python_bulletproofs/src')
        from utils.utils import ModP, mod_hash, inner_product
        from fastecdsa.curve import P224, Curve


        felts = [memory[ids.felts + i] for i in range(4)]
        pythonret = mod_hash(felts, P224.q, PRIME)
    %}

    let (hashed) = blake2s_hash_felts{
        output_ptr=output_ptr,
        bitwise_ptr=bitwise_ptr,
        range_check_ptr=range_check_ptr,
        blake2s_ptr=blake2s_ptr}(felts, 4, P224_Order)

    %{
        print(pythonret, ids.hashed)
        assert(ModP(ids.hashed, ids.P224_Order) == pythonret)
    %}


    finalize_blake2s(blake2s_ptr_start=blake2s_ptr_start, blake2s_ptr_end=blake2s_ptr)
    return ()
end

func main{output_ptr: felt*, range_check_ptr: felt, bitwise_ptr: BitwiseBuiltin*}():
    alloc_locals
    
    test_run_blake2s_and_finalize()
    return()
end