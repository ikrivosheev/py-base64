import pytest

from b64_stream import Base64StreamEncode


@pytest.mark.parametrize("chunks, expected", [
    ([b'AAA'], b'QUFB'),
    ([b'12345'], b'MTIzNDU='),
])
def test_decode(chunks, expected):
    encoder = Base64StreamEncode()
    result = []
    for chunk in chunks:
        for r_chunk in encoder.update(chunk):
            result.append(r_chunk)
    result.append(encoder.finalize())

    assert b''.join(result) == expected

