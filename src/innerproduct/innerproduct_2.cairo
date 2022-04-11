%builtins output range_check
from starkware.cairo.common.cairo_builtins import BitwiseBuiltin
from src.structs import Transcript, TranscriptEntry, ProofInnerproduct2
from src.math_utils import inverse_mod_p, variable_exponentiaition
from common_ec_cairo.ec.ec import EcPoint
from starkware.cairo.common.bitwise import bitwise_and 

# Return a 1 if the transcript was successfully verified
func verify_transcript_inner_product_2(transcript: Transcript*, i: felt)
    -> (success: felt):
    # TODO:... may have to have an inner function...
    return (success = 1)
end

func get_ssi{bitwise_ptr : BitwiseBuiltin*, range_check_ptr: felt*}(transcript: Transcript*, i: felt, j: felt, p: felt) ->
        (ssi: felt):

    alloc_locals

    # log_n and the number of "rounds" are the same
    let log_n = transcript.n_rounds

    if j == log_n:
        return (ssi = 1)
    end

    # A mask for the jth bit of a number at most 2 ** log_n - 1
    # the mask is just a 1 at the jth position
    let (mask) = variable_exponentiaition{range_check_ptr=range_check_ptr}(2, j)
    let (local b_i_j) = bitwise_and(i, mask)

    let (r) = get_ssi(transcript, i, j + 1, p)
    if b_i_j == 0:
        let (curr_mult) = inverse_mod_p(transcript.transcript_entries[j].x, p)
        return (ssi = r * curr_mult)
    else:
        let curr_mult = transcript.transcript_entries[j].x
        return (ssi = r * curr_mult)
    end
end

# As per page 15 of the paper
func get_ss{bitwise_ptr : BitwiseBuiltin*, range_check_ptr: felt*}(ss: felt*, n: felt, transcript: Transcript*, i: felt, p: felt):
    if i == n:
        return ()
    end
    let ssi = get_ssi(transcript, i, 0, p)
    assert [ss + i] = ssi
    return ()
end

# func get_final_g{bitwise_ptr : BitwiseBuiltin*, range_check_ptr}
#         (ss: felt*, n: felt, transcript: Transcript*, gs: EcPoint*, i: felt, p: felt) -> (g: EcPoint*):
#     if i == n:
          # Have identity element here
#         return ()
#     end
    
#     return ()
# end

# Return 0 if successful, otherwise return 1
func verify(gs: EcPoint*, hs: EcPoint*, u: EcPoint*, P: EcPoint*, proof: ProofInnerproduct2*, transcript: Transcript*) ->
        (success: felt):

    let (transcript_verified) = verify_transcript_inner_product_2(transcript, 0)

    # Fail if the transcript is not verified
    if transcript_verified == 0:
        return (success = 0)
    end



    return (success = 1)
end

# Return 1 if the proof is verified, otherwise return 0
func inner_product() -> (verified: felt):
    alloc_locals

    local transcript: Transcript*
    local proof_innerprod_2: ProofInnerproduct2*
    local transcript_entries: TranscriptEntry*
    %{
        import sys

        sys.path.insert(1, './python_bulletproofs')
        sys.path.insert(1, './python_bulletproofs/src')

        import os
        from random import randint
        from fastecdsa.curve import P224, Curve

        from src.pippenger.group import EC
        from innerproduct.inner_product_prover import NIProver, FastNIProver2
        from innerproduct.inner_product_verifier import SUPERCURVE, Verifier1, Verifier2
        from utils.commitments import vector_commitment
        from utils.utils import ModP, mod_hash, inner_product
        from utils.elliptic_curve_hash import elliptic_hash_P224        

        seeds = [os.urandom(10) for _ in range(6)]

        # TODO: the following will be loaded from a file
        p = SUPERCURVE.q
        N = 2 ** i
        g = [elliptic_hash_P224(str(i).encode() + seeds[0], CURVE) for i in range(N)]
        h = [elliptic_hash_P224(str(i).encode() + seeds[1], CURVE) for i in range(N)]
        u = elliptic_hash_P224(seeds[2], CURVE)
        a = [mod_hash(str(i).encode() + seeds[3], p) for i in range(N)]
        b = [mod_hash(str(i).encode() + seeds[4], p) for i in range(N)]
        P = vector_commitment(g, h, a, b) + inner_product(a, b) * u

        Prov = FastNIProver2(g, h, u, P, a, b, CURVE, prime=p)
        proof = Prov.prove() 

        # Convert the proof into a cairo format
        proof.convert_to_cairo(ids, memory, segments)
    %}


    return (verified = 1)
end