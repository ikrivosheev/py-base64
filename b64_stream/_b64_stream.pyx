from libc.stdlib cimport malloc, free

cimport cb64_stream


cdef class Base64StreamDecode:
    cdef cb64_stream.b64_decode_state* _c_state

    def __init__(self):
        self._c_state = <cb64_stream.b64_decode_state*> malloc(sizeof(cb64_stream.b64_decode_state))
        if self._c_state is NULL:
            raise MemoryError()
    
    def __dealloc__(self):
        if self._c_state is not NULL:
            free(self._c_state)


cdef class Base64StreamEncode:
    cdef cb64_stream.b64_encode_state* _c_state

    def __init__(self):
        self._c_state = <cb64_stream.b64_encode_state*> malloc(sizeof(cb64_stream.b64_encode_state))
        if self._c_state is NULL:
            raise MemoryError()

    def __dealloc__(self):
        if self._c_state is not NULL:
            free(self._c_state)
