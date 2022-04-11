from starkware.cairo.common.math_cmp import is_le_felt

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
func inverse_mod_p{range_check_ptr}(x: felt, p: felt) -> (inv: felt):
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
func variable_exponentiaition{range_check_ptr}(x: felt, y: felt) -> (exp: felt):
    alloc_locals 
    local exp: felt
    %{
        ids.exp = pow(ids.x, ids.y, PRIME)
    %}


    return (exp = exp)
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