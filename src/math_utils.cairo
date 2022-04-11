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