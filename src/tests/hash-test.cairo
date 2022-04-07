%builtins output range_check bitwise

from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.cairo_blake2s.blake2s import INSTANCE_SIZE, blake2s, finalize_blake2s
from starkware.cairo.common.cairo_builtins import BitwiseBuiltin
from src.hash import blake2s_hash_felts


func test_run_blake2s_and_finalize{output_ptr: felt*, range_check_ptr, bitwise_ptr : BitwiseBuiltin*}():
    alloc_locals
    let (local blake2s_ptr_start) = alloc()
    let blake2s_ptr = blake2s_ptr_start
    let (felts) = alloc()

    assert [felts] = 123454321
    #assert [felts + 1] = 23454321
    #assert [felts + 2] = 3454321
    #assert [felts + 3] = 454321

    %{
        import sys

        sys.path.insert(1, './python_bulletproofs')
        sys.path.insert(1, './python_bulletproofs/src')
        from utils.utils import ModP, mod_hash, inner_product

        felts = [memory[ids.felts + i] for i in range(1)]
        print(felts)
        pythonret = mod_hash(felts, PRIME)
        print(felts, pythonret)
    %}

    let (hashed) = blake2s_hash_felts{
        output_ptr=output_ptr,
        bitwise_ptr=bitwise_ptr,
        range_check_ptr=range_check_ptr,
        blake2s_ptr=blake2s_ptr}(felts, 1)

    %{
        print("HASHED ID", ids.hashed)
        #assert(ModP(ids.hashed, PRIME) == pythonret)
    %}


    finalize_blake2s(blake2s_ptr_start=blake2s_ptr_start, blake2s_ptr_end=blake2s_ptr)
    return ()
end

func main{output_ptr: felt*, range_check_ptr: felt, bitwise_ptr: BitwiseBuiltin*}():
    alloc_locals
    
    test_run_blake2s_and_finalize()
    return()
end