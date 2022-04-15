from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.cairo_builtins import BitwiseBuiltin
from src.structs import Transcript, TranscriptEntry, ProofInnerproduct2
from src.math_utils import inverse_mod_p, variable_exponentiaition_felts, felt_to_bigint, mult_bigint, multi_exp, check_ec_equal
from common_ec_cairo.ec.ec import EcPoint, ec_mul, ec_add
from common_ec_cairo.ec.bigint import BigInt3
from starkware.cairo.common.bitwise import bitwise_and 

# Return a 1 if the transcript was successfully verified
func verify_transcript_inner_product_2(transcript: Transcript*, i: felt)
    -> (success: felt):
    # TODO:... may have to have an inner function...
    # TODO: verify n rounds = log n
    return (success = 1)
end

func get_ssi{bitwise_ptr : BitwiseBuiltin*, range_check_ptr}(transcript: Transcript*, i: felt, j: felt, p: BigInt3) ->
        (ssi: BigInt3):

    alloc_locals

    # log_n and the number of "rounds" are the same
    let log_n = transcript.n_rounds

    # TODO: need to have bigint 3 multiplying for the ss...
    if j == log_n:
        let (one) = felt_to_bigint(1)
        return (ssi = one)
    end

    # A mask for the jth bit of a number at most 2 ** log_n - 1
    # the mask is just a 1 at the jth position
    let (mask) = variable_exponentiaition_felts{range_check_ptr=range_check_ptr}(2, j)
    let (local b_i_j) = bitwise_and(i, mask)

    let (r) = get_ssi(transcript, i, j + 1, p)
    if b_i_j == 0:
        let (curr_mult) = inverse_mod_p(transcript.transcript_entries[j].x, p)
        let (ssi) = mult_bigint(r, curr_mult, p)
        return (ssi = ssi)
    else:
        let curr_mult = transcript.transcript_entries[j].x
        let (ssi) = mult_bigint(r, curr_mult, p)
        return (ssi = ssi)
    end
end

# As per page 15 of the paper
func get_ss_and_inverse{bitwise_ptr : BitwiseBuiltin*, range_check_ptr}(
        ss: BigInt3*,
        ssinv: BigInt3*,
        n: felt,
        transcript: Transcript*,
        i: felt, p: BigInt3
    )->(ss_ret: BigInt3*, ssinv_ret: BigInt3*):
    if i == n:
        return (ss_ret=ss, ssinv_ret=ssinv)
    end
    let (ssi: BigInt3) = get_ssi(transcript, i, 0, p)
    let (ssi_inv: BigInt3) = inverse_mod_p(ssi, p)

    # TODO: syntax??
    assert ss[i] = ssi
    assert ssinv[i] = ssi_inv

    let (ss, ssinv) = get_ss_and_inverse(ss, ssinv, n, transcript, i + 1, p)
    return (ss_ret=ss, ssinv_ret=ssinv)
end

func get_final_P_difference{range_check_ptr, bitwise_ptr: BitwiseBuiltin*}(transcript: Transcript*, i: felt, p: BigInt3) -> (P_diff: EcPoint): 
    alloc_locals
    let (local x_inv: BigInt3) = inverse_mod_p(transcript.transcript_entries[i].x, p)

    let (curr_add_L_1: EcPoint) = ec_mul(transcript.transcript_entries[i].L, transcript.transcript_entries[i].x)
    let (curr_add_L: EcPoint) = ec_mul(curr_add_L_1, transcript.transcript_entries[i].x)

    let (curr_add_R_1: EcPoint) = ec_mul(transcript.transcript_entries[i].R, x_inv)
    let (curr_add_R: EcPoint) = ec_mul(curr_add_R_1, x_inv)
    let (curr_diff: EcPoint) = ec_add(curr_add_L, curr_add_R)

    if i == transcript.n_rounds - 1:
        return (P_diff = curr_diff)
    end
    let (recur_diff) = get_final_P_difference(transcript, i + 1, p)
    let (added_diff) = ec_add(recur_diff, curr_diff)
    return (P_diff = added_diff)
