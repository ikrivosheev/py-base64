from libc.stdlib cimport malloc, free

cimport _b64_stream


def chunks(data, count):
    cdef int i
    for i in range(0, len(data), count):
        yield data[i:i+count]


cdef class Base64StreamBase:
    cdef char* _buffer
    cdef size_t _chunk_size
    cdef size_t _buffer_size

    @property
    def total(self):
        raise NotImplementedError

    def update(self, bytes data):
        raise NotImplementedError
    
    def finalize(self):
        raise NotImplementedError


cdef class Base64StreamDecode(Base64StreamBase):
    cdef _b64_stream.b64_decode_state* _c_state

    def __cinit__(self, size_t buffer_size=3 * (2 ** 10)):
        self._c_state = <_b64_stream.b64_decode_state*> malloc(sizeof(_b64_stream.b64_decode_state))
        if self._c_state is NULL:
            raise MemoryError()
        self._buffer = <char*> malloc(sizeof(char) * buffer_size)
        if self._buffer is NULL:
            raise MemoryError()
        self._buffer_size = buffer_size
        self._chunk_size = buffer_size / 3 * 4
    
    @property
    def total(self):
        return self._c_state.out_len

    def update(self, bytes data):
        cdef size_t length

        with memoryview(data) as view:
            for chunk in chunks(view, self._chunk_size):
                length = _b64_stream.b64_stream_decode(self._c_state, chunk, len(chunk), self._buffer)
                yield self._buffer[:length]

    def finalize(self):
        result = _b64_stream.b64_stream_decode_final(self._c_state)
        if not result:
            raise ValueError('Test')

    def __dealloc__(self):
        if self._c_state is not NULL:
            free(self._c_state)
        if self._buffer is not NULL:
            free(self._buffer)


cdef class Base64StreamEncode(Base64StreamBase):
    cdef _b64_stream.b64_encode_state* _c_state

    def __cinit__(self, size_t buffer_size=2 ** 10):
        self._c_state = <_b64_stream.b64_encode_state*> malloc(sizeof(_b64_stream.b64_encode_state))
        if self._c_state is NULL:
            raise MemoryError
        self._buffer = <char*> malloc(sizeof(char) * buffer_size)
        if self._buffer is NULL:
            raise MemoryError
        self._buffer_size = buffer_size
        self._chunk_size = buffer_size * 3 / 4
    
    @property
    def total(self):
        return self._c_state.out_len

    def update(self, bytes data):
        cdef size_t length

        with memoryview(data) as view:
            for chunk in chunks(view, self._chunk_size):
                length = _b64_stream.b64_stream_encode(self._c_state, chunk, len(chunk), self._buffer)
                yield self._buffer[:length]

    def finalize(self):
        cdef size_t length

        length = _b64_stream.b64_stream_encode_final(self._c_state, self._buffer)
        if length < 0:
            raise ValueError
        return self._buffer[:length]

    def __dealloc__(self):
        if self._c_state is not NULL:
            free(self._c_state)
        if self._buffer is not NULL:
            free(self._buffer)
