%builtins range_check bitwise
from src.innerproduct.innerproduct_2 import verify_innerproduct_2
from starkware.cairo.common.cairo_builtins import BitwiseBuiltin
from common_ec_cairo.ec.param_def import BASE, P0, P1, P2, N0, N1, N2, A0, A1, A2, GX0, GX1, GX2, GY0, GY1, GY2
from common_ec_cairo.ec.bigint import BigInt3
from common_ec_cairo.ec.ec import EcPoint
from src.structs import Transcript
from src.structs import TranscriptEntry
from src.structs import ProofInnerproduct2

# Return 1 if the proof is verified, otherwise return 0
func main{range_check_ptr, bitwise_ptr: BitwiseBuiltin*}():
    alloc_locals

    local transcript: Transcript*
    local proof_innerprod_2: ProofInnerproduct2
    local transcript_entries: TranscriptEntry*
    local gs: EcPoint*
    local hs: EcPoint*
    local u: EcPoint*
    local P: EcPoint*

    let prime = BigInt3(P0, P1, P2)
    # Set the global parameters (these should be 
    # made explicit to the verifier/ and or loaded by the verifier)
    %{
        import sys

        sys.path.insert(1, './python_bulletproofs')
        sys.path.insert(1, './python_bulletproofs/src')

        import os
        from random import randint
        from fastecdsa.curve import secp256k1, Curve

        from src.pippenger.group import EC
        from innerproduct.inner_product_prover import NIProver, FastNIProver2
        from innerproduct.inner_product_verifier import SUPERCURVE, Verifier1, Verifier2
        from utils.commitments import vector_commitment
        from utils.utils import ModP, mod_hash, inner_product, set_ec_points
        from utils.elliptic_curve_hash import elliptic_hash_secp256k1

        seeds = [os.urandom(10) for _ in range(6)]
        CURVE = SUPERCURVE

        # Have 3 rounds
        i = 3


        # TODO: the following will be loaded from a file
        p = SUPERCURVE.q
        N = 2 ** i
        g = [elliptic_hash_secp256k1(str(i).encode() + seeds[0], CURVE) for i in range(N)]
        h = [elliptic_hash_secp256k1(str(i).encode() + seeds[1], CURVE) for i in range(N)]
        u = elliptic_hash_secp256k1(seeds[2], CURVE)

        set_ec_points(ids, segments, memory, "u", [u])

        set_ec_points(ids, segments, memory, "gs", g)
        set_ec_points(ids, segments, memory, "hs", h)
    %}

    # Load the vector commitments and proof
    %{
        a = [mod_hash(str(i).encode() + seeds[3], p) for i in range(N)]
        b = [mod_hash(str(i).encode() + seeds[4], p) for i in range(N)]
        # TODO: set P
        P = vector_commitment(g, h, a, b) + inner_product(a, b) * u
        set_ec_points(ids, segments, memory, "P", [P])
    %}

    %{
        # Create and set the proof
        Prov = FastNIProver2(g, h, u, P, a, b, CURVE, prime=p)
        proof = Prov.prove() 
        # Convert the proof into a cairo format
        proof.convert_to_cairo(ids, memory, segments, len(g))
    %}

    verify_innerproduct_2(gs, hs, u[0], P[0], proof_innerprod_2, transcript, prime)


    return ()
end