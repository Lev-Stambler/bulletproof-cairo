from starkware.cairo.common.ec_point import EcPoint

# An entry into a transcript, takes 5 felt memory addresses
struct TranscriptEntry:
    member L: EcPoint
    member R: EcPoint
    member x: felt
end

struct Transcript:
    member n_rounds: felt
    member transcript_seed: felt
    member transcript_entries: TranscriptEntry
end


# Represents the proof passed to the verifier
# not including the transcript entries
struct ProofInnerproduct2:
    member a: felt
    member b: felt
    member n: felt
end