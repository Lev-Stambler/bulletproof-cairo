%builtins output range_check
# %builtins range_check_ptr
from starkware.cairo.common.serialize import serialize_word
from starkware.cairo.common.alloc import alloc
from src.vector_utils import elem_wise_prod, multi_exp
from src.innerproduct.verifier_innerproduct_2 import verify as verify_innerproduct_2
from src.structs import TranscriptEntry

func array_sum(arr: felt*, size) -> (sum):
    if size == 0:
        return (sum = 0)
    end
    let (sum_of_rest) = array_sum(arr = arr + 1, size = size - 1)
    return (sum=[arr] + sum_of_rest)
end

func array_prod(arr: felt*, size) -> (prod):
    if size == 0:
        return (prod = 1)
    end
    let (prod_rest) = array_prod(arr = arr + 1, size = size - 1)
    return (prod=[arr] * prod_rest)
end

func check_inner_product{output_ptr : felt*}(
    g: felt*,
    h: felt*,
    n: felt,
    P: felt,
    c: felt
):
    return()
end

func main{output_ptr : felt*, range_check_ptr: felt}(
):
    alloc_locals
    local transcript_entries: TranscriptEntry*
    local transcript_seed: felt
    local n_transcript_entries: felt
    %{
        import sys

        sys.path.insert(1, './python_bulletproofs')
        sys.path.insert(1, './python_bulletproofs/src')

        from utils.transcript import Transcript
        from utils.elliptic_curve_hash import elliptic_hash
        from utils.utils import ModP, mod_hash, inner_product
        from fastecdsa.curve import secp256k1, Curve

        CURVE: Curve = secp256k1
        L1 = elliptic_hash(str("AAAA").encode(), CURVE)
        R1 = elliptic_hash(str("BBBB").encode(), CURVE)
        x = ModP(69, 100)

        transcript = Transcript()
        transcript.add_point(L1)
        transcript.add_point(R1)
        transcript.add_number(x)
        Transcript.convert_to_cairo(ids, memory, segments, transcript.digest)
    %}
    serialize_word([transcript_entries].x)
    let (v1: felt*) = alloc()
    let (v2: felt*) = alloc()
    let (e1: felt*) = alloc()
    assert [e1] = 1
    assert [e1 + 1] = 0
    assert [e1 + 2] = 0
    assert [v1] = 10
    assert [v1 + 1] = 11
    assert [v1 + 2] = 12
    assert [v2] = 10
    assert [v2 + 1] = 11
    assert [v2 + 2] = 12
    let (x) = multi_exp{range_check_ptr = range_check_ptr}(v1, e1, 3)
    let (r: felt*) = elem_wise_prod(v1, v2, 3)
    return()
end

# > Understanding how to set Cairo's input from a JSON. 
# > Understanding field elements and their relationship to things
# > Multiexponentiation function... may not 
# > Hadamard (element wise) product
# > Initializing transcript and building up (probs a struct with a constant size array and changing n)
# > Computing transcript hash
# > Actual functionallity
# > 
# > let's start with Pederson commitment functions