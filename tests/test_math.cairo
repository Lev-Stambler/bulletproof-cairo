%builtins output range_check bitwise ec_op
from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.ec import EcPoint, ec_add
from src.math_utils import multi_exp, ec_mul
from src.constants import P224_Order
from starkware.cairo.common.cairo_builtins import BitwiseBuiltin
from starkware.cairo.common.cairo_builtins import EcOpBuiltin

# TODO: update
func test_multiexp{output_ptr : felt*, range_check_ptr, bitwise_ptr: BitwiseBuiltin*, ec_op_ptr: EcOpBuiltin*}():
    alloc_locals

    local gs: EcPoint*
    let n: felt = 3
    local ss: felt*
    %{
        import sys
        sys.path.insert(1, './python_bulletproofs')
        sys.path.insert(1, './python_bulletproofs/src')

        from utils.elliptic_curve_hash import elliptic_hash_secp256k1
        from innerproduct.inner_product_verifier import SUPERCURVE as CURVE
        from group import EC
        from pippenger import PipCURVE


        ss_py = [3, 2, 4]
        ids.ss = ss = segments.add()

        for i, s in enumerate(ss_py):
            memory[ss + i] = s

        gs_py = [elliptic_hash_secp256k1(str("AAAA").encode(), CURVE),
                elliptic_hash_secp256k1(str("BBBB").encode(), CURVE),
                elliptic_hash_secp256k1(str("BBBB").encode(), CURVE)]

        ids.gs = gs = segments.add()
        for i, g in enumerate(gs_py):
            felts = EC.elem_to_cairo(g)
            for j, f in enumerate(felts):
                memory[gs + 2 * i + j] = f
        
        multi_exp = PipCURVE.multiexp(gs_py, ss_py)
    %}
    let (cairo_multi_exp: EcPoint) = multi_exp(ss, 3, gs)

    %{
        felts = EC.elem_to_cairo(multi_exp)
        x = felts[0]

        y = felts[1]

        assert x == ids.cairo_multi_exp.x

        assert y == ids.cairo_multi_exp.y
    %}

    return ()

end

func test_ec_mul{output_ptr : felt*, range_check_ptr, bitwise_ptr: BitwiseBuiltin*, ec_op_ptr: EcOpBuiltin*}():
    alloc_locals

    local g: EcPoint*
    let (local scalars_array : felt*) = alloc()
    assert scalars_array[0] = 1
    assert scalars_array[1] = 2
    assert scalars_array[2] = 3
    assert scalars_array[3] = 4
    assert scalars_array[4] = 5
    %{
        import sys
        sys.path.insert(1, './python_bulletproofs')
        sys.path.insert(1, './python_bulletproofs/src')

        from utils.elliptic_curve_hash import elliptic_hash_secp256k1
        from innerproduct.inner_product_verifier import SUPERCURVE as CURVE
        from group import EC
        from pippenger import PipCURVE

        g_py = elliptic_hash_secp256k1(str("AAAA").encode(), CURVE)
        scalars_array = [1, 2, 3, 4, 5]

        ids.g = g_cairo = segments.add()

        felts = EC.elem_to_cairo(g_py)
        for j, f in enumerate(felts):
            memory[g_cairo + j] = f
    %}

    let (local x_1: EcPoint) = ec_mul(g[0], 1)
    let (local x_2: EcPoint) = ec_mul(g[0], 2)
    let (local x_3: EcPoint) = ec_mul(g[0], 3)
    let (local x_4: EcPoint) = ec_mul(g[0], 4)
    let (local x_5: EcPoint) = ec_mul(g[0], 5)


    %{
        def check_cairo_eq(cairo, pt):
            assert(cairo.x == pt.x)
            assert(cairo.y == pt.y)

        check_cairo_eq(ids.x_1, g_py * 1)
        check_cairo_eq(ids.x_2, g_py * 2)
        check_cairo_eq(ids.x_3, g_py * 3)
        check_cairo_eq(ids.x_4, g_py * 4)
        check_cairo_eq(ids.x_5, g_py * 5)
    %}
    return ()

end



# TODO: actually run
func main{output_ptr : felt*, range_check_ptr, bitwise_ptr: BitwiseBuiltin*, ec_op_ptr: EcOpBuiltin*}():
    alloc_locals
    test_multiexp()
    test_ec_mul()
    return()
end
