from starkware.cairo.common.cairo_builtins import EcOpBuiltin
from starkware.cairo.common.uint256 import Uint256, uint256_unsigned_div_rem, uint256_mul, uint256_add
from starkware.cairo.common.ec_point import EcPoint
from starkware.cairo.common.ec import ec_op, ec_add
from starkware.cairo.common.cairo_builtins import BitwiseBuiltin
from starkware.cairo.common.math import unsigned_div_rem

const Q = 3618502788666131213697322783095070105526743751716087489154079457884512865583
const Q_high = 10633823966279327296825105735305134079
const Q_low = 243918903305429252644362009180409056559

func _to_uint256(a: felt) -> (r: Uint256):
    alloc_locals
    local high
    local low
    %{
        ids.high = ids.a // 2 ** 128
        ids.low = ids.a % 2 ** 128
    %}
    assert a = high * 2 ** 128 + low
    let r = Uint256(low=low, high=high)
    return (r = r)
end

# Explicitly convert a uint256 to a felt
func _uint256_to_mod_Q_direct(a: Uint256) -> (r: felt):
    return (r= 2** 128 * a.high + a .low)
end

func uint256_to_mod_Q{range_check_ptr}(a: Uint256) -> (modded: felt):
    let Q_uint256 = Uint256(Q_low, Q_high)
    let (_: Uint256, rem: Uint256) = uint256_unsigned_div_rem(a, Q_uint256)

    # Because Q < PRIME, we expect rem < PRIME, so we can directly compute it
    let (rem_felt: felt) = _uint256_to_mod_Q_direct(rem)

    return (modded=rem_felt)
end

# Carry out multplication of field elements mod q via a python hint.
# The hint is then verified using Uin256 and subsequent multplication
# We can ensure that, for some proof k:
# k * Q + (ab mod Q) = ab over the integers.
# Because uint256_mul gives us a 512 integer and any number mod Q is at most
# 251 bits, we are working in a sufficiently large field to pretend that we are
# working in the integers
func _mul_mod_Q{range_check_ptr}(a: Uint256, b: Uint256) -> (prod: Uint256):
    alloc_locals
    local prod_mod_q_low: felt
    local prod_mod_q_high: felt
    local quotient_low: felt
    local quotient_high: felt
    %{
        import sys
        sys.path.insert(1, './python_bulletproofs')
        sys.path.insert(1, './python_bulletproofs/src')

        from utils.utils import ModP, mod_hash, inner_product, set_ec_points
        Q = ids.Q + PRIME
        _a = ids.a.high * 2 ** 128 + ids.a.low
        _b = ids.b.high * 2 ** 128 + ids.b.low
        a = ModP(_a, Q)
        b = ModP(_b, Q)
        prod = (a * b).x % Q

        ids.prod_mod_q_high = prod // 2 ** 128
        ids.prod_mod_q_low = prod % 2 ** 128

        quotient = _a * _b // Q
        ids.quotient_low = quotient % 2 ** 128
        ids.quotient_high = quotient // 2 ** 128
    %}
    let quotient = Uint256(quotient_low, quotient_high)
    let Q_uint256 = Uint256(Q_low, Q_high)
    let prod_mod_q_uint256 = Uint256(prod_mod_q_low, prod_mod_q_high)

    let (ab_prod_low: Uint256, ab_prod_high: Uint256) = uint256_mul(a, b)

    let (quot_q_low: Uint256, quot_q_high: Uint256) = uint256_mul(quotient, Q_uint256)

    let (quot_q_low_summed: Uint256, carry: felt) = uint256_add(quot_q_low, prod_mod_q_uint256)

    # Ensure that quotient * Q + prod = a * b
    assert ab_prod_high.low = quot_q_high.low + carry
    assert ab_prod_high.high = quot_q_high.high

    assert ab_prod_low.low = quot_q_low_summed.low
    assert ab_prod_low.high = quot_q_low_summed.high

    
    return (prod=prod_mod_q_uint256)
end

# TODO: add tests
# Calculate the inverse via a hint and then use _mul_mod_Q to verifiy the inverse
func inv_mod_Q{range_check_ptr}(a: felt) -> (inv: felt):
    alloc_locals
    local inv_low: felt
    local inv_high: felt
    local multi: felt
    %{
        import sys
        import math
        sys.path.insert(1, './python_bulletproofs')
        sys.path.insert(1, './python_bulletproofs/src')

        from utils.utils import ModP, mod_hash, inner_product, set_ec_points
        Q = ids.Q + PRIME
        x = ModP(ids.a, Q)
        inv = x.inv().x
        ids.inv_low = inv % 2 ** 128
        ids.inv_high = inv // 2 ** 128
    %}
    let inv_uint256 = Uint256(inv_low, inv_high)
    let (a_uint256) = _to_uint256(a)

    # Ensure that the inverse is correct via multiplication check    
    let (prod) = _mul_mod_Q(inv_uint256, a_uint256)
    assert prod.high = 0
    assert prod.low = 1

    let (inv) = _uint256_to_mod_Q_direct(inv_uint256)
    return (inv=inv)
end

func mul_mod_Q{range_check_ptr}(a: felt, b: felt) -> (prod: felt):
    let (_a) = _to_uint256(a)
    let (_b) = _to_uint256(b)
    let (prod: Uint256) = _mul_mod_Q(_a, _b)
    let (prod_felt) = _uint256_to_mod_Q_direct(prod)
    return (prod=prod_felt)
end
