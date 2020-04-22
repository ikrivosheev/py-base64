from b64_stream import Base64StreamDecode


def test_noop():
    decoder = Base64StreamDecode()
    print([chunk for chunk in decoder.update(b'MTIzNAo=')])
    decoder.finalize()
    print(decoder.total)

test_noop()
