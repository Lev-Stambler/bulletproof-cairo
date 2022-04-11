from common_ec_cairo.ec.ec import EcPoint

struct TranscriptEntry:
    member L: EcPoint
    member R: EcPoint
    member x: felt
end

struct Transcript:
    member transcript_seed: felt
    member n_transcript_entries: felt
    member transcript_entries: TranscriptEntry*
end


# Represents the proof passed to the verifier
struct ProofInnerproduct2:
    member a: felt
    member b: felt
    member n_rounds: felt
    member transcript: Transcript
end