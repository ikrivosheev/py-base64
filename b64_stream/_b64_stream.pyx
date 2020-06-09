#cython: language_level=3

from cpython.object cimport PyObject
from cpython.memoryview cimport PyMemoryView_GET_BUFFER
from libc.stdlib cimport malloc, free

from b64_stream cimport _b64_stream


def chunks(data, count):
    cdef int i
    for i in range(0, len(data), count):
        yield data[i:i+count]



cdef class Base64StreamDecode:
    cdef char* _buffer;
    cdef size_t _chunk_size;
    cdef _b64_stream.b64_decode_state* _c_state

    def __cinit__(self, size_t buffer_size = 2 ** 10):
        self._c_state = <_b64_stream.b64_decode_state*> malloc(sizeof(_b64_stream.b64_decode_state))
        if self._c_state is NULL:
            raise MemoryError()
        _b64_stream.b64_stream_decode_init(self._c_state)

        self._buffer = <char*> malloc(sizeof(char) * buffer_size)
        if self._buffer is NULL:
            raise MemoryError()
        self._chunk_size = buffer_size * 4 // 3
    
    @property
    def total(self):
        return self._c_state.out_len

    def update(self, data):
        cdef size_t length
        cdef Py_buffer* chunk_buffer
        
        with memoryview(data) as mem:
            for chunk in chunks(mem, self._chunk_size):
                chunk_buffer = PyMemoryView_GET_BUFFER(chunk)
                length = _b64_stream.b64_stream_decode(
                    self._c_state, 
                    <const char*>(chunk_buffer.buf), 
                    len(chunk), 
                    self._buffer)

                yield self._buffer[:length]        

    def finalize(self):
        result = _b64_stream.b64_stream_decode_final(self._c_state)
        if not result:
            raise ValueError('Incorrect padding')

    def __dealloc__(self):
        free(self._c_state)
        free(self._buffer)


cdef class Base64StreamEncode:
    cdef char* _buffer
    cdef size_t _chunk_size
    cdef _b64_stream.b64_encode_state* _c_state

    def __cinit__(self, size_t buffer_size = 2 ** 10):
        self._c_state = <_b64_stream.b64_encode_state*> malloc(sizeof(_b64_stream.b64_encode_state))
        if self._c_state is NULL:
            raise MemoryError()
        _b64_stream.b64_stream_encode_init(self._c_state)
        
        self._buffer = <char*> malloc(sizeof(char) * buffer_size)
        if self._buffer is NULL:
            raise MemoryError()
        self._chunk_size = buffer_size * 3 // 4
    
    @property
    def total(self):
        return self._c_state.out_len

    def update(self, data):
        cdef size_t length
        cdef Py_buffer* chunk_buffer

        with memoryview(data) as mem:
            for chunk in chunks(mem, self._chunk_size):
                chunk_buffer = PyMemoryView_GET_BUFFER(chunk)
                length = _b64_stream.b64_stream_encode(
                    self._c_state, 
                    <const char*>(chunk_buffer.buf), 
                    len(chunk), 
                    self._buffer)

                yield self._buffer[:length]        

    def finalize(self):
        cdef size_t length
        cdef char buffer[4]

        length = _b64_stream.b64_stream_encode_final(self._c_state, buffer)
        if length < 0:
            raise ValueError
        return buffer[:length]

    def __dealloc__(self):
        free(self._c_state)
        free(self._buffer)
