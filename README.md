[![Version](https://img.shields.io/pypi/v/b64-stream)](https://pypi.org/project/b64-stream)
[![Python versions](https://img.shields.io/pypi/pyversions/b64-stream)](https://pypi.org/project/b64-stream)
[![Build Status](https://travis-ci.org/ikrivosheev/py-base64.svg?branch=master)](https://travis-ci.org/ikrivosheev/py-base64)
[![License](https://img.shields.io/pypi/l/b64-stream)](https://pypi.org/project/b64-stream/)


# b64-stream

**b64-stream** is a Python binding for the [b64-stream](https://github.com/ikrivosheev/base64). 
This is Base64 stream encode/decode library.


### Installation

```
pip install b64-stream
```

### Getting started

**b64-stream** implements classes: 

1. `Base64StreamDecode`
2. `Base64StreamEncode`

Every class has:

0. **\_\_init\_\_(buffer_size: int = 2000)** - **buffer_size** used by create buffer for **update** method for new encoded/decoded chunk. 
1. **buffer_size** - size of buffer
3. **total** - total encoded/decoded bytes
4. **clear()** - reset state to initial
5. **update(chunk)** - processing chunk
6. **finalize()** - end of processing


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
from b64_stream import Base64StreamEncode

chunks = [b'1234567', b'1234567']
encoder = Base64StreamEncode()
result = []
for chunk in chunks:
    for r_chunk in encoder.update(chunk):
        result.append(r_chunk)
result.append(encoder.finalize())
```

### License
b64-stream is licensed under the Apache 2.0 License.
