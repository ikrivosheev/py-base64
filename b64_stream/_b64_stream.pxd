cdef extern from 'b64_stream.h':

    # Decode
    cdef struct b64_decode_state:
        int phase
        size_t out_len
        char buffer[4]

    void b64_stream_decode_init(b64_decode_state* state)
    int b64_stream_decode(b64_decode_state* state, const char* src, size_t src_len, char* out)
    int b64_stream_decode_final(b64_decode_state *state)

    # Encode
    cdef struct b64_encode_state:
        int phase
        size_t out_len
        char buffer[3]

    void b64_stream_encode_init(b64_encode_state *state)
    int b64_stream_encode(b64_encode_state *state, const char* src, size_t src_len, char* out);
    int b64_stream_encode_final(b64_encode_state *state, char* out);
