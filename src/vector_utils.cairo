from starkware.cairo.common.pow import pow
from starkware.cairo.common.alloc import alloc

# Compute the inner product of v1, v2 over Euclidean Space
func inner_product(
    v1: felt*,
    v2: felt*,
    n: felt
) -> (r: felt):
    alloc_locals
    if n == 1:
        return (r = [v1] * [v2])
    end
    let (local recur: felt) = inner_product(v1 + 1, v2 + 1, n - 1)
    let p = [v1] * [v2]
    let r = p * recur
    return (r = r)
end


# Multi_exp v1^v2 by doing Prod_{i \in [n]} v1^v2
func multi_exp{range_check_ptr: felt}(
    v1: felt*,
    v2: felt*,
    n: felt
) -> (r: felt):
    alloc_locals
    if n == 0:
        return (r = 1)
    end
    let (local pow_recur) = pow{range_check_ptr=range_check_ptr}([v1], [v2])
    let (next) = multi_exp(v1 + 1, v2 + 1, n - 1)
    let r = next * pow_recur
    return (r = r)
end


func _elem_wise_prod(
    v1: felt*,
    v2: felt*,
    n: felt,
    i: felt,
    res: felt*
):
    if i == n:
        return ()
    end
    assert [res] = [v1] * [v2]
    _elem_wise_prod(v1, v2, n, i + 1, res + 1)
    return ()
end

# Take the element wise product of v1, v2 and place it in res,
# where res is uninitialized
# Expects n = |v1| = |v2|
func elem_wise_prod(
    v1: felt*,
    v2: felt*,
    n: felt,
) -> (r: felt*): 
    alloc_locals
    let (local r: felt*) = alloc()
    _elem_wise_prod(v1, v2, n, 0, r)
    return (r = r)
end