end


# Return 0 if successful, otherwise return 1
func verify_innerproduct_2{range_check_ptr, bitwise_ptr: BitwiseBuiltin*}(gs: EcPoint*, hs: EcPoint*, u: EcPoint, P: EcPoint, proof: ProofInnerproduct2, transcript: Transcript*, p: BigInt3) ->
        (success: felt):

    alloc_locals

    let (ss: BigInt3*) = alloc()
    let (ssinv: BigInt3*) = alloc()
    let (transcript_verified) = verify_transcript_inner_product_2(transcript, 0)

    # Fail if the transcript is not verified
    if transcript_verified == 0:
        return (success = 0)
    end

    let (ss, ssinv) = get_ss_and_inverse(ss, ssinv, proof.n, transcript, 0, p)

    %{
        print("ss[0]", from_cairo_big_int(memory[ss], memory[ss + 1], memory[ss + 2]))
        print("ss[1]", from_cairo_big_int(memory[3 + ss], memory[3 + ss + 1], memory[3 + ss + 2]))
    %}
    
    # TODO: does the verifier have to do this step??? (its the suppa expensive one...)
    let (g: EcPoint) = multi_exp(ss, proof.n, gs)
    let (h: EcPoint) = multi_exp(ssinv, proof.n, hs)

    %{
        print("g", from_cairo_big_int(ids.g.x.d0, ids.g.x.d1, ids.g.x.d2))
        print("h", from_cairo_big_int(ids.h.x.d0, ids.h.x.d1, ids.h.x.d2))
    %}
    let (g_a: EcPoint) = ec_mul(g, proof.a)

    let (h_b: EcPoint) = ec_mul(h, proof.b)
    
    # TODO: you can reduce this to 1 EC multiply by doing proof.a * proof.b once
    # a decent math_utils library for bigints is up
    let (u_a: EcPoint) = ec_mul(u, proof.a)
    let (u_ab: EcPoint) = ec_mul(u_a, proof.b)
    %{
        import sys

        sys.path.insert(1, './python_bulletproofs')
        sys.path.insert(1, './python_bulletproofs/src')

        from utils.utils import ModP, mod_hash, inner_product, set_ec_points, from_cairo_big_int
        print("u_ab", from_cairo_big_int(ids.u_ab.x.d0, ids.u_ab.x.d1, ids.u_ab.x.d2))
    %}


    let (LHS_1: EcPoint) = ec_add(g_a, h_b)
    let (LHS: EcPoint) = ec_add(LHS_1, u_ab)

    if transcript.n_rounds == 0:
        let (success) = check_ec_equal(LHS, P)
        return (success = success)
    end

    let (P_diff) = get_final_P_difference(transcript, 0, p)
    let (P_prime) = ec_add(P, P_diff)

    %{
        import sys

        sys.path.insert(1, './python_bulletproofs')
        sys.path.insert(1, './python_bulletproofs/src')

        from utils.utils import ModP, mod_hash, inner_product, set_ec_points, from_cairo_big_int
        print("X", from_cairo_big_int(ids.LHS.x.d0, ids.LHS.x.d1, ids.LHS.x.d2))
        print("g_a", from_cairo_big_int(ids.g_a.x.d0, ids.g_a.x.d1, ids.g_a.x.d2))
        print("h_b", from_cairo_big_int(ids.h_b.x.d0, ids.h_b.x.d1, ids.h_b.x.d2))
        print("PPrime", from_cairo_big_int(ids.P_prime.x.d0, ids.P_prime.x.d1, ids.P_prime.x.d2))
    %}
    let (success) = check_ec_equal(LHS, P_prime)
    # TODO: have P update properly

    return (success = success)
end
