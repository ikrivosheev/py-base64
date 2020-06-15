import pytest

from b64_stream import Base64StreamEncode


@pytest.mark.parametrize('chunks, buffer_size, chunks_count, chunk_size, expected', [
    pytest.param([b'1234567'], 3, 3, 5, b'MTIzNDU2Nw==', id='simple'),
    pytest.param([b'1234567', b'1234567'], 10, 3, 17, b'MTIzNDU2NzEyMzQ1Njc=', id='chunks'),
])
def test_encode(chunks, buffer_size, chunks_count, chunk_size, expected):
    encoder = Base64StreamEncode(buffer_size)
    result = []
    for chunk in chunks:
        for r_chunk in encoder.update(chunk):
            result.append(r_chunk)
    result.append(encoder.finalize())
    
    assert encoder.chunk_size == chunk_size
    assert encoder.buffer_size == buffer_size
    assert encoder.total == len(expected)
    assert len(result) == chunks_count
    assert b''.join(result) == expected

