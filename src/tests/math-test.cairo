%builtins output range_check bitwise
from common_ec_cairo.ec.ec import EcPoint, ec_mul, ec_add
from src.math_utils import multi_exp, remainder, inverse_mod_p, variable_exponentiaition
from src.constants import P224_Order
from starkware.cairo.common.cairo_builtins import BitwiseBuiltin
from common_ec_cairo.ec.bigint import BigInt3


func test_inverse_mod_p{output_ptr: felt*, range_check_ptr}():
    alloc_locals
    local x: BigInt3
    local p: BigInt3

    %{
        import sys
        sys.path.insert(1, './python_bulletproofs')
        sys.path.insert(1, './python_bulletproofs/src')

        from utils.utils import ModP, mod_hash, inner_product, from_cairo_big_int, to_cairo_big_int

        x = 123456789
        p = 13

        ids.x.d0, ids.x.d1, ids.x.d2 = to_cairo_big_int(x)
        ids.p.d0, ids.p.d1, ids.p.d2 = to_cairo_big_int(p)
    %}

    let (r) = inverse_mod_p(x, p)
    
    %{
        assert from_cairo_big_int(ids.r.d0, ids.r.d1, ids.r.d2) == ModP(x, p).inv().x
    %}

    return ()
end


func test_variable_exponentiation{output_ptr: felt*, range_check_ptr}():
    alloc_locals
    local x: BigInt3
    local y: BigInt3
    local p: BigInt3

    %{
        import sys
        sys.path.insert(1, './python_bulletproofs')
        sys.path.insert(1, './python_bulletproofs/src')

        from utils.utils import ModP, mod_hash, inner_product, from_cairo_big_int, to_cairo_big_int

        x = 123456789
        y = 123456799
        p = 92723

        ids.x.d0, ids.x.d1, ids.x.d2 = to_cairo_big_int(x)
        ids.y.d0, ids.y.d1, ids.y.d2 = to_cairo_big_int(y)
        ids.p.d0, ids.p.d1, ids.p.d2 = to_cairo_big_int(p)
    %}

    let (r) = variable_exponentiaition{range_check_ptr=range_check_ptr}(x, y, p)
    
    %{
        assert from_cairo_big_int(ids.r.d0, ids.r.d1, ids.r.d2) == pow(x, y, p)
    %}

    return ()
end



func test_remainder{output_ptr: felt*, range_check_ptr}():
    alloc_locals
    local x: BigInt3
    local p: BigInt3

    %{
        import sys
        sys.path.insert(1, './python_bulletproofs')
        sys.path.insert(1, './python_bulletproofs/src')

        from utils.utils import ModP, mod_hash, inner_product, from_cairo_big_int, to_cairo_big_int

        x = 123456789
        p = 12345

        ids.x.d0, ids.x.d1, ids.x.d2 = to_cairo_big_int(x)
        ids.p.d0, ids.p.d1, ids.p.d2 = to_cairo_big_int(p)
    %}

    let (r) = remainder(x, p)
    
    %{
        assert from_cairo_big_int(ids.r.d0, ids.r.d1, ids.r.d2) == x % p
    %}

    return ()
end


func test_multiexp{output_ptr : felt*, range_check_ptr, bitwise_ptr: BitwiseBuiltin*}():
    alloc_locals

    local gs: EcPoint*
    let n: felt = 3
    local ss: BigInt3*
    %{
        import sys
        sys.path.insert(1, './python_bulletproofs')
        sys.path.insert(1, './python_bulletproofs/src')

        from utils.elliptic_curve_hash import elliptic_hash_P224, elliptic_hash_secp256k1
        from utils.utils import to_cairo_big_int
        from pippenger import Pip256k1
        from pippenger.group import EC

        from fastecdsa.curve import secp256k1, Curve

        ss_py = [3, 2, 4]
        ids.ss = ss = segments.add()

        for i, s in enumerate(ss_py):
            d0, d1, d2 = to_cairo_big_int(s)
            memory[ss + i * 3] = d0
            memory[ss + i * 3 + 1] = d1
            memory[ss + i * 3 + 2] = d2

        CURVE: Curve = secp256k1
        gs_py = [elliptic_hash_secp256k1(str("AAAA").encode(), CURVE),
                elliptic_hash_secp256k1(str("BBBB").encode(), CURVE),
                elliptic_hash_secp256k1(str("BBBB").encode(), CURVE)]

        ids.gs = gs = segments.add()
        for i, g in enumerate(gs_py):
            felts = EC.elem_to_cairo(g)
            # print("AAA", felts)
            for j, f in enumerate(felts):
                print(6 * i + j)
                memory[gs + 6 * i + j] = f
        
        multi_exp = Pip256k1.multiexp(gs_py, ss_py)
    %}
    let (cairo_multi_exp: EcPoint) = multi_exp{bitwise_ptr=bitwise_ptr, range_check_ptr=range_check_ptr}(ss, 3, gs, P224_Order)

    %{
        felts = EC.elem_to_cairo(multi_exp)
        x0 = felts[0]
        x1 = felts[1]
        x2 = felts[2]

        y0 = felts[3]
        y1 = felts[4]
        y2 = felts[5]

        print(felts, ids.cairo_multi_exp.x.d0)
        assert x0 == ids.cairo_multi_exp.x.d0
        assert x1 == ids.cairo_multi_exp.x.d1
        assert x2 == ids.cairo_multi_exp.x.d2

        assert y0 == ids.cairo_multi_exp.y.d0
        assert y1 == ids.cairo_multi_exp.y.d1
        assert y2 == ids.cairo_multi_exp.y.d2
    %}

    return ()

end

# TODO: actually run
func main{output_ptr : felt*, range_check_ptr, bitwise_ptr: BitwiseBuiltin*}():
    alloc_locals
    test_multiexp()

    test_remainder()
    test_inverse_mod_p()
    test_variable_exponentiation()
    return()
end
