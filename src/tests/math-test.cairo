%builtins output range_check bitwise
from common_ec_cairo.ec.ec import EcPoint, ec_mul, ec_add
from src.math_utils import multi_exp
from src.constants import P224_Order
from starkware.cairo.common.cairo_builtins import BitwiseBuiltin

# TODO: actually run
func main{output_ptr : felt*, range_check_ptr, bitwise_ptr: BitwiseBuiltin*}():
    alloc_locals
    local gs: EcPoint*
    let n: felt = 3
    local ss: felt*
    %{
        import sys
        sys.path.insert(1, './python_bulletproofs')
        sys.path.insert(1, './python_bulletproofs/src')

        from utils.elliptic_curve_hash import elliptic_hash_P224
        from pippenger import PipP224
        from pippenger.group import EC

        from fastecdsa.curve import P224, secp256k1, Curve

        ss_py = [3, 2, 4]
        ids.ss = ss = segments.add()

        for i, s in enumerate(ss_py):
            memory[ss + i] = s

        CURVE: Curve = P224
        gs_py = [elliptic_hash_P224(str("AAAA").encode(), CURVE),
                elliptic_hash_P224(str("BBBB").encode(), CURVE),
                elliptic_hash_P224(str("BBBB").encode(), CURVE)]

        ids.gs = gs = segments.add()
        for i, g in enumerate(gs_py):
            felts = EC.elem_to_cairo(g)
            # print("AAA", felts)
            for j, f in enumerate(felts):
                print(6 * i + j)
                memory[gs + 6 * i + j] = f
        
        multi_exp = PipP224.multiexp(gs_py, ss_py)
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
    return()
end
