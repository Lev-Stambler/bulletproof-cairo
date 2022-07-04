from starkware.cairo.common.ec_point import EcPoint

# An entry into a transcript, takes 5 felt memory addresses
struct TranscriptEntry:
    member L: EcPoint
    member R: EcPoint
    member x: felt
end

# The transcript for a proof. Note that in order to make checking that a transcript
# entry's x was indeed computed with the hash of points, we do a hack where
# in order to access transcript entries, the following cast is required
# `let transcript_entries = tcast(transcript + 2, TranscriptEntry*)`
struct Transcript:
    member n_rounds: felt
    member transcript_seed: felt
    member transcript_entries: felt
end


# Represents the proof passed to the verifier
# not including the transcript entries
struct ProofInnerproduct2:
    member a: felt
    member b: felt
    member n: felt
end