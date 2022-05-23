from common_ec_cairo.ec.ec import EcPoint
from common_ec_cairo.ec.bigint import BigInt3

struct TranscriptEntry:
    member L: EcPoint
    member R: EcPoint
    member x: BigIntw3
end

struct Transcript:
    member transcript_seed: felt
    member n_rounds: felt
    member transcript_entries: TranscriptEntry*
end


# Represents the proof passed to the verifier
# not including the transcript entries
struct ProofInnerproduct2:
    member a: BigInt3
    member b: BigInt3
    member n: felt
end