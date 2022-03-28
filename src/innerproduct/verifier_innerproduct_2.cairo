from src.innerproduct.proof_innerproduct_2 import ProofInnerproduct2 
from common_ec_cairo.ec.ec import EcPoint

# Return 0 if successful, otherwise return 1
func verify(g: EcPoint*, h: EcPoint*, u: EcPoint*, P: EcPoint*,
    proof: ProofInnerproduct2*) ->
        (success: felt):


    return (success = 1)
end