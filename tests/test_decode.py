import pytest

from b64_stream import Base64StreamDecode


@pytest.mark.parametrize('chunks, buffer_size, chunks_count, chunk_size, expected', [
    pytest.param([b'MTIzNDU2Nw=='], 3, 3, 5, b'1234567', id='simple'),
    pytest.param([b'MTIzNDU2', b'NzEyMzQ1Njc='], 10, 3, 17, b'12345671234567', id='chunks'),
])
def test_decode(chunks, buffer_size, chunks_count, chunk_size, expected):
    decoder = Base64StreamDecode()
    result = []
    for chunk in chunks:
        for r_chunk in decoder.update(chunk):
            result.append(r_chunk)
    decoder.finalize()

    assert b''.join(result) == expected

