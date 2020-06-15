#cython: language_level=3

from cpython.object cimport PyObject
from cpython.memoryview cimport PyMemoryView_GET_BUFFER
from libc.stdlib cimport malloc, free

from b64_stream cimport _b64_stream


def chunks(data, count):
    cdef int i
    for i in range(0, len(data), count):
        yield data[i:i+count]


cdef class BufferedBase64Stream:
    cdef char* _buffer
    cdef size_t _buffer_size
    cdef size_t _chunk_size

    def __init__(self, size_t buffer_size = 2 ** 10):
        self._buffer_size = buffer_size
        self._buffer = <char*> malloc(sizeof(char) * buffer_size)
        if self._buffer is NULL:
            raise MemoryError()
    
    @property
    def buffer_size(self):
        return self._buffer_size

    @property
    def chunk_size(self):
        return self._chunk_size
    
    @property
    def total(self):
        raise NotImplementedError

    def clear(self):
        raise NotImplementedError

    def _process_chunk(self, chunk):
        raise NotImplementedError

    def finalize(self):
        raise NotImplementedError

    def update(self, data):
        with memoryview(data) as mem:
            for chunk in chunks(mem, self._chunk_size):
                yield self._process_chunk(chunk)

    def __dealloc__(self):
        free(self._buffer)


cdef class Base64StreamDecode(BufferedBase64Stream):
    cdef _b64_stream.b64_decode_state* _c_state

    def __init__(self, size_t buffer_size = 2 ** 10):
        super().__init__(buffer_size)
        self._c_state = <_b64_stream.b64_decode_state*> malloc(sizeof(_b64_stream.b64_decode_state))
        if self._c_state is NULL:
            raise MemoryError()
        _b64_stream.b64_stream_decode_init(self._c_state)
        
        self._chunk_size = (buffer_size + 3) // 4 * 3

    @property
    def total(self):
        return self._c_state.out_len

    def clear(self):
        _b64_stream.b64_stream_decode_init(self._c_state)

    def _process_chunk(self, chunk):
        cdef size_t length
        cdef Py_buffer* chunk_buffer = PyMemoryView_GET_BUFFER(chunk)

        length = _b64_stream.b64_stream_decode(
            self._c_state, 
            <char*> chunk_buffer.buf, 
            len(chunk), 
            self._buffer)

        return self._buffer[:length]
    
    def finalize(self):
        result = _b64_stream.b64_stream_decode_final(self._c_state)
        if not result:
            raise ValueError('Incorrect padding')
    
    def __dealloc__(self):
        free(self._c_state)


cdef class Base64StreamEncode(BufferedBase64Stream):
    cdef _b64_stream.b64_encode_state* _c_state

    def __init__(self, size_t buffer_size = 2 ** 10):
        super().__init__(buffer_size)
        self._c_state = <_b64_stream.b64_encode_state*> malloc(sizeof(_b64_stream.b64_encode_state))
        if self._c_state is NULL:
            raise MemoryError()
        _b64_stream.b64_stream_encode_init(self._c_state)
        
        self._chunk_size = ((buffer_size + 2) // 3 * 4) + 1
    
    @property
    def total(self):
        return self._c_state.out_len
    
    def clear(self):
        _b64_stream.b64_stream_encode_init(self._c_state)
    
    def _process_chunk(self, chunk):
        cdef size_t length
        cdef Py_buffer* chunk_buffer = PyMemoryView_GET_BUFFER(chunk)

        length = _b64_stream.b64_stream_encode(
            self._c_state, 
            <char*> chunk_buffer.buf, 
            len(chunk), 
            self._buffer)
        return self._buffer[:length]


    def finalize(self):
        cdef size_t length
        cdef char buffer[4]

        length = _b64_stream.b64_stream_encode_final(self._c_state, buffer)
        if length < 0:
            raise ValueError
        return buffer[:length]

    def __dealloc__(self):
        free(self._c_state)
