#cython: language_level=3

from libc.stdlib cimport malloc, free

from b64_stream cimport _b64_stream


def chunks(data, count):
    cdef int i
    for i in range(0, len(data), count):
        yield data[i:i+count]


cdef class Base64StreamBase:
    @property
    def total(self):
        raise NotImplementedError

    def update(self, bytes data):
        raise NotImplementedError
    
    def finalize(self):
        raise NotImplementedError


cdef class Base64StreamDecode(Base64StreamBase):
    cdef _b64_stream.b64_decode_state* _c_state

    def __cinit__(self):
        self._c_state = <_b64_stream.b64_decode_state*> malloc(sizeof(_b64_stream.b64_decode_state))
        if self._c_state is NULL:
            raise MemoryError()
        _b64_stream.b64_stream_decode_init(self._c_state)
    
    @property
    def total(self):
        return self._c_state.out_len

    def update(self, bytes data):
        cdef bytes result
        cdef size_t length
        cdef char* buffer = <char*> malloc(sizeof(char) * len(data) * 4 // 3)
        
        length = _b64_stream.b64_stream_decode(self._c_state, data, len(data), buffer)
        try:
            result = buffer[:length]
        finally:
            free(buffer)
        return result

    def finalize(self):
        result = _b64_stream.b64_stream_decode_final(self._c_state)
        if not result:
            raise ValueError('Incorrect padding')

    def __dealloc__(self):
        if self._c_state is not NULL:
            free(self._c_state)


cdef class Base64StreamEncode(Base64StreamBase):
    cdef _b64_stream.b64_encode_state* _c_state

    def __cinit__(self):
        self._c_state = <_b64_stream.b64_encode_state*> malloc(sizeof(_b64_stream.b64_encode_state))
        if self._c_state is NULL:
            raise MemoryError()
        _b64_stream.b64_stream_encode_init(self._c_state)
    
    @property
    def total(self):
        return self._c_state.out_len

    def update(self, bytes data):
        cdef bytes result
        cdef size_t length
        cdef char* buffer = <char*> malloc(sizeof(char) * len(data) * 3 // 4)

        length = _b64_stream.b64_stream_encode(self._c_state, data, len(data), buffer)
        try:
            result = buffer[:length]
        finally:
            free(buffer)
        return result

    def finalize(self):
        cdef size_t length
        cdef char buffer[4]

        length = _b64_stream.b64_stream_encode_final(self._c_state, buffer)
        if length < 0:
            raise ValueError
        return buffer[:length]

    def __dealloc__(self):
        if self._c_state is not NULL:
            free(self._c_state)
