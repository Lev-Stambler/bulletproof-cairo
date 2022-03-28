
# Represents the proof passed to the verifier
struct ProofInnerproduct2:
    member a: felt
    member b: felt
    member n_rounds: felt
    member xs: felt*
    member Ls: felt*
    member Rs: felt*
end