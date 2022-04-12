from common_ec_cairo.ec.ec import EcPoint, ec_mul, ec_add
from starkware.cairo.common.cairo_builtins import BitwiseBuiltin
from starkware.cairo.common.math_cmp import is_le_felt
from common_ec_cairo.ec.param_def import BASE
from common_ec_cairo.ec.bigint import BigInt3

# Divide n / d using a Python hint and assert the computation in Cairo
func divide_and_remainder{range_check_ptr}(n: felt, d: felt) -> (q: felt, r: felt):
    alloc_locals
    local q: felt
    local r: felt
    %{
        ids.q = ids.n // ids.d
        ids.r = ids.n % ids.d
    %}
    # Ensure that the hint computed the result correctly
    assert q * d + r = n
    let (local lt_d) = is_le_felt{range_check_ptr=range_check_ptr}(r, d - 1)
    if lt_d == 0:
        # Fail if r is greater than d
        assert 0 = 1
    end
    let (local gte_0) = is_le_felt{range_check_ptr=range_check_ptr}(0, r)
    if gte_0 == 0:
        # Fail if r is greater than d
        assert 0 = 1
    end


    return (q = q, r=r)
end


# TODO: have code that verifies the inverse
func inverse_mod_p(x: felt, p: felt) -> (inv: felt):
    alloc_locals 
    local inv: felt
    %{
        sys.path.insert(1, './python_bulletproofs')
        sys.path.insert(1, './python_bulletproofs/src')

        from utils.utils import ModP, mod_hash, inner_product

        x_modp = ModP(ids.x, ids.p)
        ids.inv = x_modp.inv()
    %}


    return (inv = inv)
end

# Exponentiate x ^ y
# TODO: check that this is correct
func variable_exponentiaition{range_check_ptr: felt*}(x: felt, y: felt) -> (exp: felt):
    alloc_locals 
    local exp: felt
    %{
        ids.exp = pow(ids.x, ids.y, PRIME)
    %}


    return (exp = exp)
end

func felt_to_bigint(x: felt) -> (bigint: BigInt3):
    alloc_locals
    local bigint3: BigInt3*
    %{
        import sys
        sys.path.insert(1, './python_bulletproofs')
        sys.path.insert(1, './python_bulletproofs/src')

        from utils.utils import to_cairo_big_int
        d0, d1, d2 = to_cairo_big_int(ids.x)
        ids.bigint3 = bigint3 = segments.add()

        memory[bigint3] = d0
        memory[bigint3 + 1] = d1
        memory[bigint3 + 2] = d2
    %}
    assert bigint3.d0 + bigint3.d1 * BASE + bigint3.d2 * BASE = x
    return (bigint=bigint3[0])
end



# Only works for a small x
# TODO: speedup
# func slow_multiplication_mod_p{range_check_ptr}(x: felt, y: felt, p: felt) -> (output: felt):
#     if x == 1:
#         return (output = y)
#     end
#     let (r) = slow_multiplication_mod_p(x - 1, y, p)
#     let not_modded = r + y
#     let (_, modded) = divide_and_remainder(not_modded, p)
#     return (output = modded)
# end


# TODO: move to a multiexp fn
# TODO: test me by comparing with python...
# g \in G
# and s \in Z
func multi_exp_internal{bitwise_ptr : BitwiseBuiltin*, range_check_ptr}(ss: felt*, n: felt, gs: EcPoint*, i: felt, p: felt) -> (g: EcPoint):
    alloc_locals
    if i == n - 1:
        let (bigint: BigInt3) = felt_to_bigint(ss[i])
        let (ec: EcPoint) = ec_mul(gs[i], bigint)
        return (g=ec)
    end

    let (bigint: BigInt3) = felt_to_bigint(ss[i])
    let (local ec: EcPoint) = ec_mul(gs[i], bigint)

    let (recur: EcPoint) = multi_exp_internal(ss, n, gs, i + 1, p)    
    let (prod: EcPoint) = ec_add(ec, recur)
    
    return (g=prod)
end


func multi_exp{bitwise_ptr : BitwiseBuiltin*, range_check_ptr}(ss: felt*, n: felt, gs: EcPoint*, p: felt) -> (g: EcPoint):
    let (g: EcPoint) = multi_exp_internal(ss, n, gs, 0, p)
    return (g=g)
end