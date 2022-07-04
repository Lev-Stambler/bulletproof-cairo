from starkware.cairo.common.cairo_builtins import EcOpBuiltin
from starkware.cairo.common.uint256 import Uint256
from starkware.cairo.common.ec_point import EcPoint
from starkware.cairo.common.ec import ec_op, ec_add
from starkware.cairo.common.cairo_builtins import BitwiseBuiltin
from starkware.cairo.common.math_cmp import is_le_felt

const Q = 3618502788666131213697322783095070105526743751716087489154079457884512865583

# Multiply an EC point by a scalar
func ec_mul{ec_op_ptr: EcOpBuiltin*}(p: EcPoint, m: felt) -> (product: EcPoint):
    alloc_locals
    local id_point: EcPoint = EcPoint(0, 0)
    let (r: EcPoint) = ec_op(id_point, m, p)
    return (product = r)
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