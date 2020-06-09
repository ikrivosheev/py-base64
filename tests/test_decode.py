import pytest

from b64_stream import Base64StreamDecode


@pytest.mark.parametrize("chunks, expected", [
    ([b'QUFB'], b'AAA'),
    ([b'Q\nQ=='], b'A'),
    ([b'MTI', b'zNDU2'], b'123456')
])
def test_decode(chunks, expected):
    decoder = Base64StreamDecode()
    result = []
    for chunk in chunks:
        for r_chunk in decoder.update(chunk):
            result.append(r_chunk)
    decoder.finalize()

    assert b''.join(result) == expected

