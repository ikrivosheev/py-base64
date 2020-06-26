[![Version](https://img.shields.io/pypi/v/b64-stream)](https://pypi.org/project/b64-stream)
[![Python versions](https://img.shields.io/pypi/pyversions/b64-stream)](https://pypi.org/project/b64-stream)
[![Build Status](https://travis-ci.org/ikrivosheev/py-base64.svg?branch=master)](https://travis-ci.org/ikrivosheev/py-base64)
[![License](https://img.shields.io/pypi/l/b64-stream)](https://pypi.org/project/b64-stream/)


# py-base64

**py-base64** is a Python binding for the [b64-stream](https://github.com/ikrivosheev/base64). 
This is Base64 stream encode/decode library.


### Installation

```
pip install b64-stream
```

### Usage examples

#### Decode data

```python
from b64_stream import Base64StreamDecode

chunks = [b'MTIzNDU2', b'NzEyMzQ1Njc=']
result = []
decoder = Base64StreamDecode()
for chunk in chunks:
    for r_chunk in decoder.update(chunk):
        result.append(r_chunk)
decoder.finalize()
```

#### Encode data

```python

chunks = [b'1234567', b'1234567']
encoder = Base64StreamEncode(buffer_size)
result = []
for chunk in chunks:
    for r_chunk in encoder.update(chunk):
        result.append(r_chunk)
result.append(encoder.finalize())
```

### License
b64-stream is licensed under the Apache 2.0 License.
