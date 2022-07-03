from starkware.cairo.common.cairo_builtins import EcOpBuiltin
from starkware.cairo.common.ec_point import EcPoint
from starkware.cairo.common.ec import ec_op, ec_add
from starkware.cairo.common.cairo_builtins import BitwiseBuiltin
from starkware.cairo.common.math_cmp import is_le_felt

const Q = 3618502788666131213697322783095070105526743751716087489154079457884512865583

# Multiply an EC point by a scalar
# Multiply an EC point by a scalar
func ec_mul{ec_op_ptr: EcOpBuiltin*}(p: EcPoint, m: felt) -> (product: EcPoint):
    alloc_locals
    local id_point: EcPoint = EcPoint(0, 0)
    let (r: EcPoint) = ec_op(id_point, m, p)
    return (product = r)
end

# TODO: add tests
func inv_mod_Q(a: felt) -> (inv: felt):
    alloc_locals
    local inv: felt
    local multi: felt
    %{
        import sys
        import math
        sys.path.insert(1, './python_bulletproofs')
        sys.path.insert(1, './python_bulletproofs/src')

        from utils.utils import ModP, mod_hash, inner_product, set_ec_points
        Q = ids.Q + PRIME
        x = ModP(ids.a, Q)
        ids.inv = inv = x.inv().x

        # multi = math.floor((inv * a % PRIME) / Q)
        # print("M", multi)
        # ids.multi = multi
    %}
    # TODO: how to asserthh
    # assert inv * a - 1 = Q 
    return (inv=inv)
end

# # TODO: test and assert
func mul_mod_Q(a: felt, b: felt) -> (prod: felt):
    alloc_locals
    local prod: felt
    %{
        import sys
        sys.path.insert(1, './python_bulletproofs')
        sys.path.insert(1, './python_bulletproofs/src')

        from utils.utils import ModP, mod_hash, inner_product, set_ec_points
        a = ModP(ids.a, ids.Q + PRIME)
        b = ModP(ids.b, ids.Q + PRIME)
        ids.prod = (a * b).x
    %}
    # a should either equal the mod or be Q off from the mod
    # if (rem - a) != Q:
    #     if rem != a:
    #         assert true = false
    #     end
    # end
    return (prod=prod)
end


# Multi exponentiate `gs` with `ss` as defined at the top of page 12 of the Bulletproof paper
# where
# g \in G
# and s \in Z
func multi_exp_internal{ec_op_ptr: EcOpBuiltin*, bitwise_ptr : BitwiseBuiltin*, range_check_ptr}(ss: felt*,
        n: felt, gs: EcPoint*, i: felt) -> (g: EcPoint):
    alloc_locals
    if i == n - 1:
        let (ec: EcPoint) = ec_mul(gs[i], ss[i])
        return (g=ec)
    end

    let (local ec: EcPoint) = ec_mul(gs[i], ss[i])

    let (recur: EcPoint) = multi_exp_internal(ss, n, gs, i + 1)    
    let (prod: EcPoint) = ec_add(ec, recur)
    
    return (g=prod)
end


# Wrapper to multi exponentiate `gs` with `ss` as defined at the top of page 12 of the Bulletproof paper
func multi_exp{ec_op_ptr: EcOpBuiltin*, bitwise_ptr : BitwiseBuiltin*, range_check_ptr}(ss: felt*, n: felt, gs: EcPoint*) -> (g: EcPoint):
    let (g: EcPoint) = multi_exp_internal(ss, n, gs, 0)
    return (g=g)
end

func check_ec_equal(ec1: EcPoint, ec2: EcPoint) -> (success: felt):
  if ec1.x != ec2.x:
        return (success = 0)
    end
    if ec1.y != ec2.y:
        return (success = 0)
    end
    return (success = 1)
end