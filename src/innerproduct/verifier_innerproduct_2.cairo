from src.innerproduct.proof_innerproduct_2 import ProofInnerproduct2 
from src.structs import TranscriptEntry
from common_ec_cairo.ec.ec import EcPoint

# Return 0 if successful, otherwise return 1
func verify(g: EcPoint*, h: EcPoint*, u: EcPoint*, P: EcPoint*,
    proof: ProofInnerproduct2*) ->
        (success: felt):


    return (success = 1)
end

# Return a 1 if the transcript was successfully verified
func verify_transcript_inner_product_2(n_entries: felt, transcript_entries: TranscriptEntry*, seed: felt)
    -> (success: felt):
    # TODO:... may have to have an inner function...
    return (success = 1)
end