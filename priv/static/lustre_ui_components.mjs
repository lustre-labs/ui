// build/dev/javascript/prelude.mjs
var CustomType = class {
  withFields(fields) {
    let properties = Object.keys(this).map(
      (label) => label in fields ? fields[label] : this[label]
    );
    return new this.constructor(...properties);
  }
};
var List = class {
  static fromArray(array3, tail) {
    let t = tail || new Empty();
    for (let i = array3.length - 1; i >= 0; --i) {
      t = new NonEmpty(array3[i], t);
    }
    return t;
  }
  [Symbol.iterator]() {
    return new ListIterator(this);
  }
  toArray() {
    return [...this];
  }
  // @internal
  atLeastLength(desired) {
    let current = this;
    while (desired-- > 0 && current)
      current = current.tail;
    return current !== void 0;
  }
  // @internal
  hasLength(desired) {
    let current = this;
    while (desired-- > 0 && current)
      current = current.tail;
    return desired === -1 && current instanceof Empty;
  }
  // @internal
  countLength() {
    let current = this;
    let length2 = 0;
    while (current) {
      current = current.tail;
      length2++;
    }
    return length2 - 1;
  }
};
function prepend(element7, tail) {
  return new NonEmpty(element7, tail);
}
function toList(elements, tail) {
  return List.fromArray(elements, tail);
}
var ListIterator = class {
  #current;
  constructor(current) {
    this.#current = current;
  }
  next() {
    if (this.#current instanceof Empty) {
      return { done: true };
    } else {
      let { head, tail } = this.#current;
      this.#current = tail;
      return { value: head, done: false };
    }
  }
};
var Empty = class extends List {
};
var NonEmpty = class extends List {
  constructor(head, tail) {
    super();
    this.head = head;
    this.tail = tail;
  }
};
var BitArray = class {
  /**
   * The size in bits of this bit array's data.
   *
   * @type {number}
   */
  bitSize;
  /**
   * The size in bytes of this bit array's data. If this bit array doesn't store
   * a whole number of bytes then this value is rounded up.
   *
   * @type {number}
   */
  byteSize;
  /**
   * The number of unused high bits in the first byte of this bit array's
   * buffer prior to the start of its data. The value of any unused high bits is
   * undefined.
   *
   * The bit offset will be in the range 0-7.
   *
   * @type {number}
   */
  bitOffset;
  /**
   * The raw bytes that hold this bit array's data.
   *
   * If `bitOffset` is not zero then there are unused high bits in the first
   * byte of this buffer.
   *
   * If `bitOffset + bitSize` is not a multiple of 8 then there are unused low
   * bits in the last byte of this buffer.
   *
   * @type {Uint8Array}
   */
  rawBuffer;
  /**
   * Constructs a new bit array from a `Uint8Array`, an optional size in
   * bits, and an optional bit offset.
   *
   * If no bit size is specified it is taken as `buffer.length * 8`, i.e. all
   * bytes in the buffer make up the new bit array's data.
   *
   * If no bit offset is specified it defaults to zero, i.e. there are no unused
   * high bits in the first byte of the buffer.
   *
   * @param {Uint8Array} buffer
   * @param {number} [bitSize]
   * @param {number} [bitOffset]
   */
  constructor(buffer, bitSize, bitOffset) {
    if (!(buffer instanceof Uint8Array)) {
      throw globalThis.Error(
        "BitArray can only be constructed from a Uint8Array"
      );
    }
    this.bitSize = bitSize ?? buffer.length * 8;
    this.byteSize = Math.trunc((this.bitSize + 7) / 8);
    this.bitOffset = bitOffset ?? 0;
    if (this.bitSize < 0) {
      throw globalThis.Error(`BitArray bit size is invalid: ${this.bitSize}`);
    }
    if (this.bitOffset < 0 || this.bitOffset > 7) {
      throw globalThis.Error(
        `BitArray bit offset is invalid: ${this.bitOffset}`
      );
    }
    if (buffer.length !== Math.trunc((this.bitOffset + this.bitSize + 7) / 8)) {
      throw globalThis.Error("BitArray buffer length is invalid");
    }
    this.rawBuffer = buffer;
  }
  /**
   * Returns a specific byte in this bit array. If the byte index is out of
   * range then `undefined` is returned.
   *
   * When returning the final byte of a bit array with a bit size that's not a
   * multiple of 8, the content of the unused low bits are undefined.
   *
   * @param {number} index
   * @returns {number | undefined}
   */
  byteAt(index4) {
    if (index4 < 0 || index4 >= this.byteSize) {
      return void 0;
    }
    return bitArrayByteAt(this.rawBuffer, this.bitOffset, index4);
  }
  /** @internal */
  equals(other) {
    if (this.bitSize !== other.bitSize) {
      return false;
    }
    const wholeByteCount = Math.trunc(this.bitSize / 8);
    if (this.bitOffset === 0 && other.bitOffset === 0) {
      for (let i = 0; i < wholeByteCount; i++) {
        if (this.rawBuffer[i] !== other.rawBuffer[i]) {
          return false;
        }
      }
      const trailingBitsCount = this.bitSize % 8;
      if (trailingBitsCount) {
        const unusedLowBitCount = 8 - trailingBitsCount;
        if (this.rawBuffer[wholeByteCount] >> unusedLowBitCount !== other.rawBuffer[wholeByteCount] >> unusedLowBitCount) {
          return false;
        }
      }
    } else {
      for (let i = 0; i < wholeByteCount; i++) {
        const a = bitArrayByteAt(this.rawBuffer, this.bitOffset, i);
        const b = bitArrayByteAt(other.rawBuffer, other.bitOffset, i);
        if (a !== b) {
          return false;
        }
      }
      const trailingBitsCount = this.bitSize % 8;
      if (trailingBitsCount) {
        const a = bitArrayByteAt(
          this.rawBuffer,
          this.bitOffset,
          wholeByteCount
        );
        const b = bitArrayByteAt(
          other.rawBuffer,
          other.bitOffset,
          wholeByteCount
        );
        const unusedLowBitCount = 8 - trailingBitsCount;
        if (a >> unusedLowBitCount !== b >> unusedLowBitCount) {
          return false;
        }
      }
    }
    return true;
  }
  /**
   * Returns this bit array's internal buffer.
   *
   * @deprecated Use `BitArray.byteAt()` or `BitArray.rawBuffer` instead.
   *
   * @returns {Uint8Array}
   */
  get buffer() {
    bitArrayPrintDeprecationWarning(
      "buffer",
      "Use BitArray.byteAt() or BitArray.rawBuffer instead"
    );
    if (this.bitOffset !== 0 || this.bitSize % 8 !== 0) {
      throw new globalThis.Error(
        "BitArray.buffer does not support unaligned bit arrays"
      );
    }
    return this.rawBuffer;
  }
  /**
   * Returns the length in bytes of this bit array's internal buffer.
   *
   * @deprecated Use `BitArray.bitSize` or `BitArray.byteSize` instead.
   *
   * @returns {number}
   */
  get length() {
    bitArrayPrintDeprecationWarning(
      "length",
      "Use BitArray.bitSize or BitArray.byteSize instead"
    );
    if (this.bitOffset !== 0 || this.bitSize % 8 !== 0) {
      throw new globalThis.Error(
        "BitArray.length does not support unaligned bit arrays"
      );
    }
    return this.rawBuffer.length;
  }
};
function bitArrayByteAt(buffer, bitOffset, index4) {
  if (bitOffset === 0) {
    return buffer[index4] ?? 0;
  } else {
    const a = buffer[index4] << bitOffset & 255;
    const b = buffer[index4 + 1] >> 8 - bitOffset;
    return a | b;
  }
}
var UtfCodepoint = class {
  constructor(value2) {
    this.value = value2;
  }
};
var isBitArrayDeprecationMessagePrinted = {};
function bitArrayPrintDeprecationWarning(name6, message) {
  if (isBitArrayDeprecationMessagePrinted[name6]) {
    return;
  }
  console.warn(
    `Deprecated BitArray.${name6} property used in JavaScript FFI code. ${message}.`
  );
  isBitArrayDeprecationMessagePrinted[name6] = true;
}
function bitArraySlice(bitArray, start3, end) {
  end ??= bitArray.bitSize;
  bitArrayValidateRange(bitArray, start3, end);
  if (start3 === end) {
    return new BitArray(new Uint8Array());
  }
  if (start3 === 0 && end === bitArray.bitSize) {
    return bitArray;
  }
  start3 += bitArray.bitOffset;
  end += bitArray.bitOffset;
  const startByteIndex = Math.trunc(start3 / 8);
  const endByteIndex = Math.trunc((end + 7) / 8);
  const byteLength = endByteIndex - startByteIndex;
  let buffer;
  if (startByteIndex === 0 && byteLength === bitArray.rawBuffer.byteLength) {
    buffer = bitArray.rawBuffer;
  } else {
    buffer = new Uint8Array(
      bitArray.rawBuffer.buffer,
      bitArray.rawBuffer.byteOffset + startByteIndex,
      byteLength
    );
  }
  return new BitArray(buffer, end - start3, start3 % 8);
}
function bitArraySliceToInt(bitArray, start3, end, isBigEndian, isSigned) {
  bitArrayValidateRange(bitArray, start3, end);
  if (start3 === end) {
    return 0;
  }
  start3 += bitArray.bitOffset;
  end += bitArray.bitOffset;
  const isStartByteAligned = start3 % 8 === 0;
  const isEndByteAligned = end % 8 === 0;
  if (isStartByteAligned && isEndByteAligned) {
    return intFromAlignedSlice(
      bitArray,
      start3 / 8,
      end / 8,
      isBigEndian,
      isSigned
    );
  }
  const size3 = end - start3;
  const startByteIndex = Math.trunc(start3 / 8);
  const endByteIndex = Math.trunc((end - 1) / 8);
  if (startByteIndex == endByteIndex) {
    const mask2 = 255 >> start3 % 8;
    const unusedLowBitCount = (8 - end % 8) % 8;
    let value2 = (bitArray.rawBuffer[startByteIndex] & mask2) >> unusedLowBitCount;
    if (isSigned) {
      const highBit = 2 ** (size3 - 1);
      if (value2 >= highBit) {
        value2 -= highBit * 2;
      }
    }
    return value2;
  }
  if (size3 <= 53) {
    return intFromUnalignedSliceUsingNumber(
      bitArray.rawBuffer,
      start3,
      end,
      isBigEndian,
      isSigned
    );
  } else {
    return intFromUnalignedSliceUsingBigInt(
      bitArray.rawBuffer,
      start3,
      end,
      isBigEndian,
      isSigned
    );
  }
}
function intFromAlignedSlice(bitArray, start3, end, isBigEndian, isSigned) {
  const byteSize = end - start3;
  if (byteSize <= 6) {
    return intFromAlignedSliceUsingNumber(
      bitArray.rawBuffer,
      start3,
      end,
      isBigEndian,
      isSigned
    );
  } else {
    return intFromAlignedSliceUsingBigInt(
      bitArray.rawBuffer,
      start3,
      end,
      isBigEndian,
      isSigned
    );
  }
}
function intFromAlignedSliceUsingNumber(buffer, start3, end, isBigEndian, isSigned) {
  const byteSize = end - start3;
  let value2 = 0;
  if (isBigEndian) {
    for (let i = start3; i < end; i++) {
      value2 *= 256;
      value2 += buffer[i];
    }
  } else {
    for (let i = end - 1; i >= start3; i--) {
      value2 *= 256;
      value2 += buffer[i];
    }
  }
  if (isSigned) {
    const highBit = 2 ** (byteSize * 8 - 1);
    if (value2 >= highBit) {
      value2 -= highBit * 2;
    }
  }
  return value2;
}
function intFromAlignedSliceUsingBigInt(buffer, start3, end, isBigEndian, isSigned) {
  const byteSize = end - start3;
  let value2 = 0n;
  if (isBigEndian) {
    for (let i = start3; i < end; i++) {
      value2 *= 256n;
      value2 += BigInt(buffer[i]);
    }
  } else {
    for (let i = end - 1; i >= start3; i--) {
      value2 *= 256n;
      value2 += BigInt(buffer[i]);
    }
  }
  if (isSigned) {
    const highBit = 1n << BigInt(byteSize * 8 - 1);
    if (value2 >= highBit) {
      value2 -= highBit * 2n;
    }
  }
  return Number(value2);
}
function intFromUnalignedSliceUsingNumber(buffer, start3, end, isBigEndian, isSigned) {
  const isStartByteAligned = start3 % 8 === 0;
  let size3 = end - start3;
  let byteIndex = Math.trunc(start3 / 8);
  let value2 = 0;
  if (isBigEndian) {
    if (!isStartByteAligned) {
      const leadingBitsCount = 8 - start3 % 8;
      value2 = buffer[byteIndex++] & (1 << leadingBitsCount) - 1;
      size3 -= leadingBitsCount;
    }
    while (size3 >= 8) {
      value2 *= 256;
      value2 += buffer[byteIndex++];
      size3 -= 8;
    }
    if (size3 > 0) {
      value2 *= 2 ** size3;
      value2 += buffer[byteIndex] >> 8 - size3;
    }
  } else {
    if (isStartByteAligned) {
      let size4 = end - start3;
      let scale = 1;
      while (size4 >= 8) {
        value2 += buffer[byteIndex++] * scale;
        scale *= 256;
        size4 -= 8;
      }
      value2 += (buffer[byteIndex] >> 8 - size4) * scale;
    } else {
      const highBitsCount = start3 % 8;
      const lowBitsCount = 8 - highBitsCount;
      let size4 = end - start3;
      let scale = 1;
      while (size4 >= 8) {
        const byte = buffer[byteIndex] << highBitsCount | buffer[byteIndex + 1] >> lowBitsCount;
        value2 += (byte & 255) * scale;
        scale *= 256;
        size4 -= 8;
        byteIndex++;
      }
      if (size4 > 0) {
        const lowBitsUsed = size4 - Math.max(0, size4 - lowBitsCount);
        let trailingByte = (buffer[byteIndex] & (1 << lowBitsCount) - 1) >> lowBitsCount - lowBitsUsed;
        size4 -= lowBitsUsed;
        if (size4 > 0) {
          trailingByte *= 2 ** size4;
          trailingByte += buffer[byteIndex + 1] >> 8 - size4;
        }
        value2 += trailingByte * scale;
      }
    }
  }
  if (isSigned) {
    const highBit = 2 ** (end - start3 - 1);
    if (value2 >= highBit) {
      value2 -= highBit * 2;
    }
  }
  return value2;
}
function intFromUnalignedSliceUsingBigInt(buffer, start3, end, isBigEndian, isSigned) {
  const isStartByteAligned = start3 % 8 === 0;
  let size3 = end - start3;
  let byteIndex = Math.trunc(start3 / 8);
  let value2 = 0n;
  if (isBigEndian) {
    if (!isStartByteAligned) {
      const leadingBitsCount = 8 - start3 % 8;
      value2 = BigInt(buffer[byteIndex++] & (1 << leadingBitsCount) - 1);
      size3 -= leadingBitsCount;
    }
    while (size3 >= 8) {
      value2 *= 256n;
      value2 += BigInt(buffer[byteIndex++]);
      size3 -= 8;
    }
    if (size3 > 0) {
      value2 <<= BigInt(size3);
      value2 += BigInt(buffer[byteIndex] >> 8 - size3);
    }
  } else {
    if (isStartByteAligned) {
      let size4 = end - start3;
      let shift = 0n;
      while (size4 >= 8) {
        value2 += BigInt(buffer[byteIndex++]) << shift;
        shift += 8n;
        size4 -= 8;
      }
      value2 += BigInt(buffer[byteIndex] >> 8 - size4) << shift;
    } else {
      const highBitsCount = start3 % 8;
      const lowBitsCount = 8 - highBitsCount;
      let size4 = end - start3;
      let shift = 0n;
      while (size4 >= 8) {
        const byte = buffer[byteIndex] << highBitsCount | buffer[byteIndex + 1] >> lowBitsCount;
        value2 += BigInt(byte & 255) << shift;
        shift += 8n;
        size4 -= 8;
        byteIndex++;
      }
      if (size4 > 0) {
        const lowBitsUsed = size4 - Math.max(0, size4 - lowBitsCount);
        let trailingByte = (buffer[byteIndex] & (1 << lowBitsCount) - 1) >> lowBitsCount - lowBitsUsed;
        size4 -= lowBitsUsed;
        if (size4 > 0) {
          trailingByte <<= size4;
          trailingByte += buffer[byteIndex + 1] >> 8 - size4;
        }
        value2 += BigInt(trailingByte) << shift;
      }
    }
  }
  if (isSigned) {
    const highBit = 2n ** BigInt(end - start3 - 1);
    if (value2 >= highBit) {
      value2 -= highBit * 2n;
    }
  }
  return Number(value2);
}
function bitArrayValidateRange(bitArray, start3, end) {
  if (start3 < 0 || start3 > bitArray.bitSize || end < start3 || end > bitArray.bitSize) {
    const msg = `Invalid bit array slice: start = ${start3}, end = ${end}, bit size = ${bitArray.bitSize}`;
    throw new globalThis.Error(msg);
  }
}
var Result = class _Result extends CustomType {
  // @internal
  static isResult(data) {
    return data instanceof _Result;
  }
};
var Ok = class extends Result {
  constructor(value2) {
    super();
    this[0] = value2;
  }
  // @internal
  isOk() {
    return true;
  }
};
var Error = class extends Result {
  constructor(detail) {
    super();
    this[0] = detail;
  }
  // @internal
  isOk() {
    return false;
  }
};
function isEqual(x, y) {
  let values3 = [x, y];
  while (values3.length) {
    let a = values3.pop();
    let b = values3.pop();
    if (a === b)
      continue;
    if (!isObject(a) || !isObject(b))
      return false;
    let unequal = !structurallyCompatibleObjects(a, b) || unequalDates(a, b) || unequalBuffers(a, b) || unequalArrays(a, b) || unequalMaps(a, b) || unequalSets(a, b) || unequalRegExps(a, b);
    if (unequal)
      return false;
    const proto = Object.getPrototypeOf(a);
    if (proto !== null && typeof proto.equals === "function") {
      try {
        if (a.equals(b))
          continue;
        else
          return false;
      } catch {
      }
    }
    let [keys2, get3] = getters(a);
    for (let k of keys2(a)) {
      values3.push(get3(a, k), get3(b, k));
    }
  }
  return true;
}
function getters(object4) {
  if (object4 instanceof Map) {
    return [(x) => x.keys(), (x, y) => x.get(y)];
  } else {
    let extra = object4 instanceof globalThis.Error ? ["message"] : [];
    return [(x) => [...extra, ...Object.keys(x)], (x, y) => x[y]];
  }
}
function unequalDates(a, b) {
  return a instanceof Date && (a > b || a < b);
}
function unequalBuffers(a, b) {
  return !(a instanceof BitArray) && a.buffer instanceof ArrayBuffer && a.BYTES_PER_ELEMENT && !(a.byteLength === b.byteLength && a.every((n, i) => n === b[i]));
}
function unequalArrays(a, b) {
  return Array.isArray(a) && a.length !== b.length;
}
function unequalMaps(a, b) {
  return a instanceof Map && a.size !== b.size;
}
function unequalSets(a, b) {
  return a instanceof Set && (a.size != b.size || [...a].some((e) => !b.has(e)));
}
function unequalRegExps(a, b) {
  return a instanceof RegExp && (a.source !== b.source || a.flags !== b.flags);
}
function isObject(a) {
  return typeof a === "object" && a !== null;
}
function structurallyCompatibleObjects(a, b) {
  if (typeof a !== "object" && typeof b !== "object" && (!a || !b))
    return false;
  let nonstructural = [Promise, WeakSet, WeakMap, Function];
  if (nonstructural.some((c) => a instanceof c))
    return false;
  return a.constructor === b.constructor;
}
function makeError(variant, file, module, line, fn, message, extra) {
  let error = new globalThis.Error(message);
  error.gleam_error = variant;
  error.file = file;
  error.module = module;
  error.line = line;
  error.function = fn;
  error.fn = fn;
  for (let k in extra)
    error[k] = extra[k];
  return error;
}

// build/dev/javascript/gleam_stdlib/gleam/order.mjs
var Lt = class extends CustomType {
};
var Eq = class extends CustomType {
};
var Gt = class extends CustomType {
};

// build/dev/javascript/gleam_stdlib/gleam/option.mjs
var Some = class extends CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
};
var None = class extends CustomType {
};
function from_result(result) {
  if (result instanceof Ok) {
    let a = result[0];
    return new Some(a);
  } else {
    return new None();
  }
}

// build/dev/javascript/gleam_stdlib/dict.mjs
var referenceMap = /* @__PURE__ */ new WeakMap();
var tempDataView = /* @__PURE__ */ new DataView(
  /* @__PURE__ */ new ArrayBuffer(8)
);
var referenceUID = 0;
function hashByReference(o) {
  const known = referenceMap.get(o);
  if (known !== void 0) {
    return known;
  }
  const hash = referenceUID++;
  if (referenceUID === 2147483647) {
    referenceUID = 0;
  }
  referenceMap.set(o, hash);
  return hash;
}
function hashMerge(a, b) {
  return a ^ b + 2654435769 + (a << 6) + (a >> 2) | 0;
}
function hashString(s) {
  let hash = 0;
  const len = s.length;
  for (let i = 0; i < len; i++) {
    hash = Math.imul(31, hash) + s.charCodeAt(i) | 0;
  }
  return hash;
}
function hashNumber(n) {
  tempDataView.setFloat64(0, n);
  const i = tempDataView.getInt32(0);
  const j = tempDataView.getInt32(4);
  return Math.imul(73244475, i >> 16 ^ i) ^ j;
}
function hashBigInt(n) {
  return hashString(n.toString());
}
function hashObject(o) {
  const proto = Object.getPrototypeOf(o);
  if (proto !== null && typeof proto.hashCode === "function") {
    try {
      const code = o.hashCode(o);
      if (typeof code === "number") {
        return code;
      }
    } catch {
    }
  }
  if (o instanceof Promise || o instanceof WeakSet || o instanceof WeakMap) {
    return hashByReference(o);
  }
  if (o instanceof Date) {
    return hashNumber(o.getTime());
  }
  let h = 0;
  if (o instanceof ArrayBuffer) {
    o = new Uint8Array(o);
  }
  if (Array.isArray(o) || o instanceof Uint8Array) {
    for (let i = 0; i < o.length; i++) {
      h = Math.imul(31, h) + getHash(o[i]) | 0;
    }
  } else if (o instanceof Set) {
    o.forEach((v) => {
      h = h + getHash(v) | 0;
    });
  } else if (o instanceof Map) {
    o.forEach((v, k) => {
      h = h + hashMerge(getHash(v), getHash(k)) | 0;
    });
  } else {
    const keys2 = Object.keys(o);
    for (let i = 0; i < keys2.length; i++) {
      const k = keys2[i];
      const v = o[k];
      h = h + hashMerge(getHash(v), hashString(k)) | 0;
    }
  }
  return h;
}
function getHash(u) {
  if (u === null)
    return 1108378658;
  if (u === void 0)
    return 1108378659;
  if (u === true)
    return 1108378657;
  if (u === false)
    return 1108378656;
  switch (typeof u) {
    case "number":
      return hashNumber(u);
    case "string":
      return hashString(u);
    case "bigint":
      return hashBigInt(u);
    case "object":
      return hashObject(u);
    case "symbol":
      return hashByReference(u);
    case "function":
      return hashByReference(u);
    default:
      return 0;
  }
}
var SHIFT = 5;
var BUCKET_SIZE = Math.pow(2, SHIFT);
var MASK = BUCKET_SIZE - 1;
var MAX_INDEX_NODE = BUCKET_SIZE / 2;
var MIN_ARRAY_NODE = BUCKET_SIZE / 4;
var ENTRY = 0;
var ARRAY_NODE = 1;
var INDEX_NODE = 2;
var COLLISION_NODE = 3;
var EMPTY = {
  type: INDEX_NODE,
  bitmap: 0,
  array: []
};
function mask(hash, shift) {
  return hash >>> shift & MASK;
}
function bitpos(hash, shift) {
  return 1 << mask(hash, shift);
}
function bitcount(x) {
  x -= x >> 1 & 1431655765;
  x = (x & 858993459) + (x >> 2 & 858993459);
  x = x + (x >> 4) & 252645135;
  x += x >> 8;
  x += x >> 16;
  return x & 127;
}
function index(bitmap, bit) {
  return bitcount(bitmap & bit - 1);
}
function cloneAndSet(arr, at, val) {
  const len = arr.length;
  const out = new Array(len);
  for (let i = 0; i < len; ++i) {
    out[i] = arr[i];
  }
  out[at] = val;
  return out;
}
function spliceIn(arr, at, val) {
  const len = arr.length;
  const out = new Array(len + 1);
  let i = 0;
  let g = 0;
  while (i < at) {
    out[g++] = arr[i++];
  }
  out[g++] = val;
  while (i < len) {
    out[g++] = arr[i++];
  }
  return out;
}
function spliceOut(arr, at) {
  const len = arr.length;
  const out = new Array(len - 1);
  let i = 0;
  let g = 0;
  while (i < at) {
    out[g++] = arr[i++];
  }
  ++i;
  while (i < len) {
    out[g++] = arr[i++];
  }
  return out;
}
function createNode(shift, key1, val1, key2hash, key2, val2) {
  const key1hash = getHash(key1);
  if (key1hash === key2hash) {
    return {
      type: COLLISION_NODE,
      hash: key1hash,
      array: [
        { type: ENTRY, k: key1, v: val1 },
        { type: ENTRY, k: key2, v: val2 }
      ]
    };
  }
  const addedLeaf = { val: false };
  return assoc(
    assocIndex(EMPTY, shift, key1hash, key1, val1, addedLeaf),
    shift,
    key2hash,
    key2,
    val2,
    addedLeaf
  );
}
function assoc(root3, shift, hash, key, val, addedLeaf) {
  switch (root3.type) {
    case ARRAY_NODE:
      return assocArray(root3, shift, hash, key, val, addedLeaf);
    case INDEX_NODE:
      return assocIndex(root3, shift, hash, key, val, addedLeaf);
    case COLLISION_NODE:
      return assocCollision(root3, shift, hash, key, val, addedLeaf);
  }
}
function assocArray(root3, shift, hash, key, val, addedLeaf) {
  const idx = mask(hash, shift);
  const node = root3.array[idx];
  if (node === void 0) {
    addedLeaf.val = true;
    return {
      type: ARRAY_NODE,
      size: root3.size + 1,
      array: cloneAndSet(root3.array, idx, { type: ENTRY, k: key, v: val })
    };
  }
  if (node.type === ENTRY) {
    if (isEqual(key, node.k)) {
      if (val === node.v) {
        return root3;
      }
      return {
        type: ARRAY_NODE,
        size: root3.size,
        array: cloneAndSet(root3.array, idx, {
          type: ENTRY,
          k: key,
          v: val
        })
      };
    }
    addedLeaf.val = true;
    return {
      type: ARRAY_NODE,
      size: root3.size,
      array: cloneAndSet(
        root3.array,
        idx,
        createNode(shift + SHIFT, node.k, node.v, hash, key, val)
      )
    };
  }
  const n = assoc(node, shift + SHIFT, hash, key, val, addedLeaf);
  if (n === node) {
    return root3;
  }
  return {
    type: ARRAY_NODE,
    size: root3.size,
    array: cloneAndSet(root3.array, idx, n)
  };
}
function assocIndex(root3, shift, hash, key, val, addedLeaf) {
  const bit = bitpos(hash, shift);
  const idx = index(root3.bitmap, bit);
  if ((root3.bitmap & bit) !== 0) {
    const node = root3.array[idx];
    if (node.type !== ENTRY) {
      const n = assoc(node, shift + SHIFT, hash, key, val, addedLeaf);
      if (n === node) {
        return root3;
      }
      return {
        type: INDEX_NODE,
        bitmap: root3.bitmap,
        array: cloneAndSet(root3.array, idx, n)
      };
    }
    const nodeKey = node.k;
    if (isEqual(key, nodeKey)) {
      if (val === node.v) {
        return root3;
      }
      return {
        type: INDEX_NODE,
        bitmap: root3.bitmap,
        array: cloneAndSet(root3.array, idx, {
          type: ENTRY,
          k: key,
          v: val
        })
      };
    }
    addedLeaf.val = true;
    return {
      type: INDEX_NODE,
      bitmap: root3.bitmap,
      array: cloneAndSet(
        root3.array,
        idx,
        createNode(shift + SHIFT, nodeKey, node.v, hash, key, val)
      )
    };
  } else {
    const n = root3.array.length;
    if (n >= MAX_INDEX_NODE) {
      const nodes = new Array(32);
      const jdx = mask(hash, shift);
      nodes[jdx] = assocIndex(EMPTY, shift + SHIFT, hash, key, val, addedLeaf);
      let j = 0;
      let bitmap = root3.bitmap;
      for (let i = 0; i < 32; i++) {
        if ((bitmap & 1) !== 0) {
          const node = root3.array[j++];
          nodes[i] = node;
        }
        bitmap = bitmap >>> 1;
      }
      return {
        type: ARRAY_NODE,
        size: n + 1,
        array: nodes
      };
    } else {
      const newArray = spliceIn(root3.array, idx, {
        type: ENTRY,
        k: key,
        v: val
      });
      addedLeaf.val = true;
      return {
        type: INDEX_NODE,
        bitmap: root3.bitmap | bit,
        array: newArray
      };
    }
  }
}
function assocCollision(root3, shift, hash, key, val, addedLeaf) {
  if (hash === root3.hash) {
    const idx = collisionIndexOf(root3, key);
    if (idx !== -1) {
      const entry = root3.array[idx];
      if (entry.v === val) {
        return root3;
      }
      return {
        type: COLLISION_NODE,
        hash,
        array: cloneAndSet(root3.array, idx, { type: ENTRY, k: key, v: val })
      };
    }
    const size3 = root3.array.length;
    addedLeaf.val = true;
    return {
      type: COLLISION_NODE,
      hash,
      array: cloneAndSet(root3.array, size3, { type: ENTRY, k: key, v: val })
    };
  }
  return assoc(
    {
      type: INDEX_NODE,
      bitmap: bitpos(root3.hash, shift),
      array: [root3]
    },
    shift,
    hash,
    key,
    val,
    addedLeaf
  );
}
function collisionIndexOf(root3, key) {
  const size3 = root3.array.length;
  for (let i = 0; i < size3; i++) {
    if (isEqual(key, root3.array[i].k)) {
      return i;
    }
  }
  return -1;
}
function find(root3, shift, hash, key) {
  switch (root3.type) {
    case ARRAY_NODE:
      return findArray(root3, shift, hash, key);
    case INDEX_NODE:
      return findIndex(root3, shift, hash, key);
    case COLLISION_NODE:
      return findCollision(root3, key);
  }
}
function findArray(root3, shift, hash, key) {
  const idx = mask(hash, shift);
  const node = root3.array[idx];
  if (node === void 0) {
    return void 0;
  }
  if (node.type !== ENTRY) {
    return find(node, shift + SHIFT, hash, key);
  }
  if (isEqual(key, node.k)) {
    return node;
  }
  return void 0;
}
function findIndex(root3, shift, hash, key) {
  const bit = bitpos(hash, shift);
  if ((root3.bitmap & bit) === 0) {
    return void 0;
  }
  const idx = index(root3.bitmap, bit);
  const node = root3.array[idx];
  if (node.type !== ENTRY) {
    return find(node, shift + SHIFT, hash, key);
  }
  if (isEqual(key, node.k)) {
    return node;
  }
  return void 0;
}
function findCollision(root3, key) {
  const idx = collisionIndexOf(root3, key);
  if (idx < 0) {
    return void 0;
  }
  return root3.array[idx];
}
function without(root3, shift, hash, key) {
  switch (root3.type) {
    case ARRAY_NODE:
      return withoutArray(root3, shift, hash, key);
    case INDEX_NODE:
      return withoutIndex(root3, shift, hash, key);
    case COLLISION_NODE:
      return withoutCollision(root3, key);
  }
}
function withoutArray(root3, shift, hash, key) {
  const idx = mask(hash, shift);
  const node = root3.array[idx];
  if (node === void 0) {
    return root3;
  }
  let n = void 0;
  if (node.type === ENTRY) {
    if (!isEqual(node.k, key)) {
      return root3;
    }
  } else {
    n = without(node, shift + SHIFT, hash, key);
    if (n === node) {
      return root3;
    }
  }
  if (n === void 0) {
    if (root3.size <= MIN_ARRAY_NODE) {
      const arr = root3.array;
      const out = new Array(root3.size - 1);
      let i = 0;
      let j = 0;
      let bitmap = 0;
      while (i < idx) {
        const nv = arr[i];
        if (nv !== void 0) {
          out[j] = nv;
          bitmap |= 1 << i;
          ++j;
        }
        ++i;
      }
      ++i;
      while (i < arr.length) {
        const nv = arr[i];
        if (nv !== void 0) {
          out[j] = nv;
          bitmap |= 1 << i;
          ++j;
        }
        ++i;
      }
      return {
        type: INDEX_NODE,
        bitmap,
        array: out
      };
    }
    return {
      type: ARRAY_NODE,
      size: root3.size - 1,
      array: cloneAndSet(root3.array, idx, n)
    };
  }
  return {
    type: ARRAY_NODE,
    size: root3.size,
    array: cloneAndSet(root3.array, idx, n)
  };
}
function withoutIndex(root3, shift, hash, key) {
  const bit = bitpos(hash, shift);
  if ((root3.bitmap & bit) === 0) {
    return root3;
  }
  const idx = index(root3.bitmap, bit);
  const node = root3.array[idx];
  if (node.type !== ENTRY) {
    const n = without(node, shift + SHIFT, hash, key);
    if (n === node) {
      return root3;
    }
    if (n !== void 0) {
      return {
        type: INDEX_NODE,
        bitmap: root3.bitmap,
        array: cloneAndSet(root3.array, idx, n)
      };
    }
    if (root3.bitmap === bit) {
      return void 0;
    }
    return {
      type: INDEX_NODE,
      bitmap: root3.bitmap ^ bit,
      array: spliceOut(root3.array, idx)
    };
  }
  if (isEqual(key, node.k)) {
    if (root3.bitmap === bit) {
      return void 0;
    }
    return {
      type: INDEX_NODE,
      bitmap: root3.bitmap ^ bit,
      array: spliceOut(root3.array, idx)
    };
  }
  return root3;
}
function withoutCollision(root3, key) {
  const idx = collisionIndexOf(root3, key);
  if (idx < 0) {
    return root3;
  }
  if (root3.array.length === 1) {
    return void 0;
  }
  return {
    type: COLLISION_NODE,
    hash: root3.hash,
    array: spliceOut(root3.array, idx)
  };
}
function forEach(root3, fn) {
  if (root3 === void 0) {
    return;
  }
  const items = root3.array;
  const size3 = items.length;
  for (let i = 0; i < size3; i++) {
    const item = items[i];
    if (item === void 0) {
      continue;
    }
    if (item.type === ENTRY) {
      fn(item.v, item.k);
      continue;
    }
    forEach(item, fn);
  }
}
var Dict = class _Dict {
  /**
   * @template V
   * @param {Record<string,V>} o
   * @returns {Dict<string,V>}
   */
  static fromObject(o) {
    const keys2 = Object.keys(o);
    let m = _Dict.new();
    for (let i = 0; i < keys2.length; i++) {
      const k = keys2[i];
      m = m.set(k, o[k]);
    }
    return m;
  }
  /**
   * @template K,V
   * @param {Map<K,V>} o
   * @returns {Dict<K,V>}
   */
  static fromMap(o) {
    let m = _Dict.new();
    o.forEach((v, k) => {
      m = m.set(k, v);
    });
    return m;
  }
  static new() {
    return new _Dict(void 0, 0);
  }
  /**
   * @param {undefined | Node<K,V>} root
   * @param {number} size
   */
  constructor(root3, size3) {
    this.root = root3;
    this.size = size3;
  }
  /**
   * @template NotFound
   * @param {K} key
   * @param {NotFound} notFound
   * @returns {NotFound | V}
   */
  get(key, notFound) {
    if (this.root === void 0) {
      return notFound;
    }
    const found = find(this.root, 0, getHash(key), key);
    if (found === void 0) {
      return notFound;
    }
    return found.v;
  }
  /**
   * @param {K} key
   * @param {V} val
   * @returns {Dict<K,V>}
   */
  set(key, val) {
    const addedLeaf = { val: false };
    const root3 = this.root === void 0 ? EMPTY : this.root;
    const newRoot = assoc(root3, 0, getHash(key), key, val, addedLeaf);
    if (newRoot === this.root) {
      return this;
    }
    return new _Dict(newRoot, addedLeaf.val ? this.size + 1 : this.size);
  }
  /**
   * @param {K} key
   * @returns {Dict<K,V>}
   */
  delete(key) {
    if (this.root === void 0) {
      return this;
    }
    const newRoot = without(this.root, 0, getHash(key), key);
    if (newRoot === this.root) {
      return this;
    }
    if (newRoot === void 0) {
      return _Dict.new();
    }
    return new _Dict(newRoot, this.size - 1);
  }
  /**
   * @param {K} key
   * @returns {boolean}
   */
  has(key) {
    if (this.root === void 0) {
      return false;
    }
    return find(this.root, 0, getHash(key), key) !== void 0;
  }
  /**
   * @returns {[K,V][]}
   */
  entries() {
    if (this.root === void 0) {
      return [];
    }
    const result = [];
    this.forEach((v, k) => result.push([k, v]));
    return result;
  }
  /**
   *
   * @param {(val:V,key:K)=>void} fn
   */
  forEach(fn) {
    forEach(this.root, fn);
  }
  hashCode() {
    let h = 0;
    this.forEach((v, k) => {
      h = h + hashMerge(getHash(v), getHash(k)) | 0;
    });
    return h;
  }
  /**
   * @param {unknown} o
   * @returns {boolean}
   */
  equals(o) {
    if (!(o instanceof _Dict) || this.size !== o.size) {
      return false;
    }
    try {
      this.forEach((v, k) => {
        if (!isEqual(o.get(k, !v), v)) {
          throw unequalDictSymbol;
        }
      });
      return true;
    } catch (e) {
      if (e === unequalDictSymbol) {
        return false;
      }
      throw e;
    }
  }
};
var unequalDictSymbol = /* @__PURE__ */ Symbol();

// build/dev/javascript/gleam_stdlib/gleam/dict.mjs
function do_has_key(key, dict2) {
  return !isEqual(map_get(dict2, key), new Error(void 0));
}
function has_key(dict2, key) {
  return do_has_key(key, dict2);
}
function insert(dict2, key, value2) {
  return map_insert(key, value2, dict2);
}
function delete$(dict2, key) {
  return map_remove(key, dict2);
}
function fold_loop(loop$list, loop$initial, loop$fun) {
  while (true) {
    let list4 = loop$list;
    let initial = loop$initial;
    let fun = loop$fun;
    if (list4 instanceof Empty) {
      return initial;
    } else {
      let rest = list4.tail;
      let k = list4.head[0];
      let v = list4.head[1];
      loop$list = rest;
      loop$initial = fun(initial, k, v);
      loop$fun = fun;
    }
  }
}
function fold(dict2, initial, fun) {
  return fold_loop(map_to_list(dict2), initial, fun);
}
function do_filter(f, dict2) {
  let insert$1 = (dict3, k, v) => {
    let $ = f(k, v);
    if ($) {
      return insert(dict3, k, v);
    } else {
      return dict3;
    }
  };
  return fold(dict2, new_map(), insert$1);
}
function filter(dict2, predicate) {
  return do_filter(predicate, dict2);
}

// build/dev/javascript/gleam_stdlib/gleam/dynamic.mjs
function nil() {
  return identity(void 0);
}

// build/dev/javascript/gleam_stdlib/gleam/list.mjs
var Ascending = class extends CustomType {
};
var Descending = class extends CustomType {
};
function reverse_and_prepend(loop$prefix, loop$suffix) {
  while (true) {
    let prefix = loop$prefix;
    let suffix = loop$suffix;
    if (prefix instanceof Empty) {
      return suffix;
    } else {
      let first$1 = prefix.head;
      let rest$1 = prefix.tail;
      loop$prefix = rest$1;
      loop$suffix = prepend(first$1, suffix);
    }
  }
}
function reverse(list4) {
  return reverse_and_prepend(list4, toList([]));
}
function first(list4) {
  if (list4 instanceof Empty) {
    return new Error(void 0);
  } else {
    let first$1 = list4.head;
    return new Ok(first$1);
  }
}
function filter_loop(loop$list, loop$fun, loop$acc) {
  while (true) {
    let list4 = loop$list;
    let fun = loop$fun;
    let acc = loop$acc;
    if (list4 instanceof Empty) {
      return reverse(acc);
    } else {
      let first$1 = list4.head;
      let rest$1 = list4.tail;
      let _block;
      let $ = fun(first$1);
      if ($) {
        _block = prepend(first$1, acc);
      } else {
        _block = acc;
      }
      let new_acc = _block;
      loop$list = rest$1;
      loop$fun = fun;
      loop$acc = new_acc;
    }
  }
}
function filter2(list4, predicate) {
  return filter_loop(list4, predicate, toList([]));
}
function filter_map_loop(loop$list, loop$fun, loop$acc) {
  while (true) {
    let list4 = loop$list;
    let fun = loop$fun;
    let acc = loop$acc;
    if (list4 instanceof Empty) {
      return reverse(acc);
    } else {
      let first$1 = list4.head;
      let rest$1 = list4.tail;
      let _block;
      let $ = fun(first$1);
      if ($ instanceof Ok) {
        let first$2 = $[0];
        _block = prepend(first$2, acc);
      } else {
        _block = acc;
      }
      let new_acc = _block;
      loop$list = rest$1;
      loop$fun = fun;
      loop$acc = new_acc;
    }
  }
}
function filter_map(list4, fun) {
  return filter_map_loop(list4, fun, toList([]));
}
function map_loop(loop$list, loop$fun, loop$acc) {
  while (true) {
    let list4 = loop$list;
    let fun = loop$fun;
    let acc = loop$acc;
    if (list4 instanceof Empty) {
      return reverse(acc);
    } else {
      let first$1 = list4.head;
      let rest$1 = list4.tail;
      loop$list = rest$1;
      loop$fun = fun;
      loop$acc = prepend(fun(first$1), acc);
    }
  }
}
function map(list4, fun) {
  return map_loop(list4, fun, toList([]));
}
function try_map_loop(loop$list, loop$fun, loop$acc) {
  while (true) {
    let list4 = loop$list;
    let fun = loop$fun;
    let acc = loop$acc;
    if (list4 instanceof Empty) {
      return new Ok(reverse(acc));
    } else {
      let first$1 = list4.head;
      let rest$1 = list4.tail;
      let $ = fun(first$1);
      if ($ instanceof Ok) {
        let first$2 = $[0];
        loop$list = rest$1;
        loop$fun = fun;
        loop$acc = prepend(first$2, acc);
      } else {
        let error = $[0];
        return new Error(error);
      }
    }
  }
}
function try_map(list4, fun) {
  return try_map_loop(list4, fun, toList([]));
}
function append_loop(loop$first, loop$second) {
  while (true) {
    let first3 = loop$first;
    let second2 = loop$second;
    if (first3 instanceof Empty) {
      return second2;
    } else {
      let first$1 = first3.head;
      let rest$1 = first3.tail;
      loop$first = rest$1;
      loop$second = prepend(first$1, second2);
    }
  }
}
function append(first3, second2) {
  return append_loop(reverse(first3), second2);
}
function prepend2(list4, item) {
  return prepend(item, list4);
}
function fold2(loop$list, loop$initial, loop$fun) {
  while (true) {
    let list4 = loop$list;
    let initial = loop$initial;
    let fun = loop$fun;
    if (list4 instanceof Empty) {
      return initial;
    } else {
      let first$1 = list4.head;
      let rest$1 = list4.tail;
      loop$list = rest$1;
      loop$initial = fun(initial, first$1);
      loop$fun = fun;
    }
  }
}
function fold_right(list4, initial, fun) {
  if (list4 instanceof Empty) {
    return initial;
  } else {
    let first$1 = list4.head;
    let rest$1 = list4.tail;
    return fun(fold_right(rest$1, initial, fun), first$1);
  }
}
function index_fold_loop(loop$over, loop$acc, loop$with, loop$index) {
  while (true) {
    let over = loop$over;
    let acc = loop$acc;
    let with$ = loop$with;
    let index4 = loop$index;
    if (over instanceof Empty) {
      return acc;
    } else {
      let first$1 = over.head;
      let rest$1 = over.tail;
      loop$over = rest$1;
      loop$acc = with$(acc, first$1, index4);
      loop$with = with$;
      loop$index = index4 + 1;
    }
  }
}
function index_fold(list4, initial, fun) {
  return index_fold_loop(list4, initial, fun, 0);
}
function find2(loop$list, loop$is_desired) {
  while (true) {
    let list4 = loop$list;
    let is_desired = loop$is_desired;
    if (list4 instanceof Empty) {
      return new Error(void 0);
    } else {
      let first$1 = list4.head;
      let rest$1 = list4.tail;
      let $ = is_desired(first$1);
      if ($) {
        return new Ok(first$1);
      } else {
        loop$list = rest$1;
        loop$is_desired = is_desired;
      }
    }
  }
}
function sequences(loop$list, loop$compare, loop$growing, loop$direction, loop$prev, loop$acc) {
  while (true) {
    let list4 = loop$list;
    let compare4 = loop$compare;
    let growing = loop$growing;
    let direction = loop$direction;
    let prev = loop$prev;
    let acc = loop$acc;
    let growing$1 = prepend(prev, growing);
    if (list4 instanceof Empty) {
      if (direction instanceof Ascending) {
        return prepend(reverse(growing$1), acc);
      } else {
        return prepend(growing$1, acc);
      }
    } else {
      let new$1 = list4.head;
      let rest$1 = list4.tail;
      let $ = compare4(prev, new$1);
      if (direction instanceof Ascending) {
        if ($ instanceof Lt) {
          loop$list = rest$1;
          loop$compare = compare4;
          loop$growing = growing$1;
          loop$direction = direction;
          loop$prev = new$1;
          loop$acc = acc;
        } else if ($ instanceof Eq) {
          loop$list = rest$1;
          loop$compare = compare4;
          loop$growing = growing$1;
          loop$direction = direction;
          loop$prev = new$1;
          loop$acc = acc;
        } else {
          let _block;
          if (direction instanceof Ascending) {
            _block = prepend(reverse(growing$1), acc);
          } else {
            _block = prepend(growing$1, acc);
          }
          let acc$1 = _block;
          if (rest$1 instanceof Empty) {
            return prepend(toList([new$1]), acc$1);
          } else {
            let next2 = rest$1.head;
            let rest$2 = rest$1.tail;
            let _block$1;
            let $1 = compare4(new$1, next2);
            if ($1 instanceof Lt) {
              _block$1 = new Ascending();
            } else if ($1 instanceof Eq) {
              _block$1 = new Ascending();
            } else {
              _block$1 = new Descending();
            }
            let direction$1 = _block$1;
            loop$list = rest$2;
            loop$compare = compare4;
            loop$growing = toList([new$1]);
            loop$direction = direction$1;
            loop$prev = next2;
            loop$acc = acc$1;
          }
        }
      } else if ($ instanceof Lt) {
        let _block;
        if (direction instanceof Ascending) {
          _block = prepend(reverse(growing$1), acc);
        } else {
          _block = prepend(growing$1, acc);
        }
        let acc$1 = _block;
        if (rest$1 instanceof Empty) {
          return prepend(toList([new$1]), acc$1);
        } else {
          let next2 = rest$1.head;
          let rest$2 = rest$1.tail;
          let _block$1;
          let $1 = compare4(new$1, next2);
          if ($1 instanceof Lt) {
            _block$1 = new Ascending();
          } else if ($1 instanceof Eq) {
            _block$1 = new Ascending();
          } else {
            _block$1 = new Descending();
          }
          let direction$1 = _block$1;
          loop$list = rest$2;
          loop$compare = compare4;
          loop$growing = toList([new$1]);
          loop$direction = direction$1;
          loop$prev = next2;
          loop$acc = acc$1;
        }
      } else if ($ instanceof Eq) {
        let _block;
        if (direction instanceof Ascending) {
          _block = prepend(reverse(growing$1), acc);
        } else {
          _block = prepend(growing$1, acc);
        }
        let acc$1 = _block;
        if (rest$1 instanceof Empty) {
          return prepend(toList([new$1]), acc$1);
        } else {
          let next2 = rest$1.head;
          let rest$2 = rest$1.tail;
          let _block$1;
          let $1 = compare4(new$1, next2);
          if ($1 instanceof Lt) {
            _block$1 = new Ascending();
          } else if ($1 instanceof Eq) {
            _block$1 = new Ascending();
          } else {
            _block$1 = new Descending();
          }
          let direction$1 = _block$1;
          loop$list = rest$2;
          loop$compare = compare4;
          loop$growing = toList([new$1]);
          loop$direction = direction$1;
          loop$prev = next2;
          loop$acc = acc$1;
        }
      } else {
        loop$list = rest$1;
        loop$compare = compare4;
        loop$growing = growing$1;
        loop$direction = direction;
        loop$prev = new$1;
        loop$acc = acc;
      }
    }
  }
}
function merge_ascendings(loop$list1, loop$list2, loop$compare, loop$acc) {
  while (true) {
    let list1 = loop$list1;
    let list22 = loop$list2;
    let compare4 = loop$compare;
    let acc = loop$acc;
    if (list1 instanceof Empty) {
      let list4 = list22;
      return reverse_and_prepend(list4, acc);
    } else if (list22 instanceof Empty) {
      let list4 = list1;
      return reverse_and_prepend(list4, acc);
    } else {
      let first1 = list1.head;
      let rest1 = list1.tail;
      let first22 = list22.head;
      let rest2 = list22.tail;
      let $ = compare4(first1, first22);
      if ($ instanceof Lt) {
        loop$list1 = rest1;
        loop$list2 = list22;
        loop$compare = compare4;
        loop$acc = prepend(first1, acc);
      } else if ($ instanceof Eq) {
        loop$list1 = list1;
        loop$list2 = rest2;
        loop$compare = compare4;
        loop$acc = prepend(first22, acc);
      } else {
        loop$list1 = list1;
        loop$list2 = rest2;
        loop$compare = compare4;
        loop$acc = prepend(first22, acc);
      }
    }
  }
}
function merge_ascending_pairs(loop$sequences, loop$compare, loop$acc) {
  while (true) {
    let sequences2 = loop$sequences;
    let compare4 = loop$compare;
    let acc = loop$acc;
    if (sequences2 instanceof Empty) {
      return reverse(acc);
    } else {
      let $ = sequences2.tail;
      if ($ instanceof Empty) {
        let sequence = sequences2.head;
        return reverse(prepend(reverse(sequence), acc));
      } else {
        let ascending1 = sequences2.head;
        let ascending2 = $.head;
        let rest$1 = $.tail;
        let descending = merge_ascendings(
          ascending1,
          ascending2,
          compare4,
          toList([])
        );
        loop$sequences = rest$1;
        loop$compare = compare4;
        loop$acc = prepend(descending, acc);
      }
    }
  }
}
function merge_descendings(loop$list1, loop$list2, loop$compare, loop$acc) {
  while (true) {
    let list1 = loop$list1;
    let list22 = loop$list2;
    let compare4 = loop$compare;
    let acc = loop$acc;
    if (list1 instanceof Empty) {
      let list4 = list22;
      return reverse_and_prepend(list4, acc);
    } else if (list22 instanceof Empty) {
      let list4 = list1;
      return reverse_and_prepend(list4, acc);
    } else {
      let first1 = list1.head;
      let rest1 = list1.tail;
      let first22 = list22.head;
      let rest2 = list22.tail;
      let $ = compare4(first1, first22);
      if ($ instanceof Lt) {
        loop$list1 = list1;
        loop$list2 = rest2;
        loop$compare = compare4;
        loop$acc = prepend(first22, acc);
      } else if ($ instanceof Eq) {
        loop$list1 = rest1;
        loop$list2 = list22;
        loop$compare = compare4;
        loop$acc = prepend(first1, acc);
      } else {
        loop$list1 = rest1;
        loop$list2 = list22;
        loop$compare = compare4;
        loop$acc = prepend(first1, acc);
      }
    }
  }
}
function merge_descending_pairs(loop$sequences, loop$compare, loop$acc) {
  while (true) {
    let sequences2 = loop$sequences;
    let compare4 = loop$compare;
    let acc = loop$acc;
    if (sequences2 instanceof Empty) {
      return reverse(acc);
    } else {
      let $ = sequences2.tail;
      if ($ instanceof Empty) {
        let sequence = sequences2.head;
        return reverse(prepend(reverse(sequence), acc));
      } else {
        let descending1 = sequences2.head;
        let descending2 = $.head;
        let rest$1 = $.tail;
        let ascending = merge_descendings(
          descending1,
          descending2,
          compare4,
          toList([])
        );
        loop$sequences = rest$1;
        loop$compare = compare4;
        loop$acc = prepend(ascending, acc);
      }
    }
  }
}
function merge_all(loop$sequences, loop$direction, loop$compare) {
  while (true) {
    let sequences2 = loop$sequences;
    let direction = loop$direction;
    let compare4 = loop$compare;
    if (sequences2 instanceof Empty) {
      return toList([]);
    } else if (direction instanceof Ascending) {
      let $ = sequences2.tail;
      if ($ instanceof Empty) {
        let sequence = sequences2.head;
        return sequence;
      } else {
        let sequences$1 = merge_ascending_pairs(sequences2, compare4, toList([]));
        loop$sequences = sequences$1;
        loop$direction = new Descending();
        loop$compare = compare4;
      }
    } else {
      let $ = sequences2.tail;
      if ($ instanceof Empty) {
        let sequence = sequences2.head;
        return reverse(sequence);
      } else {
        let sequences$1 = merge_descending_pairs(sequences2, compare4, toList([]));
        loop$sequences = sequences$1;
        loop$direction = new Ascending();
        loop$compare = compare4;
      }
    }
  }
}
function sort(list4, compare4) {
  if (list4 instanceof Empty) {
    return toList([]);
  } else {
    let $ = list4.tail;
    if ($ instanceof Empty) {
      let x = list4.head;
      return toList([x]);
    } else {
      let x = list4.head;
      let y = $.head;
      let rest$1 = $.tail;
      let _block;
      let $1 = compare4(x, y);
      if ($1 instanceof Lt) {
        _block = new Ascending();
      } else if ($1 instanceof Eq) {
        _block = new Ascending();
      } else {
        _block = new Descending();
      }
      let direction = _block;
      let sequences$1 = sequences(
        rest$1,
        compare4,
        toList([x]),
        direction,
        y,
        toList([])
      );
      return merge_all(sequences$1, new Ascending(), compare4);
    }
  }
}

// build/dev/javascript/gleam_stdlib/gleam/dynamic/decode.mjs
var DecodeError = class extends CustomType {
  constructor(expected, found, path2) {
    super();
    this.expected = expected;
    this.found = found;
    this.path = path2;
  }
};
var Decoder = class extends CustomType {
  constructor(function$) {
    super();
    this.function = function$;
  }
};
function run(data, decoder) {
  let $ = decoder.function(data);
  let maybe_invalid_data = $[0];
  let errors = $[1];
  if (errors instanceof Empty) {
    return new Ok(maybe_invalid_data);
  } else {
    return new Error(errors);
  }
}
function success(data) {
  return new Decoder((_) => {
    return [data, toList([])];
  });
}
function decode_dynamic(data) {
  return [data, toList([])];
}
function map2(decoder, transformer) {
  return new Decoder(
    (d) => {
      let $ = decoder.function(d);
      let data = $[0];
      let errors = $[1];
      return [transformer(data), errors];
    }
  );
}
function then$(decoder, next2) {
  return new Decoder(
    (dynamic_data) => {
      let $ = decoder.function(dynamic_data);
      let data = $[0];
      let errors = $[1];
      let decoder$1 = next2(data);
      let $1 = decoder$1.function(dynamic_data);
      let layer = $1;
      let data$1 = $1[0];
      if (errors instanceof Empty) {
        return layer;
      } else {
        return [data$1, errors];
      }
    }
  );
}
function run_decoders(loop$data, loop$failure, loop$decoders) {
  while (true) {
    let data = loop$data;
    let failure2 = loop$failure;
    let decoders = loop$decoders;
    if (decoders instanceof Empty) {
      return failure2;
    } else {
      let decoder = decoders.head;
      let decoders$1 = decoders.tail;
      let $ = decoder.function(data);
      let layer = $;
      let errors = $[1];
      if (errors instanceof Empty) {
        return layer;
      } else {
        loop$data = data;
        loop$failure = failure2;
        loop$decoders = decoders$1;
      }
    }
  }
}
function one_of(first3, alternatives) {
  return new Decoder(
    (dynamic_data) => {
      let $ = first3.function(dynamic_data);
      let layer = $;
      let errors = $[1];
      if (errors instanceof Empty) {
        return layer;
      } else {
        return run_decoders(dynamic_data, layer, alternatives);
      }
    }
  );
}
var dynamic = /* @__PURE__ */ new Decoder(decode_dynamic);
function decode_error(expected, found) {
  return toList([
    new DecodeError(expected, classify_dynamic(found), toList([]))
  ]);
}
function run_dynamic_function(data, name6, f) {
  let $ = f(data);
  if ($ instanceof Ok) {
    let data$1 = $[0];
    return [data$1, toList([])];
  } else {
    let zero = $[0];
    return [
      zero,
      toList([new DecodeError(name6, classify_dynamic(data), toList([]))])
    ];
  }
}
function decode_bool(data) {
  let $ = isEqual(identity(true), data);
  if ($) {
    return [true, toList([])];
  } else {
    let $1 = isEqual(identity(false), data);
    if ($1) {
      return [false, toList([])];
    } else {
      return [false, decode_error("Bool", data)];
    }
  }
}
function decode_int(data) {
  return run_dynamic_function(data, "Int", int);
}
function failure(zero, expected) {
  return new Decoder((d) => {
    return [zero, decode_error(expected, d)];
  });
}
function new_primitive_decoder(name6, decoding_function) {
  return new Decoder(
    (d) => {
      let $ = decoding_function(d);
      if ($ instanceof Ok) {
        let t = $[0];
        return [t, toList([])];
      } else {
        let zero = $[0];
        return [
          zero,
          toList([new DecodeError(name6, classify_dynamic(d), toList([]))])
        ];
      }
    }
  );
}
var bool = /* @__PURE__ */ new Decoder(decode_bool);
var int2 = /* @__PURE__ */ new Decoder(decode_int);
function decode_string(data) {
  return run_dynamic_function(data, "String", string);
}
var string2 = /* @__PURE__ */ new Decoder(decode_string);
function push_path(layer, path2) {
  let decoder = one_of(
    string2,
    toList([
      (() => {
        let _pipe = int2;
        return map2(_pipe, to_string);
      })()
    ])
  );
  let path$1 = map(
    path2,
    (key) => {
      let key$1 = identity(key);
      let $ = run(key$1, decoder);
      if ($ instanceof Ok) {
        let key$2 = $[0];
        return key$2;
      } else {
        return "<" + classify_dynamic(key$1) + ">";
      }
    }
  );
  let errors = map(
    layer[1],
    (error) => {
      let _record = error;
      return new DecodeError(
        _record.expected,
        _record.found,
        append(path$1, error.path)
      );
    }
  );
  return [layer[0], errors];
}
function index3(loop$path, loop$position, loop$inner, loop$data, loop$handle_miss) {
  while (true) {
    let path2 = loop$path;
    let position = loop$position;
    let inner = loop$inner;
    let data = loop$data;
    let handle_miss = loop$handle_miss;
    if (path2 instanceof Empty) {
      let _pipe = inner(data);
      return push_path(_pipe, reverse(position));
    } else {
      let key = path2.head;
      let path$1 = path2.tail;
      let $ = index2(data, key);
      if ($ instanceof Ok) {
        let $1 = $[0];
        if ($1 instanceof Some) {
          let data$1 = $1[0];
          loop$path = path$1;
          loop$position = prepend(key, position);
          loop$inner = inner;
          loop$data = data$1;
          loop$handle_miss = handle_miss;
        } else {
          return handle_miss(data, prepend(key, position));
        }
      } else {
        let kind = $[0];
        let $1 = inner(data);
        let default$ = $1[0];
        let _pipe = [
          default$,
          toList([new DecodeError(kind, classify_dynamic(data), toList([]))])
        ];
        return push_path(_pipe, reverse(position));
      }
    }
  }
}
function subfield(field_path, field_decoder, next2) {
  return new Decoder(
    (data) => {
      let $ = index3(
        field_path,
        toList([]),
        field_decoder.function,
        data,
        (data2, position) => {
          let $12 = field_decoder.function(data2);
          let default$ = $12[0];
          let _pipe = [
            default$,
            toList([new DecodeError("Field", "Nothing", toList([]))])
          ];
          return push_path(_pipe, reverse(position));
        }
      );
      let out = $[0];
      let errors1 = $[1];
      let $1 = next2(out).function(data);
      let out$1 = $1[0];
      let errors2 = $1[1];
      return [out$1, append(errors1, errors2)];
    }
  );
}
function field(field_name, field_decoder, next2) {
  return subfield(toList([field_name]), field_decoder, next2);
}

// build/dev/javascript/gleam_stdlib/gleam_stdlib.mjs
var Nil = void 0;
var NOT_FOUND = {};
function identity(x) {
  return x;
}
function to_string(term) {
  return term.toString();
}
function float_to_string(float2) {
  const string5 = float2.toString().replace("+", "");
  if (string5.indexOf(".") >= 0) {
    return string5;
  } else {
    const index4 = string5.indexOf("e");
    if (index4 >= 0) {
      return string5.slice(0, index4) + ".0" + string5.slice(index4);
    } else {
      return string5 + ".0";
    }
  }
}
function string_length(string5) {
  if (string5 === "") {
    return 0;
  }
  const iterator = graphemes_iterator(string5);
  if (iterator) {
    let i = 0;
    for (const _ of iterator) {
      i++;
    }
    return i;
  } else {
    return string5.match(/./gsu).length;
  }
}
var segmenter = void 0;
function graphemes_iterator(string5) {
  if (globalThis.Intl && Intl.Segmenter) {
    segmenter ||= new Intl.Segmenter();
    return segmenter.segment(string5)[Symbol.iterator]();
  }
}
function lowercase(string5) {
  return string5.toLowerCase();
}
function contains_string(haystack, needle) {
  return haystack.indexOf(needle) >= 0;
}
function starts_with(haystack, needle) {
  return haystack.startsWith(needle);
}
var unicode_whitespaces = [
  " ",
  // Space
  "	",
  // Horizontal tab
  "\n",
  // Line feed
  "\v",
  // Vertical tab
  "\f",
  // Form feed
  "\r",
  // Carriage return
  "\x85",
  // Next line
  "\u2028",
  // Line separator
  "\u2029"
  // Paragraph separator
].join("");
var trim_start_regex = /* @__PURE__ */ new RegExp(
  `^[${unicode_whitespaces}]*`
);
var trim_end_regex = /* @__PURE__ */ new RegExp(`[${unicode_whitespaces}]*$`);
function new_map() {
  return Dict.new();
}
function map_size(map4) {
  return map4.size;
}
function map_to_list(map4) {
  return List.fromArray(map4.entries());
}
function map_remove(key, map4) {
  return map4.delete(key);
}
function map_get(map4, key) {
  const value2 = map4.get(key, NOT_FOUND);
  if (value2 === NOT_FOUND) {
    return new Error(Nil);
  }
  return new Ok(value2);
}
function map_insert(key, value2, map4) {
  return map4.set(key, value2);
}
function classify_dynamic(data) {
  if (typeof data === "string") {
    return "String";
  } else if (typeof data === "boolean") {
    return "Bool";
  } else if (data instanceof Result) {
    return "Result";
  } else if (data instanceof List) {
    return "List";
  } else if (data instanceof BitArray) {
    return "BitArray";
  } else if (data instanceof Dict) {
    return "Dict";
  } else if (Number.isInteger(data)) {
    return "Int";
  } else if (Array.isArray(data)) {
    return `Array`;
  } else if (typeof data === "number") {
    return "Float";
  } else if (data === null) {
    return "Nil";
  } else if (data === void 0) {
    return "Nil";
  } else {
    const type = typeof data;
    return type.charAt(0).toUpperCase() + type.slice(1);
  }
}
function index2(data, key) {
  if (data instanceof Dict || data instanceof WeakMap || data instanceof Map) {
    const token2 = {};
    const entry = data.get(key, token2);
    if (entry === token2)
      return new Ok(new None());
    return new Ok(new Some(entry));
  }
  const key_is_int = Number.isInteger(key);
  if (key_is_int && key >= 0 && key < 8 && data instanceof List) {
    let i = 0;
    for (const value2 of data) {
      if (i === key)
        return new Ok(new Some(value2));
      i++;
    }
    return new Error("Indexable");
  }
  if (key_is_int && Array.isArray(data) || data && typeof data === "object" || data && Object.getPrototypeOf(data) === Object.prototype) {
    if (key in data)
      return new Ok(new Some(data[key]));
    return new Ok(new None());
  }
  return new Error(key_is_int ? "Indexable" : "Dict");
}
function int(data) {
  if (Number.isInteger(data))
    return new Ok(data);
  return new Error(0);
}
function string(data) {
  if (typeof data === "string")
    return new Ok(data);
  return new Error("");
}

// build/dev/javascript/gleam_stdlib/gleam/float.mjs
function sum_loop(loop$numbers, loop$initial) {
  while (true) {
    let numbers = loop$numbers;
    let initial = loop$initial;
    if (numbers instanceof Empty) {
      return initial;
    } else {
      let first3 = numbers.head;
      let rest = numbers.tail;
      loop$numbers = rest;
      loop$initial = first3 + initial;
    }
  }
}
function sum(numbers) {
  return sum_loop(numbers, 0);
}

// build/dev/javascript/gleam_stdlib/gleam/int.mjs
function compare2(a, b) {
  let $ = a === b;
  if ($) {
    return new Eq();
  } else {
    let $1 = a < b;
    if ($1) {
      return new Lt();
    } else {
      return new Gt();
    }
  }
}
function add(a, b) {
  return a + b;
}
function subtract(a, b) {
  return a - b;
}

// build/dev/javascript/gleam_stdlib/gleam/string.mjs
function concat_loop(loop$strings, loop$accumulator) {
  while (true) {
    let strings = loop$strings;
    let accumulator = loop$accumulator;
    if (strings instanceof Empty) {
      return accumulator;
    } else {
      let string5 = strings.head;
      let strings$1 = strings.tail;
      loop$strings = strings$1;
      loop$accumulator = accumulator + string5;
    }
  }
}
function concat2(strings) {
  return concat_loop(strings, "");
}
function join_loop(loop$strings, loop$separator, loop$accumulator) {
  while (true) {
    let strings = loop$strings;
    let separator = loop$separator;
    let accumulator = loop$accumulator;
    if (strings instanceof Empty) {
      return accumulator;
    } else {
      let string5 = strings.head;
      let strings$1 = strings.tail;
      loop$strings = strings$1;
      loop$separator = separator;
      loop$accumulator = accumulator + separator + string5;
    }
  }
}
function join(strings, separator) {
  if (strings instanceof Empty) {
    return "";
  } else {
    let first$1 = strings.head;
    let rest = strings.tail;
    return join_loop(rest, separator, first$1);
  }
}

// build/dev/javascript/gleam_stdlib/gleam/result.mjs
function is_ok(result) {
  if (result instanceof Ok) {
    return true;
  } else {
    return false;
  }
}
function map3(result, fun) {
  if (result instanceof Ok) {
    let x = result[0];
    return new Ok(fun(x));
  } else {
    let e = result[0];
    return new Error(e);
  }
}
function try$(result, fun) {
  if (result instanceof Ok) {
    let x = result[0];
    return fun(x);
  } else {
    let e = result[0];
    return new Error(e);
  }
}
function then$2(result, fun) {
  return try$(result, fun);
}
function unwrap(result, default$) {
  if (result instanceof Ok) {
    let v = result[0];
    return v;
  } else {
    return default$;
  }
}
function or(first3, second2) {
  if (first3 instanceof Ok) {
    return first3;
  } else {
    return second2;
  }
}
function replace_error(result, error) {
  if (result instanceof Ok) {
    let x = result[0];
    return new Ok(x);
  } else {
    return new Error(error);
  }
}

// build/dev/javascript/gleam_json/gleam_json_ffi.mjs
function object(entries) {
  return Object.fromEntries(entries);
}
function identity2(x) {
  return x;
}
function do_null() {
  return null;
}

// build/dev/javascript/gleam_json/gleam/json.mjs
function string3(input2) {
  return identity2(input2);
}
function bool2(input2) {
  return identity2(input2);
}
function null$() {
  return do_null();
}
function object2(entries) {
  return object(entries);
}

// build/dev/javascript/gleam_stdlib/gleam/bool.mjs
function to_string2(bool4) {
  if (bool4) {
    return "True";
  } else {
    return "False";
  }
}
function guard(requirement, consequence, alternative) {
  if (requirement) {
    return consequence;
  } else {
    return alternative();
  }
}

// build/dev/javascript/gleam_stdlib/gleam/function.mjs
function identity3(x) {
  return x;
}

// build/dev/javascript/gleam_stdlib/gleam/set.mjs
var Set2 = class extends CustomType {
  constructor(dict2) {
    super();
    this.dict = dict2;
  }
};
function new$() {
  return new Set2(new_map());
}
function size(set2) {
  return map_size(set2.dict);
}
function contains(set2, member) {
  let _pipe = set2.dict;
  let _pipe$1 = map_get(_pipe, member);
  return is_ok(_pipe$1);
}
function delete$2(set2, member) {
  return new Set2(delete$(set2.dict, member));
}
function filter3(set2, predicate) {
  return new Set2(filter(set2.dict, (m, _) => {
    return predicate(m);
  }));
}
var token = void 0;
function insert2(set2, member) {
  return new Set2(insert(set2.dict, member, token));
}
function from_list2(members) {
  let dict2 = fold2(
    members,
    new_map(),
    (m, k) => {
      return insert(m, k, token);
    }
  );
  return new Set2(dict2);
}

// build/dev/javascript/lustre/lustre/internals/constants.ffi.mjs
var EMPTY_DICT = /* @__PURE__ */ Dict.new();
var EMPTY_SET = /* @__PURE__ */ new$();
var empty_dict = () => EMPTY_DICT;
var empty_set = () => EMPTY_SET;
var document2 = () => globalThis?.document;
var NAMESPACE_HTML = "http://www.w3.org/1999/xhtml";
var ELEMENT_NODE = 1;
var TEXT_NODE = 3;
var DOCUMENT_FRAGMENT_NODE = 11;
var SUPPORTS_MOVE_BEFORE = !!globalThis.HTMLElement?.prototype?.moveBefore;

// build/dev/javascript/lustre/lustre/internals/constants.mjs
var empty_list = /* @__PURE__ */ toList([]);
var option_none = /* @__PURE__ */ new None();

// build/dev/javascript/lustre/lustre/vdom/vattr.ffi.mjs
var GT = /* @__PURE__ */ new Gt();
var LT = /* @__PURE__ */ new Lt();
var EQ = /* @__PURE__ */ new Eq();
function compare3(a, b) {
  if (a.name === b.name) {
    return EQ;
  } else if (a.name < b.name) {
    return LT;
  } else {
    return GT;
  }
}

// build/dev/javascript/lustre/lustre/vdom/vattr.mjs
var Attribute = class extends CustomType {
  constructor(kind, name6, value2) {
    super();
    this.kind = kind;
    this.name = name6;
    this.value = value2;
  }
};
var Property = class extends CustomType {
  constructor(kind, name6, value2) {
    super();
    this.kind = kind;
    this.name = name6;
    this.value = value2;
  }
};
var Event2 = class extends CustomType {
  constructor(kind, name6, handler, include, prevent_default3, stop_propagation, immediate2, debounce, throttle) {
    super();
    this.kind = kind;
    this.name = name6;
    this.handler = handler;
    this.include = include;
    this.prevent_default = prevent_default3;
    this.stop_propagation = stop_propagation;
    this.immediate = immediate2;
    this.debounce = debounce;
    this.throttle = throttle;
  }
};
var Handler = class extends CustomType {
  constructor(prevent_default3, stop_propagation, message) {
    super();
    this.prevent_default = prevent_default3;
    this.stop_propagation = stop_propagation;
    this.message = message;
  }
};
var Never = class extends CustomType {
  constructor(kind) {
    super();
    this.kind = kind;
  }
};
function merge(loop$attributes, loop$merged) {
  while (true) {
    let attributes = loop$attributes;
    let merged = loop$merged;
    if (attributes instanceof Empty) {
      return merged;
    } else {
      let $ = attributes.head;
      if ($ instanceof Attribute) {
        let $1 = $.name;
        if ($1 === "") {
          let rest = attributes.tail;
          loop$attributes = rest;
          loop$merged = merged;
        } else if ($1 === "class") {
          let $2 = $.value;
          if ($2 === "") {
            let rest = attributes.tail;
            loop$attributes = rest;
            loop$merged = merged;
          } else {
            let $3 = attributes.tail;
            if ($3 instanceof Empty) {
              let attribute$1 = $;
              let rest = $3;
              loop$attributes = rest;
              loop$merged = prepend(attribute$1, merged);
            } else {
              let $4 = $3.head;
              if ($4 instanceof Attribute) {
                let $5 = $4.name;
                if ($5 === "class") {
                  let kind = $.kind;
                  let class1 = $2;
                  let rest = $3.tail;
                  let class2 = $4.value;
                  let value2 = class1 + " " + class2;
                  let attribute$1 = new Attribute(kind, "class", value2);
                  loop$attributes = prepend(attribute$1, rest);
                  loop$merged = merged;
                } else {
                  let attribute$1 = $;
                  let rest = $3;
                  loop$attributes = rest;
                  loop$merged = prepend(attribute$1, merged);
                }
              } else {
                let attribute$1 = $;
                let rest = $3;
                loop$attributes = rest;
                loop$merged = prepend(attribute$1, merged);
              }
            }
          }
        } else if ($1 === "style") {
          let $2 = $.value;
          if ($2 === "") {
            let rest = attributes.tail;
            loop$attributes = rest;
            loop$merged = merged;
          } else {
            let $3 = attributes.tail;
            if ($3 instanceof Empty) {
              let attribute$1 = $;
              let rest = $3;
              loop$attributes = rest;
              loop$merged = prepend(attribute$1, merged);
            } else {
              let $4 = $3.head;
              if ($4 instanceof Attribute) {
                let $5 = $4.name;
                if ($5 === "style") {
                  let kind = $.kind;
                  let style1 = $2;
                  let rest = $3.tail;
                  let style2 = $4.value;
                  let value2 = style1 + ";" + style2;
                  let attribute$1 = new Attribute(kind, "style", value2);
                  loop$attributes = prepend(attribute$1, rest);
                  loop$merged = merged;
                } else {
                  let attribute$1 = $;
                  let rest = $3;
                  loop$attributes = rest;
                  loop$merged = prepend(attribute$1, merged);
                }
              } else {
                let attribute$1 = $;
                let rest = $3;
                loop$attributes = rest;
                loop$merged = prepend(attribute$1, merged);
              }
            }
          }
        } else {
          let attribute$1 = $;
          let rest = attributes.tail;
          loop$attributes = rest;
          loop$merged = prepend(attribute$1, merged);
        }
      } else {
        let attribute$1 = $;
        let rest = attributes.tail;
        loop$attributes = rest;
        loop$merged = prepend(attribute$1, merged);
      }
    }
  }
}
function prepare(attributes) {
  if (attributes instanceof Empty) {
    return attributes;
  } else {
    let $ = attributes.tail;
    if ($ instanceof Empty) {
      return attributes;
    } else {
      let _pipe = attributes;
      let _pipe$1 = sort(_pipe, (a, b) => {
        return compare3(b, a);
      });
      return merge(_pipe$1, empty_list);
    }
  }
}
var attribute_kind = 0;
function attribute(name6, value2) {
  return new Attribute(attribute_kind, name6, value2);
}
var property_kind = 1;
var event_kind = 2;
function event(name6, handler, include, prevent_default3, stop_propagation, immediate2, debounce, throttle) {
  return new Event2(
    event_kind,
    name6,
    handler,
    include,
    prevent_default3,
    stop_propagation,
    immediate2,
    debounce,
    throttle
  );
}
var never_kind = 0;
var never = /* @__PURE__ */ new Never(never_kind);
var always_kind = 2;

// build/dev/javascript/lustre/lustre/attribute.mjs
function attribute2(name6, value2) {
  return attribute(name6, value2);
}
function class$(name6) {
  return attribute2("class", name6);
}
function style(property3, value2) {
  if (property3 === "") {
    return class$("");
  } else if (value2 === "") {
    return class$("");
  } else {
    return attribute2("style", property3 + ":" + value2 + ";");
  }
}
function do_styles(loop$properties, loop$styles) {
  while (true) {
    let properties = loop$properties;
    let styles2 = loop$styles;
    if (properties instanceof Empty) {
      return styles2;
    } else {
      let $ = properties.head[0];
      if ($ === "") {
        let rest = properties.tail;
        loop$properties = rest;
        loop$styles = styles2;
      } else {
        let $1 = properties.head[1];
        if ($1 === "") {
          let rest = properties.tail;
          loop$properties = rest;
          loop$styles = styles2;
        } else {
          let rest = properties.tail;
          let name$1 = $;
          let value$1 = $1;
          loop$properties = rest;
          loop$styles = styles2 + name$1 + ":" + value$1 + ";";
        }
      }
    }
  }
}
function styles(properties) {
  return attribute2("style", do_styles(properties, ""));
}
function autocomplete(value2) {
  return attribute2("autocomplete", value2);
}
function name(element_name) {
  return attribute2("name", element_name);
}
function value(control_value) {
  return attribute2("value", control_value);
}

// build/dev/javascript/lustre/lustre/effect.mjs
var Effect = class extends CustomType {
  constructor(synchronous, before_paint2, after_paint2) {
    super();
    this.synchronous = synchronous;
    this.before_paint = before_paint2;
    this.after_paint = after_paint2;
  }
};
var empty = /* @__PURE__ */ new Effect(
  /* @__PURE__ */ toList([]),
  /* @__PURE__ */ toList([]),
  /* @__PURE__ */ toList([])
);
function none() {
  return empty;
}
function from(effect) {
  let task = (actions) => {
    let dispatch = actions.dispatch;
    return effect(dispatch);
  };
  let _record = empty;
  return new Effect(toList([task]), _record.before_paint, _record.after_paint);
}
function before_paint(effect) {
  let task = (actions) => {
    let root3 = actions.root();
    let dispatch = actions.dispatch;
    return effect(dispatch, root3);
  };
  let _record = empty;
  return new Effect(_record.synchronous, toList([task]), _record.after_paint);
}
function after_paint(effect) {
  let task = (actions) => {
    let root3 = actions.root();
    let dispatch = actions.dispatch;
    return effect(dispatch, root3);
  };
  let _record = empty;
  return new Effect(_record.synchronous, _record.before_paint, toList([task]));
}
function event2(name6, data) {
  let task = (actions) => {
    return actions.emit(name6, data);
  };
  let _record = empty;
  return new Effect(toList([task]), _record.before_paint, _record.after_paint);
}
function batch(effects) {
  return fold2(
    effects,
    empty,
    (acc, eff) => {
      return new Effect(
        fold2(eff.synchronous, acc.synchronous, prepend2),
        fold2(eff.before_paint, acc.before_paint, prepend2),
        fold2(eff.after_paint, acc.after_paint, prepend2)
      );
    }
  );
}

// build/dev/javascript/lustre/lustre/internals/mutable_map.ffi.mjs
function empty2() {
  return null;
}
function get(map4, key) {
  const value2 = map4?.get(key);
  if (value2 != null) {
    return new Ok(value2);
  } else {
    return new Error(void 0);
  }
}
function insert3(map4, key, value2) {
  map4 ??= /* @__PURE__ */ new Map();
  map4.set(key, value2);
  return map4;
}
function remove(map4, key) {
  map4?.delete(key);
  return map4;
}

// build/dev/javascript/lustre/lustre/vdom/path.mjs
var Root = class extends CustomType {
};
var Key = class extends CustomType {
  constructor(key, parent) {
    super();
    this.key = key;
    this.parent = parent;
  }
};
var Index = class extends CustomType {
  constructor(index4, parent) {
    super();
    this.index = index4;
    this.parent = parent;
  }
};
function do_matches(loop$path, loop$candidates) {
  while (true) {
    let path2 = loop$path;
    let candidates = loop$candidates;
    if (candidates instanceof Empty) {
      return false;
    } else {
      let candidate = candidates.head;
      let rest = candidates.tail;
      let $ = starts_with(path2, candidate);
      if ($) {
        return true;
      } else {
        loop$path = path2;
        loop$candidates = rest;
      }
    }
  }
}
function add3(parent, index4, key) {
  if (key === "") {
    return new Index(index4, parent);
  } else {
    return new Key(key, parent);
  }
}
var root2 = /* @__PURE__ */ new Root();
var separator_element = "	";
function do_to_string(loop$path, loop$acc) {
  while (true) {
    let path2 = loop$path;
    let acc = loop$acc;
    if (path2 instanceof Root) {
      if (acc instanceof Empty) {
        return "";
      } else {
        let segments = acc.tail;
        return concat2(segments);
      }
    } else if (path2 instanceof Key) {
      let key = path2.key;
      let parent = path2.parent;
      loop$path = parent;
      loop$acc = prepend(separator_element, prepend(key, acc));
    } else {
      let index4 = path2.index;
      let parent = path2.parent;
      loop$path = parent;
      loop$acc = prepend(
        separator_element,
        prepend(to_string(index4), acc)
      );
    }
  }
}
function to_string3(path2) {
  return do_to_string(path2, toList([]));
}
function matches(path2, candidates) {
  if (candidates instanceof Empty) {
    return false;
  } else {
    return do_matches(to_string3(path2), candidates);
  }
}
var separator_event = "\n";
function event3(path2, event4) {
  return do_to_string(path2, toList([separator_event, event4]));
}

// build/dev/javascript/lustre/lustre/vdom/vnode.mjs
var Fragment = class extends CustomType {
  constructor(kind, key, mapper, children, keyed_children, children_count) {
    super();
    this.kind = kind;
    this.key = key;
    this.mapper = mapper;
    this.children = children;
    this.keyed_children = keyed_children;
    this.children_count = children_count;
  }
};
var Element2 = class extends CustomType {
  constructor(kind, key, mapper, namespace2, tag, attributes, children, keyed_children, self_closing, void$) {
    super();
    this.kind = kind;
    this.key = key;
    this.mapper = mapper;
    this.namespace = namespace2;
    this.tag = tag;
    this.attributes = attributes;
    this.children = children;
    this.keyed_children = keyed_children;
    this.self_closing = self_closing;
    this.void = void$;
  }
};
var Text = class extends CustomType {
  constructor(kind, key, mapper, content) {
    super();
    this.kind = kind;
    this.key = key;
    this.mapper = mapper;
    this.content = content;
  }
};
var UnsafeInnerHtml = class extends CustomType {
  constructor(kind, key, mapper, namespace2, tag, attributes, inner_html) {
    super();
    this.kind = kind;
    this.key = key;
    this.mapper = mapper;
    this.namespace = namespace2;
    this.tag = tag;
    this.attributes = attributes;
    this.inner_html = inner_html;
  }
};
function is_void_element(tag, namespace2) {
  if (namespace2 === "") {
    if (tag === "area") {
      return true;
    } else if (tag === "base") {
      return true;
    } else if (tag === "br") {
      return true;
    } else if (tag === "col") {
      return true;
    } else if (tag === "embed") {
      return true;
    } else if (tag === "hr") {
      return true;
    } else if (tag === "img") {
      return true;
    } else if (tag === "input") {
      return true;
    } else if (tag === "link") {
      return true;
    } else if (tag === "meta") {
      return true;
    } else if (tag === "param") {
      return true;
    } else if (tag === "source") {
      return true;
    } else if (tag === "track") {
      return true;
    } else if (tag === "wbr") {
      return true;
    } else {
      return false;
    }
  } else {
    return false;
  }
}
function advance(node) {
  if (node instanceof Fragment) {
    let children_count = node.children_count;
    return 1 + children_count;
  } else {
    return 1;
  }
}
var fragment_kind = 0;
function fragment(key, mapper, children, keyed_children, children_count) {
  return new Fragment(
    fragment_kind,
    key,
    mapper,
    children,
    keyed_children,
    children_count
  );
}
var element_kind = 1;
function element(key, mapper, namespace2, tag, attributes, children, keyed_children, self_closing, void$) {
  return new Element2(
    element_kind,
    key,
    mapper,
    namespace2,
    tag,
    prepare(attributes),
    children,
    keyed_children,
    self_closing,
    void$ || is_void_element(tag, namespace2)
  );
}
var text_kind = 2;
function text(key, mapper, content) {
  return new Text(text_kind, key, mapper, content);
}
var unsafe_inner_html_kind = 3;
function set_fragment_key(loop$key, loop$children, loop$index, loop$new_children, loop$keyed_children) {
  while (true) {
    let key = loop$key;
    let children = loop$children;
    let index4 = loop$index;
    let new_children = loop$new_children;
    let keyed_children = loop$keyed_children;
    if (children instanceof Empty) {
      return [reverse(new_children), keyed_children];
    } else {
      let $ = children.head;
      if ($ instanceof Fragment) {
        let node = $;
        if (node.key === "") {
          let children$1 = children.tail;
          let child_key = key + "::" + to_string(index4);
          let $1 = set_fragment_key(
            child_key,
            node.children,
            0,
            empty_list,
            empty2()
          );
          let node_children = $1[0];
          let node_keyed_children = $1[1];
          let _block;
          let _record = node;
          _block = new Fragment(
            _record.kind,
            _record.key,
            _record.mapper,
            node_children,
            node_keyed_children,
            _record.children_count
          );
          let new_node = _block;
          let new_children$1 = prepend(new_node, new_children);
          let index$1 = index4 + 1;
          loop$key = key;
          loop$children = children$1;
          loop$index = index$1;
          loop$new_children = new_children$1;
          loop$keyed_children = keyed_children;
        } else {
          let node$1 = $;
          if (node$1.key !== "") {
            let children$1 = children.tail;
            let child_key = key + "::" + node$1.key;
            let keyed_node = to_keyed(child_key, node$1);
            let new_children$1 = prepend(keyed_node, new_children);
            let keyed_children$1 = insert3(
              keyed_children,
              child_key,
              keyed_node
            );
            let index$1 = index4 + 1;
            loop$key = key;
            loop$children = children$1;
            loop$index = index$1;
            loop$new_children = new_children$1;
            loop$keyed_children = keyed_children$1;
          } else {
            let node$2 = $;
            let children$1 = children.tail;
            let new_children$1 = prepend(node$2, new_children);
            let index$1 = index4 + 1;
            loop$key = key;
            loop$children = children$1;
            loop$index = index$1;
            loop$new_children = new_children$1;
            loop$keyed_children = keyed_children;
          }
        }
      } else {
        let node = $;
        if (node.key !== "") {
          let children$1 = children.tail;
          let child_key = key + "::" + node.key;
          let keyed_node = to_keyed(child_key, node);
          let new_children$1 = prepend(keyed_node, new_children);
          let keyed_children$1 = insert3(
            keyed_children,
            child_key,
            keyed_node
          );
          let index$1 = index4 + 1;
          loop$key = key;
          loop$children = children$1;
          loop$index = index$1;
          loop$new_children = new_children$1;
          loop$keyed_children = keyed_children$1;
        } else {
          let node$1 = $;
          let children$1 = children.tail;
          let new_children$1 = prepend(node$1, new_children);
          let index$1 = index4 + 1;
          loop$key = key;
          loop$children = children$1;
          loop$index = index$1;
          loop$new_children = new_children$1;
          loop$keyed_children = keyed_children;
        }
      }
    }
  }
}
function to_keyed(key, node) {
  if (node instanceof Fragment) {
    let children = node.children;
    let $ = set_fragment_key(
      key,
      children,
      0,
      empty_list,
      empty2()
    );
    let children$1 = $[0];
    let keyed_children = $[1];
    let _record = node;
    return new Fragment(
      _record.kind,
      key,
      _record.mapper,
      children$1,
      keyed_children,
      _record.children_count
    );
  } else if (node instanceof Element2) {
    let _record = node;
    return new Element2(
      _record.kind,
      key,
      _record.mapper,
      _record.namespace,
      _record.tag,
      _record.attributes,
      _record.children,
      _record.keyed_children,
      _record.self_closing,
      _record.void
    );
  } else if (node instanceof Text) {
    let _record = node;
    return new Text(_record.kind, key, _record.mapper, _record.content);
  } else {
    let _record = node;
    return new UnsafeInnerHtml(
      _record.kind,
      key,
      _record.mapper,
      _record.namespace,
      _record.tag,
      _record.attributes,
      _record.inner_html
    );
  }
}

// build/dev/javascript/lustre/lustre/internals/equals.ffi.mjs
var isReferenceEqual = (a, b) => a === b;
var isEqual2 = (a, b) => {
  if (a === b) {
    return true;
  }
  if (a == null || b == null) {
    return false;
  }
  const type = typeof a;
  if (type !== typeof b) {
    return false;
  }
  if (type !== "object") {
    return false;
  }
  const ctor = a.constructor;
  if (ctor !== b.constructor) {
    return false;
  }
  if (Array.isArray(a)) {
    return areArraysEqual(a, b);
  }
  return areObjectsEqual(a, b);
};
var areArraysEqual = (a, b) => {
  let index4 = a.length;
  if (index4 !== b.length) {
    return false;
  }
  while (index4--) {
    if (!isEqual2(a[index4], b[index4])) {
      return false;
    }
  }
  return true;
};
var areObjectsEqual = (a, b) => {
  const properties = Object.keys(a);
  let index4 = properties.length;
  if (Object.keys(b).length !== index4) {
    return false;
  }
  while (index4--) {
    const property3 = properties[index4];
    if (!Object.hasOwn(b, property3)) {
      return false;
    }
    if (!isEqual2(a[property3], b[property3])) {
      return false;
    }
  }
  return true;
};

// build/dev/javascript/lustre/lustre/vdom/events.mjs
var Events = class extends CustomType {
  constructor(handlers, dispatched_paths, next_dispatched_paths) {
    super();
    this.handlers = handlers;
    this.dispatched_paths = dispatched_paths;
    this.next_dispatched_paths = next_dispatched_paths;
  }
};
function new$3() {
  return new Events(
    empty2(),
    empty_list,
    empty_list
  );
}
function tick(events) {
  return new Events(
    events.handlers,
    events.next_dispatched_paths,
    empty_list
  );
}
function do_remove_event(handlers, path2, name6) {
  return remove(handlers, event3(path2, name6));
}
function remove_event(events, path2, name6) {
  let handlers = do_remove_event(events.handlers, path2, name6);
  let _record = events;
  return new Events(
    handlers,
    _record.dispatched_paths,
    _record.next_dispatched_paths
  );
}
function remove_attributes(handlers, path2, attributes) {
  return fold2(
    attributes,
    handlers,
    (events, attribute5) => {
      if (attribute5 instanceof Event2) {
        let name6 = attribute5.name;
        return do_remove_event(events, path2, name6);
      } else {
        return events;
      }
    }
  );
}
function handle(events, path2, name6, event4) {
  let next_dispatched_paths = prepend(path2, events.next_dispatched_paths);
  let _block;
  let _record = events;
  _block = new Events(
    _record.handlers,
    _record.dispatched_paths,
    next_dispatched_paths
  );
  let events$1 = _block;
  let $ = get(
    events$1.handlers,
    path2 + separator_event + name6
  );
  if ($ instanceof Ok) {
    let handler = $[0];
    return [events$1, run(event4, handler)];
  } else {
    return [events$1, new Error(toList([]))];
  }
}
function has_dispatched_events(events, path2) {
  return matches(path2, events.dispatched_paths);
}
function do_add_event(handlers, mapper, path2, name6, handler) {
  return insert3(
    handlers,
    event3(path2, name6),
    map2(
      handler,
      (handler2) => {
        let _record = handler2;
        return new Handler(
          _record.prevent_default,
          _record.stop_propagation,
          identity3(mapper)(handler2.message)
        );
      }
    )
  );
}
function add_event(events, mapper, path2, name6, handler) {
  let handlers = do_add_event(events.handlers, mapper, path2, name6, handler);
  let _record = events;
  return new Events(
    handlers,
    _record.dispatched_paths,
    _record.next_dispatched_paths
  );
}
function add_attributes(handlers, mapper, path2, attributes) {
  return fold2(
    attributes,
    handlers,
    (events, attribute5) => {
      if (attribute5 instanceof Event2) {
        let name6 = attribute5.name;
        let handler = attribute5.handler;
        return do_add_event(events, mapper, path2, name6, handler);
      } else {
        return events;
      }
    }
  );
}
function compose_mapper(mapper, child_mapper) {
  let $ = isReferenceEqual(mapper, identity3);
  let $1 = isReferenceEqual(child_mapper, identity3);
  if ($1) {
    return mapper;
  } else if ($) {
    return child_mapper;
  } else {
    return (msg) => {
      return mapper(child_mapper(msg));
    };
  }
}
function do_remove_children(loop$handlers, loop$path, loop$child_index, loop$children) {
  while (true) {
    let handlers = loop$handlers;
    let path2 = loop$path;
    let child_index = loop$child_index;
    let children = loop$children;
    if (children instanceof Empty) {
      return handlers;
    } else {
      let child2 = children.head;
      let rest = children.tail;
      let _pipe = handlers;
      let _pipe$1 = do_remove_child(_pipe, path2, child_index, child2);
      loop$handlers = _pipe$1;
      loop$path = path2;
      loop$child_index = child_index + advance(child2);
      loop$children = rest;
    }
  }
}
function do_remove_child(handlers, parent, child_index, child2) {
  if (child2 instanceof Fragment) {
    let children = child2.children;
    return do_remove_children(handlers, parent, child_index + 1, children);
  } else if (child2 instanceof Element2) {
    let attributes = child2.attributes;
    let children = child2.children;
    let path2 = add3(parent, child_index, child2.key);
    let _pipe = handlers;
    let _pipe$1 = remove_attributes(_pipe, path2, attributes);
    return do_remove_children(_pipe$1, path2, 0, children);
  } else if (child2 instanceof Text) {
    return handlers;
  } else {
    let attributes = child2.attributes;
    let path2 = add3(parent, child_index, child2.key);
    return remove_attributes(handlers, path2, attributes);
  }
}
function remove_child(events, parent, child_index, child2) {
  let handlers = do_remove_child(events.handlers, parent, child_index, child2);
  let _record = events;
  return new Events(
    handlers,
    _record.dispatched_paths,
    _record.next_dispatched_paths
  );
}
function do_add_children(loop$handlers, loop$mapper, loop$path, loop$child_index, loop$children) {
  while (true) {
    let handlers = loop$handlers;
    let mapper = loop$mapper;
    let path2 = loop$path;
    let child_index = loop$child_index;
    let children = loop$children;
    if (children instanceof Empty) {
      return handlers;
    } else {
      let child2 = children.head;
      let rest = children.tail;
      let _pipe = handlers;
      let _pipe$1 = do_add_child(_pipe, mapper, path2, child_index, child2);
      loop$handlers = _pipe$1;
      loop$mapper = mapper;
      loop$path = path2;
      loop$child_index = child_index + advance(child2);
      loop$children = rest;
    }
  }
}
function do_add_child(handlers, mapper, parent, child_index, child2) {
  if (child2 instanceof Fragment) {
    let children = child2.children;
    let composed_mapper = compose_mapper(mapper, child2.mapper);
    let child_index$1 = child_index + 1;
    return do_add_children(
      handlers,
      composed_mapper,
      parent,
      child_index$1,
      children
    );
  } else if (child2 instanceof Element2) {
    let attributes = child2.attributes;
    let children = child2.children;
    let path2 = add3(parent, child_index, child2.key);
    let composed_mapper = compose_mapper(mapper, child2.mapper);
    let _pipe = handlers;
    let _pipe$1 = add_attributes(_pipe, composed_mapper, path2, attributes);
    return do_add_children(_pipe$1, composed_mapper, path2, 0, children);
  } else if (child2 instanceof Text) {
    return handlers;
  } else {
    let attributes = child2.attributes;
    let path2 = add3(parent, child_index, child2.key);
    let composed_mapper = compose_mapper(mapper, child2.mapper);
    return add_attributes(handlers, composed_mapper, path2, attributes);
  }
}
function add_child(events, mapper, parent, index4, child2) {
  let handlers = do_add_child(events.handlers, mapper, parent, index4, child2);
  let _record = events;
  return new Events(
    handlers,
    _record.dispatched_paths,
    _record.next_dispatched_paths
  );
}
function add_children(events, mapper, path2, child_index, children) {
  let handlers = do_add_children(
    events.handlers,
    mapper,
    path2,
    child_index,
    children
  );
  let _record = events;
  return new Events(
    handlers,
    _record.dispatched_paths,
    _record.next_dispatched_paths
  );
}

// build/dev/javascript/lustre/lustre/element.mjs
function element2(tag, attributes, children) {
  return element(
    "",
    identity3,
    "",
    tag,
    attributes,
    children,
    empty2(),
    false,
    false
  );
}
function namespaced(namespace2, tag, attributes, children) {
  return element(
    "",
    identity3,
    namespace2,
    tag,
    attributes,
    children,
    empty2(),
    false,
    false
  );
}
function text2(content) {
  return text("", identity3, content);
}
function none2() {
  return text("", identity3, "");
}
function count_fragment_children(loop$children, loop$count) {
  while (true) {
    let children = loop$children;
    let count = loop$count;
    if (children instanceof Empty) {
      return count;
    } else {
      let child2 = children.head;
      let rest = children.tail;
      loop$children = rest;
      loop$count = count + advance(child2);
    }
  }
}
function fragment2(children) {
  return fragment(
    "",
    identity3,
    children,
    empty2(),
    count_fragment_children(children, 0)
  );
}

// build/dev/javascript/lustre/lustre/element/html.mjs
function text3(content) {
  return text2(content);
}
function div(attrs, children) {
  return element2("div", attrs, children);
}
function li(attrs, children) {
  return element2("li", attrs, children);
}
function p(attrs, children) {
  return element2("p", attrs, children);
}
function span(attrs, children) {
  return element2("span", attrs, children);
}
function svg(attrs, children) {
  return namespaced("http://www.w3.org/2000/svg", "svg", attrs, children);
}
function button(attrs, children) {
  return element2("button", attrs, children);
}
function input(attrs) {
  return element2("input", attrs, empty_list);
}
function slot(attrs, fallback) {
  return element2("slot", attrs, fallback);
}

// build/dev/javascript/lustre/lustre/vdom/patch.mjs
var Patch = class extends CustomType {
  constructor(index4, removed, changes, children) {
    super();
    this.index = index4;
    this.removed = removed;
    this.changes = changes;
    this.children = children;
  }
};
var ReplaceText = class extends CustomType {
  constructor(kind, content) {
    super();
    this.kind = kind;
    this.content = content;
  }
};
var ReplaceInnerHtml = class extends CustomType {
  constructor(kind, inner_html) {
    super();
    this.kind = kind;
    this.inner_html = inner_html;
  }
};
var Update = class extends CustomType {
  constructor(kind, added, removed) {
    super();
    this.kind = kind;
    this.added = added;
    this.removed = removed;
  }
};
var Move = class extends CustomType {
  constructor(kind, key, before, count) {
    super();
    this.kind = kind;
    this.key = key;
    this.before = before;
    this.count = count;
  }
};
var RemoveKey = class extends CustomType {
  constructor(kind, key, count) {
    super();
    this.kind = kind;
    this.key = key;
    this.count = count;
  }
};
var Replace = class extends CustomType {
  constructor(kind, from2, count, with$) {
    super();
    this.kind = kind;
    this.from = from2;
    this.count = count;
    this.with = with$;
  }
};
var Insert = class extends CustomType {
  constructor(kind, children, before) {
    super();
    this.kind = kind;
    this.children = children;
    this.before = before;
  }
};
var Remove = class extends CustomType {
  constructor(kind, from2, count) {
    super();
    this.kind = kind;
    this.from = from2;
    this.count = count;
  }
};
function new$5(index4, removed, changes, children) {
  return new Patch(index4, removed, changes, children);
}
var replace_text_kind = 0;
function replace_text(content) {
  return new ReplaceText(replace_text_kind, content);
}
var replace_inner_html_kind = 1;
function replace_inner_html(inner_html) {
  return new ReplaceInnerHtml(replace_inner_html_kind, inner_html);
}
var update_kind = 2;
function update(added, removed) {
  return new Update(update_kind, added, removed);
}
var move_kind = 3;
function move(key, before, count) {
  return new Move(move_kind, key, before, count);
}
var remove_key_kind = 4;
function remove_key(key, count) {
  return new RemoveKey(remove_key_kind, key, count);
}
var replace_kind = 5;
function replace2(from2, count, with$) {
  return new Replace(replace_kind, from2, count, with$);
}
var insert_kind = 6;
function insert4(children, before) {
  return new Insert(insert_kind, children, before);
}
var remove_kind = 7;
function remove2(from2, count) {
  return new Remove(remove_kind, from2, count);
}

// build/dev/javascript/lustre/lustre/vdom/diff.mjs
var Diff = class extends CustomType {
  constructor(patch, events) {
    super();
    this.patch = patch;
    this.events = events;
  }
};
var AttributeChange = class extends CustomType {
  constructor(added, removed, events) {
    super();
    this.added = added;
    this.removed = removed;
    this.events = events;
  }
};
function is_controlled(events, namespace2, tag, path2) {
  if (tag === "input") {
    if (namespace2 === "") {
      return has_dispatched_events(events, path2);
    } else {
      return false;
    }
  } else if (tag === "select") {
    if (namespace2 === "") {
      return has_dispatched_events(events, path2);
    } else {
      return false;
    }
  } else if (tag === "textarea") {
    if (namespace2 === "") {
      return has_dispatched_events(events, path2);
    } else {
      return false;
    }
  } else {
    return false;
  }
}
function diff_attributes(loop$controlled, loop$path, loop$mapper, loop$events, loop$old, loop$new, loop$added, loop$removed) {
  while (true) {
    let controlled = loop$controlled;
    let path2 = loop$path;
    let mapper = loop$mapper;
    let events = loop$events;
    let old = loop$old;
    let new$9 = loop$new;
    let added = loop$added;
    let removed = loop$removed;
    if (new$9 instanceof Empty) {
      if (old instanceof Empty) {
        return new AttributeChange(added, removed, events);
      } else {
        let $ = old.head;
        if ($ instanceof Event2) {
          let prev = $;
          let old$1 = old.tail;
          let name6 = $.name;
          let removed$1 = prepend(prev, removed);
          let events$1 = remove_event(events, path2, name6);
          loop$controlled = controlled;
          loop$path = path2;
          loop$mapper = mapper;
          loop$events = events$1;
          loop$old = old$1;
          loop$new = new$9;
          loop$added = added;
          loop$removed = removed$1;
        } else {
          let prev = $;
          let old$1 = old.tail;
          let removed$1 = prepend(prev, removed);
          loop$controlled = controlled;
          loop$path = path2;
          loop$mapper = mapper;
          loop$events = events;
          loop$old = old$1;
          loop$new = new$9;
          loop$added = added;
          loop$removed = removed$1;
        }
      }
    } else if (old instanceof Empty) {
      let $ = new$9.head;
      if ($ instanceof Event2) {
        let next2 = $;
        let new$1 = new$9.tail;
        let name6 = $.name;
        let handler = $.handler;
        let added$1 = prepend(next2, added);
        let events$1 = add_event(events, mapper, path2, name6, handler);
        loop$controlled = controlled;
        loop$path = path2;
        loop$mapper = mapper;
        loop$events = events$1;
        loop$old = old;
        loop$new = new$1;
        loop$added = added$1;
        loop$removed = removed;
      } else {
        let next2 = $;
        let new$1 = new$9.tail;
        let added$1 = prepend(next2, added);
        loop$controlled = controlled;
        loop$path = path2;
        loop$mapper = mapper;
        loop$events = events;
        loop$old = old;
        loop$new = new$1;
        loop$added = added$1;
        loop$removed = removed;
      }
    } else {
      let next2 = new$9.head;
      let remaining_new = new$9.tail;
      let prev = old.head;
      let remaining_old = old.tail;
      let $ = compare3(prev, next2);
      if ($ instanceof Lt) {
        if (prev instanceof Event2) {
          let name6 = prev.name;
          let removed$1 = prepend(prev, removed);
          let events$1 = remove_event(events, path2, name6);
          loop$controlled = controlled;
          loop$path = path2;
          loop$mapper = mapper;
          loop$events = events$1;
          loop$old = remaining_old;
          loop$new = new$9;
          loop$added = added;
          loop$removed = removed$1;
        } else {
          let removed$1 = prepend(prev, removed);
          loop$controlled = controlled;
          loop$path = path2;
          loop$mapper = mapper;
          loop$events = events;
          loop$old = remaining_old;
          loop$new = new$9;
          loop$added = added;
          loop$removed = removed$1;
        }
      } else if ($ instanceof Eq) {
        if (next2 instanceof Attribute) {
          if (prev instanceof Attribute) {
            let _block;
            let $1 = next2.name;
            if ($1 === "value") {
              _block = controlled || prev.value !== next2.value;
            } else if ($1 === "checked") {
              _block = controlled || prev.value !== next2.value;
            } else if ($1 === "selected") {
              _block = controlled || prev.value !== next2.value;
            } else {
              _block = prev.value !== next2.value;
            }
            let has_changes = _block;
            let _block$1;
            if (has_changes) {
              _block$1 = prepend(next2, added);
            } else {
              _block$1 = added;
            }
            let added$1 = _block$1;
            loop$controlled = controlled;
            loop$path = path2;
            loop$mapper = mapper;
            loop$events = events;
            loop$old = remaining_old;
            loop$new = remaining_new;
            loop$added = added$1;
            loop$removed = removed;
          } else if (prev instanceof Event2) {
            let name6 = prev.name;
            let added$1 = prepend(next2, added);
            let removed$1 = prepend(prev, removed);
            let events$1 = remove_event(events, path2, name6);
            loop$controlled = controlled;
            loop$path = path2;
            loop$mapper = mapper;
            loop$events = events$1;
            loop$old = remaining_old;
            loop$new = remaining_new;
            loop$added = added$1;
            loop$removed = removed$1;
          } else {
            let added$1 = prepend(next2, added);
            let removed$1 = prepend(prev, removed);
            loop$controlled = controlled;
            loop$path = path2;
            loop$mapper = mapper;
            loop$events = events;
            loop$old = remaining_old;
            loop$new = remaining_new;
            loop$added = added$1;
            loop$removed = removed$1;
          }
        } else if (next2 instanceof Property) {
          if (prev instanceof Property) {
            let _block;
            let $1 = next2.name;
            if ($1 === "scrollLeft") {
              _block = true;
            } else if ($1 === "scrollRight") {
              _block = true;
            } else if ($1 === "value") {
              _block = controlled || !isEqual2(
                prev.value,
                next2.value
              );
            } else if ($1 === "checked") {
              _block = controlled || !isEqual2(
                prev.value,
                next2.value
              );
            } else if ($1 === "selected") {
              _block = controlled || !isEqual2(
                prev.value,
                next2.value
              );
            } else {
              _block = !isEqual2(prev.value, next2.value);
            }
            let has_changes = _block;
            let _block$1;
            if (has_changes) {
              _block$1 = prepend(next2, added);
            } else {
              _block$1 = added;
            }
            let added$1 = _block$1;
            loop$controlled = controlled;
            loop$path = path2;
            loop$mapper = mapper;
            loop$events = events;
            loop$old = remaining_old;
            loop$new = remaining_new;
            loop$added = added$1;
            loop$removed = removed;
          } else if (prev instanceof Event2) {
            let name6 = prev.name;
            let added$1 = prepend(next2, added);
            let removed$1 = prepend(prev, removed);
            let events$1 = remove_event(events, path2, name6);
            loop$controlled = controlled;
            loop$path = path2;
            loop$mapper = mapper;
            loop$events = events$1;
            loop$old = remaining_old;
            loop$new = remaining_new;
            loop$added = added$1;
            loop$removed = removed$1;
          } else {
            let added$1 = prepend(next2, added);
            let removed$1 = prepend(prev, removed);
            loop$controlled = controlled;
            loop$path = path2;
            loop$mapper = mapper;
            loop$events = events;
            loop$old = remaining_old;
            loop$new = remaining_new;
            loop$added = added$1;
            loop$removed = removed$1;
          }
        } else if (prev instanceof Event2) {
          let name6 = next2.name;
          let handler = next2.handler;
          let has_changes = !isEqual(
            prev.prevent_default,
            next2.prevent_default
          ) || !isEqual(prev.stop_propagation, next2.stop_propagation) || prev.immediate !== next2.immediate || prev.debounce !== next2.debounce || prev.throttle !== next2.throttle;
          let _block;
          if (has_changes) {
            _block = prepend(next2, added);
          } else {
            _block = added;
          }
          let added$1 = _block;
          let events$1 = add_event(events, mapper, path2, name6, handler);
          loop$controlled = controlled;
          loop$path = path2;
          loop$mapper = mapper;
          loop$events = events$1;
          loop$old = remaining_old;
          loop$new = remaining_new;
          loop$added = added$1;
          loop$removed = removed;
        } else {
          let name6 = next2.name;
          let handler = next2.handler;
          let added$1 = prepend(next2, added);
          let removed$1 = prepend(prev, removed);
          let events$1 = add_event(events, mapper, path2, name6, handler);
          loop$controlled = controlled;
          loop$path = path2;
          loop$mapper = mapper;
          loop$events = events$1;
          loop$old = remaining_old;
          loop$new = remaining_new;
          loop$added = added$1;
          loop$removed = removed$1;
        }
      } else if (next2 instanceof Event2) {
        let name6 = next2.name;
        let handler = next2.handler;
        let added$1 = prepend(next2, added);
        let events$1 = add_event(events, mapper, path2, name6, handler);
        loop$controlled = controlled;
        loop$path = path2;
        loop$mapper = mapper;
        loop$events = events$1;
        loop$old = old;
        loop$new = remaining_new;
        loop$added = added$1;
        loop$removed = removed;
      } else {
        let added$1 = prepend(next2, added);
        loop$controlled = controlled;
        loop$path = path2;
        loop$mapper = mapper;
        loop$events = events;
        loop$old = old;
        loop$new = remaining_new;
        loop$added = added$1;
        loop$removed = removed;
      }
    }
  }
}
function do_diff(loop$old, loop$old_keyed, loop$new, loop$new_keyed, loop$moved, loop$moved_offset, loop$removed, loop$node_index, loop$patch_index, loop$path, loop$changes, loop$children, loop$mapper, loop$events) {
  while (true) {
    let old = loop$old;
    let old_keyed = loop$old_keyed;
    let new$9 = loop$new;
    let new_keyed = loop$new_keyed;
    let moved = loop$moved;
    let moved_offset = loop$moved_offset;
    let removed = loop$removed;
    let node_index = loop$node_index;
    let patch_index = loop$patch_index;
    let path2 = loop$path;
    let changes = loop$changes;
    let children = loop$children;
    let mapper = loop$mapper;
    let events = loop$events;
    if (new$9 instanceof Empty) {
      if (old instanceof Empty) {
        return new Diff(
          new Patch(patch_index, removed, changes, children),
          events
        );
      } else {
        let prev = old.head;
        let old$1 = old.tail;
        let _block;
        let $ = prev.key === "" || !contains(moved, prev.key);
        if ($) {
          _block = removed + advance(prev);
        } else {
          _block = removed;
        }
        let removed$1 = _block;
        let events$1 = remove_child(events, path2, node_index, prev);
        loop$old = old$1;
        loop$old_keyed = old_keyed;
        loop$new = new$9;
        loop$new_keyed = new_keyed;
        loop$moved = moved;
        loop$moved_offset = moved_offset;
        loop$removed = removed$1;
        loop$node_index = node_index;
        loop$patch_index = patch_index;
        loop$path = path2;
        loop$changes = changes;
        loop$children = children;
        loop$mapper = mapper;
        loop$events = events$1;
      }
    } else if (old instanceof Empty) {
      let events$1 = add_children(
        events,
        mapper,
        path2,
        node_index,
        new$9
      );
      let insert5 = insert4(new$9, node_index - moved_offset);
      let changes$1 = prepend(insert5, changes);
      return new Diff(
        new Patch(patch_index, removed, changes$1, children),
        events$1
      );
    } else {
      let next2 = new$9.head;
      let prev = old.head;
      if (prev.key !== next2.key) {
        let new_remaining = new$9.tail;
        let old_remaining = old.tail;
        let next_did_exist = get(old_keyed, next2.key);
        let prev_does_exist = get(new_keyed, prev.key);
        let prev_has_moved = contains(moved, prev.key);
        if (next_did_exist instanceof Ok) {
          if (prev_does_exist instanceof Ok) {
            if (prev_has_moved) {
              loop$old = old_remaining;
              loop$old_keyed = old_keyed;
              loop$new = new$9;
              loop$new_keyed = new_keyed;
              loop$moved = moved;
              loop$moved_offset = moved_offset - advance(prev);
              loop$removed = removed;
              loop$node_index = node_index;
              loop$patch_index = patch_index;
              loop$path = path2;
              loop$changes = changes;
              loop$children = children;
              loop$mapper = mapper;
              loop$events = events;
            } else {
              let match = next_did_exist[0];
              let count = advance(next2);
              let before = node_index - moved_offset;
              let move2 = move(next2.key, before, count);
              let changes$1 = prepend(move2, changes);
              let moved$1 = insert2(moved, next2.key);
              let moved_offset$1 = moved_offset + count;
              loop$old = prepend(match, old);
              loop$old_keyed = old_keyed;
              loop$new = new$9;
              loop$new_keyed = new_keyed;
              loop$moved = moved$1;
              loop$moved_offset = moved_offset$1;
              loop$removed = removed;
              loop$node_index = node_index;
              loop$patch_index = patch_index;
              loop$path = path2;
              loop$changes = changes$1;
              loop$children = children;
              loop$mapper = mapper;
              loop$events = events;
            }
          } else {
            let count = advance(prev);
            let moved_offset$1 = moved_offset - count;
            let events$1 = remove_child(events, path2, node_index, prev);
            let remove3 = remove_key(prev.key, count);
            let changes$1 = prepend(remove3, changes);
            loop$old = old_remaining;
            loop$old_keyed = old_keyed;
            loop$new = new$9;
            loop$new_keyed = new_keyed;
            loop$moved = moved;
            loop$moved_offset = moved_offset$1;
            loop$removed = removed;
            loop$node_index = node_index;
            loop$patch_index = patch_index;
            loop$path = path2;
            loop$changes = changes$1;
            loop$children = children;
            loop$mapper = mapper;
            loop$events = events$1;
          }
        } else if (prev_does_exist instanceof Ok) {
          let before = node_index - moved_offset;
          let count = advance(next2);
          let events$1 = add_child(
            events,
            mapper,
            path2,
            node_index,
            next2
          );
          let insert5 = insert4(toList([next2]), before);
          let changes$1 = prepend(insert5, changes);
          loop$old = old;
          loop$old_keyed = old_keyed;
          loop$new = new_remaining;
          loop$new_keyed = new_keyed;
          loop$moved = moved;
          loop$moved_offset = moved_offset + count;
          loop$removed = removed;
          loop$node_index = node_index + count;
          loop$patch_index = patch_index;
          loop$path = path2;
          loop$changes = changes$1;
          loop$children = children;
          loop$mapper = mapper;
          loop$events = events$1;
        } else {
          let prev_count = advance(prev);
          let next_count = advance(next2);
          let change = replace2(
            node_index - moved_offset,
            prev_count,
            next2
          );
          let _block;
          let _pipe = events;
          let _pipe$1 = remove_child(_pipe, path2, node_index, prev);
          _block = add_child(_pipe$1, mapper, path2, node_index, next2);
          let events$1 = _block;
          loop$old = old_remaining;
          loop$old_keyed = old_keyed;
          loop$new = new_remaining;
          loop$new_keyed = new_keyed;
          loop$moved = moved;
          loop$moved_offset = moved_offset - prev_count + next_count;
          loop$removed = removed;
          loop$node_index = node_index + next_count;
          loop$patch_index = patch_index;
          loop$path = path2;
          loop$changes = prepend(change, changes);
          loop$children = children;
          loop$mapper = mapper;
          loop$events = events$1;
        }
      } else {
        let $ = old.head;
        if ($ instanceof Fragment) {
          let $1 = new$9.head;
          if ($1 instanceof Fragment) {
            let next$1 = $1;
            let new$1 = new$9.tail;
            let prev$1 = $;
            let old$1 = old.tail;
            let node_index$1 = node_index + 1;
            let prev_count = prev$1.children_count;
            let next_count = next$1.children_count;
            let composed_mapper = compose_mapper(mapper, next$1.mapper);
            let child2 = do_diff(
              prev$1.children,
              prev$1.keyed_children,
              next$1.children,
              next$1.keyed_children,
              empty_set(),
              moved_offset,
              0,
              node_index$1,
              -1,
              path2,
              empty_list,
              children,
              composed_mapper,
              events
            );
            let _block;
            let $2 = child2.patch.removed > 0;
            if ($2) {
              let remove_from = node_index$1 + next_count - moved_offset;
              let patch = remove2(remove_from, child2.patch.removed);
              _block = append(
                child2.patch.changes,
                prepend(patch, changes)
              );
            } else {
              _block = append(child2.patch.changes, changes);
            }
            let changes$1 = _block;
            loop$old = old$1;
            loop$old_keyed = old_keyed;
            loop$new = new$1;
            loop$new_keyed = new_keyed;
            loop$moved = moved;
            loop$moved_offset = moved_offset + next_count - prev_count;
            loop$removed = removed;
            loop$node_index = node_index$1 + next_count;
            loop$patch_index = patch_index;
            loop$path = path2;
            loop$changes = changes$1;
            loop$children = child2.patch.children;
            loop$mapper = mapper;
            loop$events = child2.events;
          } else {
            let next$1 = $1;
            let new_remaining = new$9.tail;
            let prev$1 = $;
            let old_remaining = old.tail;
            let prev_count = advance(prev$1);
            let next_count = advance(next$1);
            let change = replace2(
              node_index - moved_offset,
              prev_count,
              next$1
            );
            let _block;
            let _pipe = events;
            let _pipe$1 = remove_child(_pipe, path2, node_index, prev$1);
            _block = add_child(
              _pipe$1,
              mapper,
              path2,
              node_index,
              next$1
            );
            let events$1 = _block;
            loop$old = old_remaining;
            loop$old_keyed = old_keyed;
            loop$new = new_remaining;
            loop$new_keyed = new_keyed;
            loop$moved = moved;
            loop$moved_offset = moved_offset - prev_count + next_count;
            loop$removed = removed;
            loop$node_index = node_index + next_count;
            loop$patch_index = patch_index;
            loop$path = path2;
            loop$changes = prepend(change, changes);
            loop$children = children;
            loop$mapper = mapper;
            loop$events = events$1;
          }
        } else if ($ instanceof Element2) {
          let $1 = new$9.head;
          if ($1 instanceof Element2) {
            let next$1 = $1;
            let prev$1 = $;
            if (prev$1.namespace === next$1.namespace && prev$1.tag === next$1.tag) {
              let new$1 = new$9.tail;
              let old$1 = old.tail;
              let composed_mapper = compose_mapper(
                mapper,
                next$1.mapper
              );
              let child_path = add3(path2, node_index, next$1.key);
              let controlled = is_controlled(
                events,
                next$1.namespace,
                next$1.tag,
                child_path
              );
              let $2 = diff_attributes(
                controlled,
                child_path,
                composed_mapper,
                events,
                prev$1.attributes,
                next$1.attributes,
                empty_list,
                empty_list
              );
              let added_attrs = $2.added;
              let removed_attrs = $2.removed;
              let events$1 = $2.events;
              let _block;
              if (removed_attrs instanceof Empty) {
                if (added_attrs instanceof Empty) {
                  _block = empty_list;
                } else {
                  _block = toList([update(added_attrs, removed_attrs)]);
                }
              } else {
                _block = toList([update(added_attrs, removed_attrs)]);
              }
              let initial_child_changes = _block;
              let child2 = do_diff(
                prev$1.children,
                prev$1.keyed_children,
                next$1.children,
                next$1.keyed_children,
                empty_set(),
                0,
                0,
                0,
                node_index,
                child_path,
                initial_child_changes,
                empty_list,
                composed_mapper,
                events$1
              );
              let _block$1;
              let $3 = child2.patch;
              let $4 = $3.children;
              if ($4 instanceof Empty) {
                let $5 = $3.changes;
                if ($5 instanceof Empty) {
                  let $6 = $3.removed;
                  if ($6 === 0) {
                    _block$1 = children;
                  } else {
                    _block$1 = prepend(child2.patch, children);
                  }
                } else {
                  _block$1 = prepend(child2.patch, children);
                }
              } else {
                _block$1 = prepend(child2.patch, children);
              }
              let children$1 = _block$1;
              loop$old = old$1;
              loop$old_keyed = old_keyed;
              loop$new = new$1;
              loop$new_keyed = new_keyed;
              loop$moved = moved;
              loop$moved_offset = moved_offset;
              loop$removed = removed;
              loop$node_index = node_index + 1;
              loop$patch_index = patch_index;
              loop$path = path2;
              loop$changes = changes;
              loop$children = children$1;
              loop$mapper = mapper;
              loop$events = child2.events;
            } else {
              let next$2 = $1;
              let new_remaining = new$9.tail;
              let prev$2 = $;
              let old_remaining = old.tail;
              let prev_count = advance(prev$2);
              let next_count = advance(next$2);
              let change = replace2(
                node_index - moved_offset,
                prev_count,
                next$2
              );
              let _block;
              let _pipe = events;
              let _pipe$1 = remove_child(
                _pipe,
                path2,
                node_index,
                prev$2
              );
              _block = add_child(
                _pipe$1,
                mapper,
                path2,
                node_index,
                next$2
              );
              let events$1 = _block;
              loop$old = old_remaining;
              loop$old_keyed = old_keyed;
              loop$new = new_remaining;
              loop$new_keyed = new_keyed;
              loop$moved = moved;
              loop$moved_offset = moved_offset - prev_count + next_count;
              loop$removed = removed;
              loop$node_index = node_index + next_count;
              loop$patch_index = patch_index;
              loop$path = path2;
              loop$changes = prepend(change, changes);
              loop$children = children;
              loop$mapper = mapper;
              loop$events = events$1;
            }
          } else {
            let next$1 = $1;
            let new_remaining = new$9.tail;
            let prev$1 = $;
            let old_remaining = old.tail;
            let prev_count = advance(prev$1);
            let next_count = advance(next$1);
            let change = replace2(
              node_index - moved_offset,
              prev_count,
              next$1
            );
            let _block;
            let _pipe = events;
            let _pipe$1 = remove_child(_pipe, path2, node_index, prev$1);
            _block = add_child(
              _pipe$1,
              mapper,
              path2,
              node_index,
              next$1
            );
            let events$1 = _block;
            loop$old = old_remaining;
            loop$old_keyed = old_keyed;
            loop$new = new_remaining;
            loop$new_keyed = new_keyed;
            loop$moved = moved;
            loop$moved_offset = moved_offset - prev_count + next_count;
            loop$removed = removed;
            loop$node_index = node_index + next_count;
            loop$patch_index = patch_index;
            loop$path = path2;
            loop$changes = prepend(change, changes);
            loop$children = children;
            loop$mapper = mapper;
            loop$events = events$1;
          }
        } else if ($ instanceof Text) {
          let $1 = new$9.head;
          if ($1 instanceof Text) {
            let next$1 = $1;
            let prev$1 = $;
            if (prev$1.content === next$1.content) {
              let new$1 = new$9.tail;
              let old$1 = old.tail;
              loop$old = old$1;
              loop$old_keyed = old_keyed;
              loop$new = new$1;
              loop$new_keyed = new_keyed;
              loop$moved = moved;
              loop$moved_offset = moved_offset;
              loop$removed = removed;
              loop$node_index = node_index + 1;
              loop$patch_index = patch_index;
              loop$path = path2;
              loop$changes = changes;
              loop$children = children;
              loop$mapper = mapper;
              loop$events = events;
            } else {
              let next$2 = $1;
              let new$1 = new$9.tail;
              let old$1 = old.tail;
              let child2 = new$5(
                node_index,
                0,
                toList([replace_text(next$2.content)]),
                empty_list
              );
              loop$old = old$1;
              loop$old_keyed = old_keyed;
              loop$new = new$1;
              loop$new_keyed = new_keyed;
              loop$moved = moved;
              loop$moved_offset = moved_offset;
              loop$removed = removed;
              loop$node_index = node_index + 1;
              loop$patch_index = patch_index;
              loop$path = path2;
              loop$changes = changes;
              loop$children = prepend(child2, children);
              loop$mapper = mapper;
              loop$events = events;
            }
          } else {
            let next$1 = $1;
            let new_remaining = new$9.tail;
            let prev$1 = $;
            let old_remaining = old.tail;
            let prev_count = advance(prev$1);
            let next_count = advance(next$1);
            let change = replace2(
              node_index - moved_offset,
              prev_count,
              next$1
            );
            let _block;
            let _pipe = events;
            let _pipe$1 = remove_child(_pipe, path2, node_index, prev$1);
            _block = add_child(
              _pipe$1,
              mapper,
              path2,
              node_index,
              next$1
            );
            let events$1 = _block;
            loop$old = old_remaining;
            loop$old_keyed = old_keyed;
            loop$new = new_remaining;
            loop$new_keyed = new_keyed;
            loop$moved = moved;
            loop$moved_offset = moved_offset - prev_count + next_count;
            loop$removed = removed;
            loop$node_index = node_index + next_count;
            loop$patch_index = patch_index;
            loop$path = path2;
            loop$changes = prepend(change, changes);
            loop$children = children;
            loop$mapper = mapper;
            loop$events = events$1;
          }
        } else {
          let $1 = new$9.head;
          if ($1 instanceof UnsafeInnerHtml) {
            let next$1 = $1;
            let new$1 = new$9.tail;
            let prev$1 = $;
            let old$1 = old.tail;
            let composed_mapper = compose_mapper(mapper, next$1.mapper);
            let child_path = add3(path2, node_index, next$1.key);
            let $2 = diff_attributes(
              false,
              child_path,
              composed_mapper,
              events,
              prev$1.attributes,
              next$1.attributes,
              empty_list,
              empty_list
            );
            let added_attrs = $2.added;
            let removed_attrs = $2.removed;
            let events$1 = $2.events;
            let _block;
            if (removed_attrs instanceof Empty) {
              if (added_attrs instanceof Empty) {
                _block = empty_list;
              } else {
                _block = toList([update(added_attrs, removed_attrs)]);
              }
            } else {
              _block = toList([update(added_attrs, removed_attrs)]);
            }
            let child_changes = _block;
            let _block$1;
            let $3 = prev$1.inner_html === next$1.inner_html;
            if ($3) {
              _block$1 = child_changes;
            } else {
              _block$1 = prepend(
                replace_inner_html(next$1.inner_html),
                child_changes
              );
            }
            let child_changes$1 = _block$1;
            let _block$2;
            if (child_changes$1 instanceof Empty) {
              _block$2 = children;
            } else {
              _block$2 = prepend(
                new$5(node_index, 0, child_changes$1, toList([])),
                children
              );
            }
            let children$1 = _block$2;
            loop$old = old$1;
            loop$old_keyed = old_keyed;
            loop$new = new$1;
            loop$new_keyed = new_keyed;
            loop$moved = moved;
            loop$moved_offset = moved_offset;
            loop$removed = removed;
            loop$node_index = node_index + 1;
            loop$patch_index = patch_index;
            loop$path = path2;
            loop$changes = changes;
            loop$children = children$1;
            loop$mapper = mapper;
            loop$events = events$1;
          } else {
            let next$1 = $1;
            let new_remaining = new$9.tail;
            let prev$1 = $;
            let old_remaining = old.tail;
            let prev_count = advance(prev$1);
            let next_count = advance(next$1);
            let change = replace2(
              node_index - moved_offset,
              prev_count,
              next$1
            );
            let _block;
            let _pipe = events;
            let _pipe$1 = remove_child(_pipe, path2, node_index, prev$1);
            _block = add_child(
              _pipe$1,
              mapper,
              path2,
              node_index,
              next$1
            );
            let events$1 = _block;
            loop$old = old_remaining;
            loop$old_keyed = old_keyed;
            loop$new = new_remaining;
            loop$new_keyed = new_keyed;
            loop$moved = moved;
            loop$moved_offset = moved_offset - prev_count + next_count;
            loop$removed = removed;
            loop$node_index = node_index + next_count;
            loop$patch_index = patch_index;
            loop$path = path2;
            loop$changes = prepend(change, changes);
            loop$children = children;
            loop$mapper = mapper;
            loop$events = events$1;
          }
        }
      }
    }
  }
}
function diff(events, old, new$9) {
  return do_diff(
    toList([old]),
    empty2(),
    toList([new$9]),
    empty2(),
    empty_set(),
    0,
    0,
    0,
    0,
    root2,
    empty_list,
    empty_list,
    identity3,
    tick(events)
  );
}

// build/dev/javascript/lustre/lustre/vdom/reconciler.ffi.mjs
var Reconciler = class {
  offset = 0;
  #root = null;
  #dispatch = () => {
  };
  #useServerEvents = false;
  #exposeKeys = false;
  constructor(root3, dispatch, { useServerEvents = false, exposeKeys = false } = {}) {
    this.#root = root3;
    this.#dispatch = dispatch;
    this.#useServerEvents = useServerEvents;
    this.#exposeKeys = exposeKeys;
  }
  mount(vdom) {
    appendChild(this.#root, this.#createChild(this.#root, 0, vdom));
  }
  #stack = [];
  push(patch) {
    const offset = this.offset;
    if (offset) {
      iterate(patch.changes, (change) => {
        switch (change.kind) {
          case insert_kind:
          case move_kind:
            change.before = (change.before | 0) + offset;
            break;
          case remove_kind:
          case replace_kind:
            change.from = (change.from | 0) + offset;
            break;
        }
      });
      iterate(patch.children, (child2) => {
        child2.index = (child2.index | 0) + offset;
      });
    }
    this.#stack.push({ node: this.#root, patch });
    this.#reconcile();
  }
  // PATCHING ------------------------------------------------------------------
  #reconcile() {
    const self = this;
    while (self.#stack.length) {
      const { node, patch } = self.#stack.pop();
      iterate(patch.changes, (change) => {
        switch (change.kind) {
          case insert_kind:
            self.#insert(node, change.children, change.before);
            break;
          case move_kind:
            self.#move(node, change.key, change.before, change.count);
            break;
          case remove_key_kind:
            self.#removeKey(node, change.key, change.count);
            break;
          case remove_kind:
            self.#remove(node, change.from, change.count);
            break;
          case replace_kind:
            self.#replace(node, change.from, change.count, change.with);
            break;
          case replace_text_kind:
            self.#replaceText(node, change.content);
            break;
          case replace_inner_html_kind:
            self.#replaceInnerHtml(node, change.inner_html);
            break;
          case update_kind:
            self.#update(node, change.added, change.removed);
            break;
        }
      });
      if (patch.removed) {
        self.#remove(
          node,
          node.childNodes.length - patch.removed,
          patch.removed
        );
      }
      let lastIndex = -1;
      let lastChild = null;
      iterate(patch.children, (child2) => {
        const index4 = child2.index | 0;
        const next2 = lastChild && lastIndex - index4 === 1 ? lastChild.previousSibling : childAt(node, index4);
        self.#stack.push({ node: next2, patch: child2 });
        lastChild = next2;
        lastIndex = index4;
      });
    }
  }
  // CHANGES -------------------------------------------------------------------
  #insert(node, children, before) {
    const fragment4 = createDocumentFragment();
    let childIndex = before | 0;
    iterate(children, (child2) => {
      const el = this.#createChild(node, childIndex, child2);
      appendChild(fragment4, el);
      childIndex += advance(child2);
    });
    insertBefore(node, fragment4, childAt(node, before));
  }
  #move(node, key, before, count) {
    let el = getKeyedChild(node, key);
    const beforeEl = childAt(node, before);
    for (let i = 0; i < count && el !== null; ++i) {
      const next2 = el.nextSibling;
      if (SUPPORTS_MOVE_BEFORE) {
        node.moveBefore(el, beforeEl);
      } else {
        insertBefore(node, el, beforeEl);
      }
      el = next2;
    }
  }
  #removeKey(node, key, count) {
    this.#removeFromChild(node, getKeyedChild(node, key), count);
  }
  #remove(node, from2, count) {
    this.#removeFromChild(node, childAt(node, from2), count);
  }
  #removeFromChild(parent, child2, count) {
    while (count-- > 0 && child2 !== null) {
      const next2 = child2.nextSibling;
      const key = child2[meta].key;
      if (key) {
        parent[meta].keyedChildren.delete(key);
      }
      for (const [_, { timeout }] of child2[meta].debouncers ?? []) {
        clearTimeout(timeout);
      }
      parent.removeChild(child2);
      child2 = next2;
    }
  }
  #replace(parent, from2, count, child2) {
    this.#remove(parent, from2, count);
    const el = this.#createChild(parent, from2, child2);
    insertBefore(parent, el, childAt(parent, from2));
  }
  #replaceText(node, content) {
    node.data = content ?? "";
  }
  #replaceInnerHtml(node, inner_html) {
    node.innerHTML = inner_html ?? "";
  }
  #update(node, added, removed) {
    iterate(removed, (attribute5) => {
      const name6 = attribute5.name;
      if (node[meta].handlers.has(name6)) {
        node.removeEventListener(name6, handleEvent);
        node[meta].handlers.delete(name6);
        if (node[meta].throttles.has(name6)) {
          node[meta].throttles.delete(name6);
        }
        if (node[meta].debouncers.has(name6)) {
          clearTimeout(node[meta].debouncers.get(name6).timeout);
          node[meta].debouncers.delete(name6);
        }
      } else {
        node.removeAttribute(name6);
        SYNCED_ATTRIBUTES[name6]?.removed?.(node, name6);
      }
    });
    iterate(added, (attribute5) => {
      this.#createAttribute(node, attribute5);
    });
  }
  // CONSTRUCTORS --------------------------------------------------------------
  #createChild(parent, index4, vnode) {
    switch (vnode.kind) {
      case element_kind: {
        const node = createChildElement(parent, index4, vnode);
        this.#createAttributes(node, vnode);
        this.#insert(node, vnode.children);
        return node;
      }
      case text_kind: {
        return createChildText(parent, index4, vnode);
      }
      case fragment_kind: {
        const node = createDocumentFragment();
        const head = createChildText(parent, index4, vnode);
        appendChild(node, head);
        let childIndex = index4 + 1;
        iterate(vnode.children, (child2) => {
          appendChild(node, this.#createChild(parent, childIndex, child2));
          childIndex += advance(child2);
        });
        return node;
      }
      case unsafe_inner_html_kind: {
        const node = createChildElement(parent, index4, vnode);
        this.#createAttributes(node, vnode);
        this.#replaceInnerHtml(node, vnode.inner_html);
        return node;
      }
    }
  }
  #createAttributes(node, { key, attributes }) {
    if (this.#exposeKeys && key) {
      node.setAttribute("data-lustre-key", key);
    }
    iterate(attributes, (attribute5) => this.#createAttribute(node, attribute5));
  }
  #createAttribute(node, attribute5) {
    const { debouncers, handlers, throttles } = node[meta];
    const {
      kind,
      name: name6,
      value: value2,
      prevent_default: prevent,
      stop_propagation: stop,
      immediate: immediate2,
      include,
      debounce: debounceDelay,
      throttle: throttleDelay
    } = attribute5;
    switch (kind) {
      case attribute_kind: {
        const valueOrDefault = value2 ?? "";
        if (name6 === "virtual:defaultValue") {
          node.defaultValue = valueOrDefault;
          return;
        }
        if (valueOrDefault !== node.getAttribute(name6)) {
          node.setAttribute(name6, valueOrDefault);
        }
        SYNCED_ATTRIBUTES[name6]?.added?.(node, value2);
        break;
      }
      case property_kind:
        node[name6] = value2;
        break;
      case event_kind: {
        if (handlers.has(name6)) {
          node.removeEventListener(name6, handleEvent);
        }
        node.addEventListener(name6, handleEvent, {
          passive: prevent.kind === never_kind
        });
        if (throttleDelay > 0) {
          const throttle = throttles.get(name6) ?? {};
          throttle.delay = throttleDelay;
          throttles.set(name6, throttle);
        } else {
          throttles.delete(name6);
        }
        if (debounceDelay > 0) {
          const debounce = debouncers.get(name6) ?? {};
          debounce.delay = debounceDelay;
          debouncers.set(name6, debounce);
        } else {
          clearTimeout(debouncers.get(name6)?.timeout);
          debouncers.delete(name6);
        }
        handlers.set(name6, (event4) => {
          if (prevent.kind === always_kind)
            event4.preventDefault();
          if (stop.kind === always_kind)
            event4.stopPropagation();
          const type = event4.type;
          const path2 = event4.currentTarget[meta].path;
          const data = this.#useServerEvents ? createServerEvent(event4, include ?? []) : event4;
          const throttle = throttles.get(type);
          if (throttle) {
            const now = Date.now();
            const last = throttle.last || 0;
            if (now > last + throttle.delay) {
              throttle.last = now;
              throttle.lastEvent = event4;
              this.#dispatch(data, path2, type, immediate2);
            }
          }
          const debounce = debouncers.get(type);
          if (debounce) {
            clearTimeout(debounce.timeout);
            debounce.timeout = setTimeout(() => {
              if (event4 === throttles.get(type)?.lastEvent)
                return;
              this.#dispatch(data, path2, type, immediate2);
            }, debounce.delay);
          }
          if (!throttle && !debounce) {
            this.#dispatch(data, path2, type, immediate2);
          }
        });
        break;
      }
    }
  }
};
var iterate = (list4, callback) => {
  if (Array.isArray(list4)) {
    for (let i = 0; i < list4.length; i++) {
      callback(list4[i]);
    }
  } else if (list4) {
    for (list4; list4.tail; list4 = list4.tail) {
      callback(list4.head);
    }
  }
};
var appendChild = (node, child2) => node.appendChild(child2);
var insertBefore = (parent, node, referenceNode) => parent.insertBefore(node, referenceNode ?? null);
var createChildElement = (parent, index4, { key, tag, namespace: namespace2 }) => {
  const node = document2().createElementNS(namespace2 || NAMESPACE_HTML, tag);
  initialiseMetadata(parent, node, index4, key);
  return node;
};
var createChildText = (parent, index4, { key, content }) => {
  const node = document2().createTextNode(content ?? "");
  initialiseMetadata(parent, node, index4, key);
  return node;
};
var createDocumentFragment = () => document2().createDocumentFragment();
var childAt = (node, at) => node.childNodes[at | 0];
var meta = Symbol("lustre");
var initialiseMetadata = (parent, node, index4 = 0, key = "") => {
  const segment = `${key || index4}`;
  switch (node.nodeType) {
    case ELEMENT_NODE:
    case DOCUMENT_FRAGMENT_NODE:
      node[meta] = {
        key,
        path: segment,
        keyedChildren: /* @__PURE__ */ new Map(),
        handlers: /* @__PURE__ */ new Map(),
        throttles: /* @__PURE__ */ new Map(),
        debouncers: /* @__PURE__ */ new Map()
      };
      break;
    case TEXT_NODE:
      node[meta] = { key };
      break;
  }
  if (parent && parent[meta] && key) {
    parent[meta].keyedChildren.set(key, new WeakRef(node));
  }
  if (parent && parent[meta] && parent[meta].path) {
    node[meta].path = `${parent[meta].path}${separator_element}${segment}`;
  }
};
var getKeyedChild = (node, key) => node[meta].keyedChildren.get(key).deref();
var handleEvent = (event4) => {
  const target = event4.currentTarget;
  const handler = target[meta].handlers.get(event4.type);
  if (event4.type === "submit") {
    event4.detail ??= {};
    event4.detail.formData = [...new FormData(event4.target).entries()];
  }
  handler(event4);
};
var createServerEvent = (event4, include = []) => {
  const data = {};
  if (event4.type === "input" || event4.type === "change") {
    include.push("target.value");
  }
  if (event4.type === "submit") {
    include.push("detail.formData");
  }
  for (const property3 of include) {
    const path2 = property3.split(".");
    for (let i = 0, input2 = event4, output = data; i < path2.length; i++) {
      if (i === path2.length - 1) {
        output[path2[i]] = input2[path2[i]];
        break;
      }
      output = output[path2[i]] ??= {};
      input2 = input2[path2[i]];
    }
  }
  return data;
};
var syncedBooleanAttribute = (name6) => {
  return {
    added(node) {
      node[name6] = true;
    },
    removed(node) {
      node[name6] = false;
    }
  };
};
var syncedAttribute = (name6) => {
  return {
    added(node, value2) {
      node[name6] = value2;
    }
  };
};
var SYNCED_ATTRIBUTES = {
  checked: syncedBooleanAttribute("checked"),
  selected: syncedBooleanAttribute("selected"),
  value: syncedAttribute("value"),
  autofocus: {
    added(node) {
      queueMicrotask(() => node.focus?.());
    }
  },
  autoplay: {
    added(node) {
      try {
        node.play?.();
      } catch (e) {
        console.error(e);
      }
    }
  }
};

// build/dev/javascript/lustre/lustre/vdom/virtualise.ffi.mjs
var virtualise = (root3) => {
  const vdom = virtualiseNode(null, root3, "");
  if (vdom === null || vdom.children instanceof Empty) {
    const empty3 = emptyTextNode(root3);
    root3.appendChild(empty3);
    return none2();
  } else if (vdom.children instanceof NonEmpty && vdom.children.tail instanceof Empty) {
    return vdom.children.head;
  } else {
    const head = emptyTextNode(root3);
    root3.insertBefore(head, root3.firstChild);
    return fragment2(vdom.children);
  }
};
var emptyTextNode = (parent) => {
  const node = document2().createTextNode("");
  initialiseMetadata(parent, node);
  return node;
};
var virtualiseNode = (parent, node, index4) => {
  switch (node.nodeType) {
    case ELEMENT_NODE: {
      const key = node.getAttribute("data-lustre-key");
      initialiseMetadata(parent, node, index4, key);
      if (key) {
        node.removeAttribute("data-lustre-key");
      }
      const tag = node.localName;
      const namespace2 = node.namespaceURI;
      const isHtmlElement = !namespace2 || namespace2 === NAMESPACE_HTML;
      if (isHtmlElement && INPUT_ELEMENTS.includes(tag)) {
        virtualiseInputEvents(tag, node);
      }
      const attributes = virtualiseAttributes(node);
      const children = virtualiseChildNodes(node);
      const vnode = isHtmlElement ? element2(tag, attributes, children) : namespaced(namespace2, tag, attributes, children);
      return key ? to_keyed(key, vnode) : vnode;
    }
    case TEXT_NODE:
      initialiseMetadata(parent, node, index4);
      return node.data ? text2(node.data) : null;
    case DOCUMENT_FRAGMENT_NODE:
      initialiseMetadata(parent, node, index4);
      return node.childNodes.length > 0 ? fragment2(virtualiseChildNodes(node)) : null;
    default:
      return null;
  }
};
var INPUT_ELEMENTS = ["input", "select", "textarea"];
var virtualiseInputEvents = (tag, node) => {
  const value2 = node.value;
  const checked = node.checked;
  if (tag === "input" && node.type === "checkbox" && !checked)
    return;
  if (tag === "input" && node.type === "radio" && !checked)
    return;
  if (node.type !== "checkbox" && node.type !== "radio" && !value2)
    return;
  queueMicrotask(() => {
    node.value = value2;
    node.checked = checked;
    node.dispatchEvent(new Event("input", { bubbles: true }));
    node.dispatchEvent(new Event("change", { bubbles: true }));
    if (document2().activeElement !== node) {
      node.dispatchEvent(new Event("blur", { bubbles: true }));
    }
  });
};
var virtualiseChildNodes = (node) => {
  let children = null;
  let index4 = 0;
  let child2 = node.firstChild;
  let ptr = null;
  while (child2) {
    const vnode = virtualiseNode(node, child2, index4);
    const next2 = child2.nextSibling;
    if (vnode) {
      const list_node = new NonEmpty(vnode, null);
      if (ptr) {
        ptr = ptr.tail = list_node;
      } else {
        ptr = children = list_node;
      }
      index4 += 1;
    } else {
      node.removeChild(child2);
    }
    child2 = next2;
  }
  if (!ptr)
    return empty_list;
  ptr.tail = empty_list;
  return children;
};
var virtualiseAttributes = (node) => {
  let index4 = node.attributes.length;
  let attributes = empty_list;
  while (index4-- > 0) {
    attributes = new NonEmpty(
      virtualiseAttribute(node.attributes[index4]),
      attributes
    );
  }
  return attributes;
};
var virtualiseAttribute = (attr) => {
  const name6 = attr.localName;
  const value2 = attr.value;
  return attribute2(name6, value2);
};

// build/dev/javascript/lustre/lustre/runtime/client/runtime.ffi.mjs
var is_browser = () => !!document2();
var Runtime = class {
  constructor(root3, [model, effects], view5, update6) {
    this.root = root3;
    this.#model = model;
    this.#view = view5;
    this.#update = update6;
    this.#reconciler = new Reconciler(this.root, (event4, path2, name6) => {
      const [events, result] = handle(this.#events, path2, name6, event4);
      this.#events = events;
      if (result.isOk()) {
        const handler = result[0];
        if (handler.stop_propagation)
          event4.stopPropagation();
        if (handler.prevent_default)
          event4.preventDefault();
        this.dispatch(handler.message, false);
      }
    });
    this.#vdom = virtualise(this.root);
    this.#events = new$3();
    this.#shouldFlush = true;
    this.#tick(effects);
  }
  // PUBLIC API ----------------------------------------------------------------
  root = null;
  set offset(offset) {
    this.#reconciler.offset = offset;
  }
  dispatch(msg, immediate2 = false) {
    this.#shouldFlush ||= immediate2;
    if (this.#shouldQueue) {
      this.#queue.push(msg);
    } else {
      const [model, effects] = this.#update(this.#model, msg);
      this.#model = model;
      this.#tick(effects);
    }
  }
  emit(event4, data) {
    const target = this.root.host ?? this.root;
    target.dispatchEvent(
      new CustomEvent(event4, {
        detail: data,
        bubbles: true,
        composed: true
      })
    );
  }
  // PRIVATE API ---------------------------------------------------------------
  #model;
  #view;
  #update;
  #vdom;
  #events;
  #reconciler;
  #shouldQueue = false;
  #queue = [];
  #beforePaint = empty_list;
  #afterPaint = empty_list;
  #renderTimer = null;
  #shouldFlush = false;
  #actions = {
    dispatch: (msg, immediate2) => this.dispatch(msg, immediate2),
    emit: (event4, data) => this.emit(event4, data),
    select: () => {
    },
    root: () => this.root
  };
  // A `#tick` is where we process effects and trigger any synchronous updates.
  // Once a tick has been processed a render will be scheduled if none is already.
  // p0
  #tick(effects) {
    this.#shouldQueue = true;
    while (true) {
      for (let list4 = effects.synchronous; list4.tail; list4 = list4.tail) {
        list4.head(this.#actions);
      }
      this.#beforePaint = listAppend(this.#beforePaint, effects.before_paint);
      this.#afterPaint = listAppend(this.#afterPaint, effects.after_paint);
      if (!this.#queue.length)
        break;
      [this.#model, effects] = this.#update(this.#model, this.#queue.shift());
    }
    this.#shouldQueue = false;
    if (this.#shouldFlush) {
      cancelAnimationFrame(this.#renderTimer);
      this.#render();
    } else if (!this.#renderTimer) {
      this.#renderTimer = requestAnimationFrame(() => {
        this.#render();
      });
    }
  }
  #render() {
    this.#shouldFlush = false;
    this.#renderTimer = null;
    const next2 = this.#view(this.#model);
    const { patch, events } = diff(this.#events, this.#vdom, next2);
    this.#events = events;
    this.#vdom = next2;
    this.#reconciler.push(patch);
    if (this.#beforePaint instanceof NonEmpty) {
      const effects = makeEffect(this.#beforePaint);
      this.#beforePaint = empty_list;
      queueMicrotask(() => {
        this.#shouldFlush = true;
        this.#tick(effects);
      });
    }
    if (this.#afterPaint instanceof NonEmpty) {
      const effects = makeEffect(this.#afterPaint);
      this.#afterPaint = empty_list;
      requestAnimationFrame(() => {
        this.#shouldFlush = true;
        this.#tick(effects);
      });
    }
  }
};
function makeEffect(synchronous) {
  return {
    synchronous,
    after_paint: empty_list,
    before_paint: empty_list
  };
}
function listAppend(a, b) {
  if (a instanceof Empty) {
    return b;
  } else if (b instanceof Empty) {
    return a;
  } else {
    return append(a, b);
  }
}
var copiedStyleSheets = /* @__PURE__ */ new WeakMap();
async function adoptStylesheets(shadowRoot) {
  const pendingParentStylesheets = [];
  for (const node of document2().querySelectorAll(
    "link[rel=stylesheet], style"
  )) {
    if (node.sheet)
      continue;
    pendingParentStylesheets.push(
      new Promise((resolve, reject) => {
        node.addEventListener("load", resolve);
        node.addEventListener("error", reject);
      })
    );
  }
  await Promise.allSettled(pendingParentStylesheets);
  if (!shadowRoot.host.isConnected) {
    return [];
  }
  shadowRoot.adoptedStyleSheets = shadowRoot.host.getRootNode().adoptedStyleSheets;
  const pending = [];
  for (const sheet of document2().styleSheets) {
    try {
      shadowRoot.adoptedStyleSheets.push(sheet);
    } catch {
      try {
        let copiedSheet = copiedStyleSheets.get(sheet);
        if (!copiedSheet) {
          copiedSheet = new CSSStyleSheet();
          for (const rule of sheet.cssRules) {
            copiedSheet.insertRule(rule.cssText, copiedSheet.cssRules.length);
          }
          copiedStyleSheets.set(sheet, copiedSheet);
        }
        shadowRoot.adoptedStyleSheets.push(copiedSheet);
      } catch {
        const node = sheet.ownerNode.cloneNode();
        shadowRoot.prepend(node);
        pending.push(node);
      }
    }
  }
  return pending;
}

// build/dev/javascript/lustre/lustre/runtime/server/runtime.mjs
var EffectDispatchedMessage = class extends CustomType {
  constructor(message) {
    super();
    this.message = message;
  }
};
var EffectEmitEvent = class extends CustomType {
  constructor(name6, data) {
    super();
    this.name = name6;
    this.data = data;
  }
};
var SystemRequestedShutdown = class extends CustomType {
};

// build/dev/javascript/lustre/lustre/runtime/client/component.ffi.mjs
var make_component = ({ init: init5, update: update6, view: view5, config }, name6) => {
  if (!is_browser())
    return new Error(new NotABrowser());
  if (!name6.includes("-"))
    return new Error(new BadComponentName(name6));
  if (customElements.get(name6)) {
    return new Error(new ComponentAlreadyRegistered(name6));
  }
  const [model, effects] = init5(void 0);
  const observedAttributes = config.attributes.entries().map(([name7]) => name7);
  const component2 = class Component extends HTMLElement {
    static get observedAttributes() {
      return observedAttributes;
    }
    static formAssociated = config.is_form_associated;
    #runtime;
    #adoptedStyleNodes = [];
    #shadowRoot;
    constructor() {
      super();
      this.internals = this.attachInternals();
      if (!this.internals.shadowRoot) {
        this.#shadowRoot = this.attachShadow({
          mode: config.open_shadow_root ? "open" : "closed"
        });
      } else {
        this.#shadowRoot = this.internals.shadowRoot;
      }
      if (config.adopt_styles) {
        this.#adoptStyleSheets();
      }
      this.#runtime = new Runtime(
        this.#shadowRoot,
        [model, effects],
        view5,
        update6
      );
    }
    adoptedCallback() {
      if (config.adopt_styles) {
        this.#adoptStyleSheets();
      }
    }
    attributeChangedCallback(name7, _, value2) {
      const decoded = config.attributes.get(name7)(value2);
      if (decoded.constructor === Ok) {
        this.dispatch(decoded[0]);
      }
    }
    formResetCallback() {
      if (config.on_form_reset instanceof Some) {
        this.dispatch(config.on_form_reset[0]);
      }
    }
    formStateRestoreCallback(state, reason) {
      switch (reason) {
        case "restore":
          if (config.on_form_restore instanceof Some) {
            this.dispatch(config.on_form_restore[0](state));
          }
          break;
        case "autocomplete":
          if (config.on_form_populate instanceof Some) {
            this.dispatch(config.on_form_autofill[0](state));
          }
          break;
      }
    }
    send(message) {
      switch (message.constructor) {
        case EffectDispatchedMessage: {
          this.dispatch(message.message, false);
          break;
        }
        case EffectEmitEvent: {
          this.emit(message.name, message.data);
          break;
        }
        case SystemRequestedShutdown:
          break;
      }
    }
    dispatch(msg, immediate2 = false) {
      this.#runtime.dispatch(msg, immediate2);
    }
    emit(event4, data) {
      this.#runtime.emit(event4, data);
    }
    async #adoptStyleSheets() {
      while (this.#adoptedStyleNodes.length) {
        this.#adoptedStyleNodes.pop().remove();
        this.shadowRoot.firstChild.remove();
      }
      this.#adoptedStyleNodes = await adoptStylesheets(this.#shadowRoot);
      this.#runtime.offset = this.#adoptedStyleNodes.length;
    }
  };
  config.properties.forEach((decoder, name7) => {
    Object.defineProperty(component2.prototype, name7, {
      get() {
        return this[`_${name7}`];
      },
      set(value2) {
        this[`_${name7}`] = value2;
        const decoded = run(value2, decoder);
        if (decoded.constructor === Ok) {
          this.dispatch(decoded[0]);
        }
      }
    });
  });
  customElements.define(name6, component2);
  return new Ok(void 0);
};
var set_pseudo_state = (root3, value2) => {
  if (!is_browser())
    return;
  if (root3 instanceof ShadowRoot) {
    root3.host.internals.states.add(value2);
  }
};
var remove_pseudo_state = (root3, value2) => {
  if (!is_browser())
    return;
  if (root3 instanceof ShadowRoot) {
    root3.host.internals.states.delete(value2);
  }
};

// build/dev/javascript/lustre/lustre/component.mjs
var Config2 = class extends CustomType {
  constructor(open_shadow_root, adopt_styles2, attributes, properties, is_form_associated, on_form_autofill, on_form_reset, on_form_restore) {
    super();
    this.open_shadow_root = open_shadow_root;
    this.adopt_styles = adopt_styles2;
    this.attributes = attributes;
    this.properties = properties;
    this.is_form_associated = is_form_associated;
    this.on_form_autofill = on_form_autofill;
    this.on_form_reset = on_form_reset;
    this.on_form_restore = on_form_restore;
  }
};
var Option = class extends CustomType {
  constructor(apply) {
    super();
    this.apply = apply;
  }
};
function new$6(options) {
  let init5 = new Config2(
    false,
    true,
    empty_dict(),
    empty_dict(),
    false,
    option_none,
    option_none,
    option_none
  );
  return fold2(
    options,
    init5,
    (config, option) => {
      return option.apply(config);
    }
  );
}
function on_attribute_change(name6, decoder) {
  return new Option(
    (config) => {
      let attributes = insert(config.attributes, name6, decoder);
      let _record = config;
      return new Config2(
        _record.open_shadow_root,
        _record.adopt_styles,
        attributes,
        _record.properties,
        _record.is_form_associated,
        _record.on_form_autofill,
        _record.on_form_reset,
        _record.on_form_restore
      );
    }
  );
}
function adopt_styles(adopt) {
  return new Option(
    (config) => {
      let _record = config;
      return new Config2(
        _record.open_shadow_root,
        adopt,
        _record.attributes,
        _record.properties,
        _record.is_form_associated,
        _record.on_form_autofill,
        _record.on_form_reset,
        _record.on_form_restore
      );
    }
  );
}
function set_pseudo_state2(value2) {
  return before_paint(
    (_, root3) => {
      return set_pseudo_state(root3, value2);
    }
  );
}
function remove_pseudo_state2(value2) {
  return before_paint(
    (_, root3) => {
      return remove_pseudo_state(root3, value2);
    }
  );
}

// build/dev/javascript/lustre/lustre/runtime/client/spa.ffi.mjs
var Spa = class _Spa {
  static start({ init: init5, update: update6, view: view5 }, selector, flags) {
    if (!is_browser())
      return new Error(new NotABrowser());
    const root3 = selector instanceof HTMLElement ? selector : document2().querySelector(selector);
    if (!root3)
      return new Error(new ElementNotFound(selector));
    return new Ok(new _Spa(root3, init5(flags), update6, view5));
  }
  #runtime;
  constructor(root3, [init5, effects], update6, view5) {
    this.#runtime = new Runtime(root3, [init5, effects], view5, update6);
  }
  send(message) {
    switch (message.constructor) {
      case EffectDispatchedMessage: {
        this.dispatch(message.message, false);
        break;
      }
      case EffectEmitEvent: {
        this.emit(message.name, message.data);
        break;
      }
      case SystemRequestedShutdown:
        break;
    }
  }
  dispatch(msg, immediate2) {
    this.#runtime.dispatch(msg, immediate2);
  }
  emit(event4, data) {
    this.#runtime.emit(event4, data);
  }
};
var start = Spa.start;

// build/dev/javascript/lustre/lustre.mjs
var App = class extends CustomType {
  constructor(init5, update6, view5, config) {
    super();
    this.init = init5;
    this.update = update6;
    this.view = view5;
    this.config = config;
  }
};
var BadComponentName = class extends CustomType {
  constructor(name6) {
    super();
    this.name = name6;
  }
};
var ComponentAlreadyRegistered = class extends CustomType {
  constructor(name6) {
    super();
    this.name = name6;
  }
};
var ElementNotFound = class extends CustomType {
  constructor(selector) {
    super();
    this.selector = selector;
  }
};
var NotABrowser = class extends CustomType {
};
function component(init5, update6, view5, options) {
  return new App(init5, update6, view5, new$6(options));
}

// build/dev/javascript/gleam_stdlib/gleam/pair.mjs
function first2(pair) {
  let a = pair[0];
  return a;
}
function second(pair) {
  let a = pair[1];
  return a;
}

// build/dev/javascript/lustre/lustre/event.mjs
function emit(event4, data) {
  return event2(event4, data);
}
function is_immediate_event(name6) {
  if (name6 === "input") {
    return true;
  } else if (name6 === "change") {
    return true;
  } else if (name6 === "focus") {
    return true;
  } else if (name6 === "focusin") {
    return true;
  } else if (name6 === "focusout") {
    return true;
  } else if (name6 === "blur") {
    return true;
  } else if (name6 === "select") {
    return true;
  } else {
    return false;
  }
}
function on(name6, handler) {
  return event(
    name6,
    map2(handler, (msg) => {
      return new Handler(false, false, msg);
    }),
    empty_list,
    never,
    never,
    is_immediate_event(name6),
    0,
    0
  );
}
function on_mouse_down(msg) {
  return on("mousedown", success(msg));
}
function on_mouse_over(msg) {
  return on("mouseover", success(msg));
}
function on_input(msg) {
  return on(
    "input",
    subfield(
      toList(["target", "value"]),
      string2,
      (value2) => {
        return success(msg(value2));
      }
    )
  );
}
function on_focus(msg) {
  return on("focus", success(msg));
}
function on_blur(msg) {
  return on("blur", success(msg));
}

// build/dev/javascript/lustre_ui/lustre/ffi/dom.ffi.mjs
var assigned_elements = (slot2) => {
  if (!(slot2 instanceof HTMLSlotElement))
    return new Error(void 0);
  const elements = slot2.assignedElements();
  return new Ok(List.fromArray(elements));
};
var bounding_client_rect = (element7) => {
  if (!(element7 instanceof HTMLElement))
    return new Error(void 0);
  const rect = element7.getBoundingClientRect();
  return new Ok(
    new BoundingClientRect(
      rect.top,
      rect.right,
      rect.bottom,
      rect.left,
      rect.width,
      rect.height
    )
  );
};
var attribute3 = (element7, name6) => {
  if (!(element7 instanceof HTMLElement))
    return new Error(void 0);
  if (typeof name6 !== "string")
    return new Error(void 0);
  const value2 = element7.getAttribute(name6);
  if (value2 === null) {
    return new Error(void 0);
  } else {
    return new Ok(value2);
  }
};
var prevent_default = (event4) => {
  if (!(event4 instanceof Event))
    return;
  event4.preventDefault();
};
var find_element = (selector, root3 = document) => {
  if (typeof selector !== "string")
    return new Error(void 0);
  if (!(root3 instanceof Document || root3 instanceof Element))
    return new Error(void 0);
  const element7 = root3.querySelector(selector);
  if (element7 === null) {
    return new Error(void 0);
  } else {
    return new Ok(element7);
  }
};
var focus = (element7) => {
  if (!(element7 instanceof HTMLElement))
    return;
  element7.focus();
};

// build/dev/javascript/lustre_ui/lustre/ffi/dom.mjs
var BoundingClientRect = class extends CustomType {
  constructor(top, right, bottom, left, width, height) {
    super();
    this.top = top;
    this.right = right;
    this.bottom = bottom;
    this.left = left;
    this.width = width;
    this.height = height;
  }
};
function assigned_elements2(decoder, lenient) {
  let lenient_decoder = one_of(
    map2(decoder, (var0) => {
      return new Ok(var0);
    }),
    toList([success(new Error(void 0))])
  );
  return new_primitive_decoder(
    "HTMLSlotElement.assignedElements()",
    (slot2) => {
      let $ = assigned_elements(slot2);
      if ($ instanceof Ok) {
        if (lenient) {
          let elements = $[0];
          let _pipe = elements;
          let _pipe$1 = try_map(
            _pipe,
            (_capture) => {
              return run(_capture, lenient_decoder);
            }
          );
          let _pipe$2 = map3(
            _pipe$1,
            (_capture) => {
              return filter_map(_capture, identity3);
            }
          );
          return replace_error(_pipe$2, toList([]));
        } else {
          let elements = $[0];
          let _pipe = elements;
          let _pipe$1 = try_map(
            _pipe,
            (_capture) => {
              return run(_capture, decoder);
            }
          );
          return replace_error(_pipe$1, toList([]));
        }
      } else {
        return new Error(toList([]));
      }
    }
  );
}
function bounding_client_rect2() {
  return new_primitive_decoder(
    "Element.getBoundingClientRect()",
    (element7) => {
      let $ = bounding_client_rect(element7);
      if ($ instanceof Ok) {
        let rect = $[0];
        return new Ok(rect);
      } else {
        return new Error(new BoundingClientRect(0, 0, 0, 0, 0, 0));
      }
    }
  );
}
function attribute4(name6) {
  return new_primitive_decoder(
    "Element.getAttribute()",
    (element7) => {
      let $ = attribute3(element7, name6);
      if ($ instanceof Ok) {
        let value2 = $[0];
        return new Ok(value2);
      } else {
        return new Error("");
      }
    }
  );
}
function prevent_default2(event4) {
  return from((_) => {
    return prevent_default(event4);
  });
}
function child(selector, zero, decoder) {
  return new_primitive_decoder(
    "Element.querySelector()",
    (element7) => {
      let $ = find_element(selector, element7);
      if ($ instanceof Ok) {
        let child$1 = $[0];
        let _pipe = run(child$1, decoder);
        return replace_error(_pipe, zero);
      } else {
        return new Error(zero);
      }
    }
  );
}
function focus2(selector) {
  return before_paint(
    (_, root3) => {
      let $ = find_element(selector, root3);
      if ($ instanceof Ok) {
        let element7 = $[0];
        return focus(element7);
      } else {
        return void 0;
      }
    }
  );
}

// build/dev/javascript/lustre_ui/lustre/ui/primitives/collapse.mjs
var Model = class extends CustomType {
  constructor(height, expanded2) {
    super();
    this.height = height;
    this.expanded = expanded2;
  }
};
var ParentChangedContent = class extends CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
};
var ParentSetExpanded = class extends CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
};
var UserPressedTrigger = class extends CustomType {
  constructor($0, event4) {
    super();
    this[0] = $0;
    this.event = event4;
  }
};
function expanded(is_expanded) {
  return attribute2(
    "aria-expanded",
    (() => {
      let _pipe = to_string2(is_expanded);
      return lowercase(_pipe);
    })()
  );
}
function on_change(handler) {
  return on(
    "change",
    subfield(
      toList(["detail", "expanded"]),
      bool,
      (expanded2) => {
        return success(handler(expanded2));
      }
    )
  );
}
function init(_) {
  let model = new Model(0, false);
  let effect = none();
  return [model, effect];
}
function update2(model, msg) {
  if (msg instanceof ParentChangedContent) {
    let height = msg[0];
    return [
      (() => {
        let _record = model;
        return new Model(height, _record.expanded);
      })(),
      none()
    ];
  } else if (msg instanceof ParentSetExpanded) {
    let expanded$1 = msg[0];
    return [
      (() => {
        let _record = model;
        return new Model(_record.height, expanded$1);
      })(),
      none()
    ];
  } else {
    let height = msg[0];
    let event4 = msg.event;
    let _block;
    let _record = model;
    _block = new Model(height, _record.expanded);
    let model$1 = _block;
    let emit_change = emit(
      "change",
      object2(toList([["expanded", bool2(!model$1.expanded)]]))
    );
    let _block$1;
    let $ = model$1.expanded;
    if ($) {
      _block$1 = emit("collapse", null$());
    } else {
      _block$1 = emit("expand", null$());
    }
    let emit_expand_collapse = _block$1;
    let effect = batch(
      toList([emit_change, emit_expand_collapse, prevent_default2(event4)])
    );
    return [model$1, effect];
  }
}
function handle_click() {
  return subfield(
    toList(["currentTarget", "nextElementSibling", "firstElementChild"]),
    assigned_elements2(
      (() => {
        let _pipe = bounding_client_rect2();
        return map2(_pipe, (rect) => {
          return rect.height;
        });
      })(),
      false
    ),
    (heights) => {
      let height = sum(heights);
      return success(new UserPressedTrigger(height, nil()));
    }
  );
}
function handle_keydown() {
  return then$(
    dynamic,
    (event4) => {
      return field(
        "key",
        string2,
        (key) => {
          if (key === "Enter") {
            return subfield(
              toList([
                "currentTarget",
                "nextElementSibling",
                "firstElementChild"
              ]),
              assigned_elements2(
                (() => {
                  let _pipe = bounding_client_rect2();
                  return map2(_pipe, (rect) => {
                    return rect.height;
                  });
                })(),
                false
              ),
              (heights) => {
                let height = sum(heights);
                return success(new UserPressedTrigger(height, event4));
              }
            );
          } else if (key === " ") {
            return subfield(
              toList([
                "currentTarget",
                "nextElementSibling",
                "firstElementChild"
              ]),
              assigned_elements2(
                (() => {
                  let _pipe = bounding_client_rect2();
                  return map2(_pipe, (rect) => {
                    return rect.height;
                  });
                })(),
                false
              ),
              (heights) => {
                let height = sum(heights);
                return success(new UserPressedTrigger(height, event4));
              }
            );
          } else {
            return failure(
              new UserPressedTrigger(0, nil()),
              ""
            );
          }
        }
      );
    }
  );
}
function view_trigger() {
  return slot(
    toList([
      attribute2("part", "collapse-trigger"),
      name("trigger"),
      on("click", handle_click()),
      on("keydown", handle_keydown())
    ]),
    toList([])
  );
}
function handle_slot_change() {
  return subfield(
    toList(["currentTarget", "nextElementSibling", "firstElementChild"]),
    assigned_elements2(
      (() => {
        let _pipe = bounding_client_rect2();
        return map2(_pipe, (rect) => {
          return rect.height;
        });
      })(),
      false
    ),
    (heights) => {
      let height = sum(heights);
      return success(new ParentChangedContent(height));
    }
  );
}
function view_content(height) {
  return div(
    toList([
      attribute2("part", "collapse-content"),
      styles(
        toList([["transition-duration", "inherit"], ["height", height]])
      )
    ]),
    toList([
      slot(
        toList([on("slotchange", handle_slot_change())]),
        toList([])
      )
    ])
  );
}
var name2 = "lustre-ui-collapse";
function element3(attributes, trigger, content) {
  return element2(
    name2,
    attributes,
    toList([
      div(toList([attribute2("slot", "trigger")]), toList([trigger])),
      content
    ])
  );
}
function view(model) {
  let _block;
  let $ = model.expanded;
  if ($) {
    _block = float_to_string(model.height) + "px";
  } else {
    _block = "0px";
  }
  let height = _block;
  return fragment2(toList([view_trigger(), view_content(height)]));
}
function register() {
  let app = component(
    init,
    update2,
    view,
    toList([
      adopt_styles(true),
      on_attribute_change(
        "aria-expanded",
        (value2) => {
          if (value2 === "true") {
            return new Ok(new ParentSetExpanded(true));
          } else if (value2 === "false") {
            return new Ok(new ParentSetExpanded(false));
          } else if (value2 === "") {
            return new Ok(new ParentSetExpanded(false));
          } else {
            return new Error(void 0);
          }
        }
      )
    ])
  );
  return make_component(app, name2);
}

// build/dev/javascript/lustre_ui/lustre/ui/primitives/popover.mjs
var TopLeft = class extends CustomType {
};
var TopMiddle = class extends CustomType {
};
var TopRight = class extends CustomType {
};
var RightTop = class extends CustomType {
};
var RightMiddle = class extends CustomType {
};
var RightBottom = class extends CustomType {
};
var BottomLeft = class extends CustomType {
};
var BottomMiddle = class extends CustomType {
};
var BottomRight = class extends CustomType {
};
var LeftTop = class extends CustomType {
};
var LeftMiddle = class extends CustomType {
};
var WillExpand = class extends CustomType {
};
var Expanded = class extends CustomType {
};
var WillCollapse = class extends CustomType {
};
var Collapsing = class extends CustomType {
};
var Collapsed = class extends CustomType {
};
var ParentSetOpen = class extends CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
};
var SchedulerDidTick = class extends CustomType {
};
var TransitionDidEnd = class extends CustomType {
};
var UserPressedTrigger2 = class extends CustomType {
  constructor(event4) {
    super();
    this.event = event4;
  }
};
function open(is_open) {
  return attribute2(
    "aria-expanded",
    (() => {
      let _pipe = to_string2(is_open);
      return lowercase(_pipe);
    })()
  );
}
function anchor(direction) {
  return attribute2(
    "anchor",
    (() => {
      if (direction instanceof TopLeft) {
        return "top-left";
      } else if (direction instanceof TopMiddle) {
        return "top-middle";
      } else if (direction instanceof TopRight) {
        return "top-right";
      } else if (direction instanceof RightTop) {
        return "right-top";
      } else if (direction instanceof RightMiddle) {
        return "right-middle";
      } else if (direction instanceof RightBottom) {
        return "right-bottom";
      } else if (direction instanceof BottomLeft) {
        return "bottom-left";
      } else if (direction instanceof BottomMiddle) {
        return "bottom-middle";
      } else if (direction instanceof BottomRight) {
        return "bottom-right";
      } else if (direction instanceof LeftTop) {
        return "left-top";
      } else if (direction instanceof LeftMiddle) {
        return "left-middle";
      } else {
        return "left-bottom";
      }
    })()
  );
}
function equal_width() {
  return attribute2("equal-width", "");
}
function gap(value2) {
  return style("--gap", value2);
}
function on_open(handler) {
  return on("open", success(handler));
}
function on_close(handler) {
  return on("close", success(handler));
}
function init2(_) {
  let model = new Collapsed();
  let effect = batch(toList([set_pseudo_state2("collapsed")]));
  return [model, effect];
}
function tick2() {
  return after_paint(
    (dispatch, _) => {
      return dispatch(new SchedulerDidTick());
    }
  );
}
function update3(model, msg) {
  let $ = echo(msg, "src/lustre/ui/primitives/popover.gleam", 162);
  if ($ instanceof ParentSetOpen) {
    let $1 = $[0];
    if ($1) {
      if (model instanceof WillCollapse) {
        return [
          new WillExpand(),
          batch(
            toList([tick2(), set_pseudo_state2("will-expand")])
          )
        ];
      } else if (model instanceof Collapsed) {
        return [
          new WillExpand(),
          batch(
            toList([tick2(), set_pseudo_state2("will-expand")])
          )
        ];
      } else {
        return [model, none()];
      }
    } else if (model instanceof WillExpand) {
      return [
        new WillCollapse(),
        batch(
          toList([tick2(), set_pseudo_state2("will-collapse")])
        )
      ];
    } else if (model instanceof Expanded) {
      return [
        new WillCollapse(),
        batch(
          toList([tick2(), set_pseudo_state2("will-collapse")])
        )
      ];
    } else {
      return [model, none()];
    }
  } else if ($ instanceof SchedulerDidTick) {
    if (model instanceof WillExpand) {
      return [new Expanded(), set_pseudo_state2("expanded")];
    } else if (model instanceof WillCollapse) {
      return [new Collapsing(), set_pseudo_state2("collapsing")];
    } else {
      return [model, none()];
    }
  } else if ($ instanceof TransitionDidEnd) {
    if (model instanceof Collapsing) {
      return [new Collapsed(), set_pseudo_state2("collapsed")];
    } else {
      return [model, none()];
    }
  } else if (model instanceof WillExpand) {
    let event4 = $.event;
    return [
      model,
      batch(
        toList([
          emit("close", null$()),
          emit(
            "change",
            object2(toList([["open", bool2(false)]]))
          ),
          prevent_default2(event4)
        ])
      )
    ];
  } else if (model instanceof Expanded) {
    let event4 = $.event;
    return [
      model,
      batch(
        toList([
          emit("close", null$()),
          emit(
            "change",
            object2(toList([["open", bool2(false)]]))
          ),
          prevent_default2(event4)
        ])
      )
    ];
  } else if (model instanceof WillCollapse) {
    let event4 = $.event;
    return [
      model,
      batch(
        toList([
          emit("open", null$()),
          emit(
            "change",
            object2(toList([["open", bool2(true)]]))
          ),
          prevent_default2(event4)
        ])
      )
    ];
  } else if (model instanceof Collapsing) {
    let event4 = $.event;
    return [
      model,
      batch(
        toList([
          emit("open", null$()),
          emit(
            "change",
            object2(toList([["open", bool2(true)]]))
          ),
          prevent_default2(event4)
        ])
      )
    ];
  } else {
    let event4 = $.event;
    return [
      model,
      batch(
        toList([
          emit("open", null$()),
          emit(
            "change",
            object2(toList([["open", bool2(true)]]))
          ),
          prevent_default2(event4)
        ])
      )
    ];
  }
}
function handle_keydown2() {
  return then$(
    dynamic,
    (event4) => {
      return field(
        "key",
        string2,
        (key) => {
          if (key === "Enter") {
            return success(new UserPressedTrigger2(event4));
          } else if (key === " ") {
            return success(new UserPressedTrigger2(event4));
          } else {
            return failure(new UserPressedTrigger2(event4), "");
          }
        }
      );
    }
  );
}
function view_trigger2() {
  return slot(
    toList([
      name("trigger"),
      on(
        "click",
        map2(
          dynamic,
          (var0) => {
            return new UserPressedTrigger2(var0);
          }
        )
      ),
      on("keydown", handle_keydown2())
    ]),
    toList([])
  );
}
function view_popover(model) {
  return guard(
    isEqual(model, new Collapsed()),
    text3(""),
    () => {
      return div(
        toList([
          attribute2("part", "popover-content"),
          on("transitionend", success(new TransitionDidEnd()))
        ]),
        toList([slot(toList([name("popover")]), toList([]))])
      );
    }
  );
}
function view2(model) {
  return div(
    toList([style("position", "relative")]),
    toList([view_trigger2(), view_popover(model)])
  );
}
var name3 = "lustre-ui-popover";
function register2() {
  let app = component(
    init2,
    update3,
    view2,
    toList([
      adopt_styles(true),
      on_attribute_change(
        "aria-expanded",
        (value2) => {
          if (value2 === "true") {
            return new Ok(new ParentSetOpen(true));
          } else if (value2 === "") {
            return new Ok(new ParentSetOpen(true));
          } else if (value2 === "false") {
            return new Ok(new ParentSetOpen(false));
          } else {
            return new Error(void 0);
          }
        }
      )
    ])
  );
  return make_component(app, name3);
}
function element4(attributes, trigger, content) {
  return element2(
    name3,
    attributes,
    toList([
      div(toList([attribute2("slot", "trigger")]), toList([trigger])),
      div(toList([attribute2("slot", "popover")]), toList([content]))
    ])
  );
}
function echo(value2, file, line) {
  const grey = "\x1B[90m";
  const reset_color = "\x1B[39m";
  const file_line = `${file}:${line}`;
  const string_value = echo$inspect(value2);
  if (globalThis.process?.stderr?.write) {
    const string5 = `${grey}${file_line}${reset_color}
${string_value}
`;
    process.stderr.write(string5);
  } else if (globalThis.Deno) {
    const string5 = `${grey}${file_line}${reset_color}
${string_value}
`;
    globalThis.Deno.stderr.writeSync(new TextEncoder().encode(string5));
  } else {
    const string5 = `${file_line}
${string_value}`;
    globalThis.console.log(string5);
  }
  return value2;
}
function echo$inspectString(str) {
  let new_str = '"';
  for (let i = 0; i < str.length; i++) {
    let char = str[i];
    if (char == "\n")
      new_str += "\\n";
    else if (char == "\r")
      new_str += "\\r";
    else if (char == "	")
      new_str += "\\t";
    else if (char == "\f")
      new_str += "\\f";
    else if (char == "\\")
      new_str += "\\\\";
    else if (char == '"')
      new_str += '\\"';
    else if (char < " " || char > "~" && char < "\xA0") {
      new_str += "\\u{" + char.charCodeAt(0).toString(16).toUpperCase().padStart(4, "0") + "}";
    } else {
      new_str += char;
    }
  }
  new_str += '"';
  return new_str;
}
function echo$inspectDict(map4) {
  let body = "dict.from_list([";
  let first3 = true;
  let key_value_pairs = [];
  map4.forEach((value2, key) => {
    key_value_pairs.push([key, value2]);
  });
  key_value_pairs.sort();
  key_value_pairs.forEach(([key, value2]) => {
    if (!first3)
      body = body + ", ";
    body = body + "#(" + echo$inspect(key) + ", " + echo$inspect(value2) + ")";
    first3 = false;
  });
  return body + "])";
}
function echo$inspectCustomType(record) {
  const props = globalThis.Object.keys(record).map((label) => {
    const value2 = echo$inspect(record[label]);
    return isNaN(parseInt(label)) ? `${label}: ${value2}` : value2;
  }).join(", ");
  return props ? `${record.constructor.name}(${props})` : record.constructor.name;
}
function echo$inspectObject(v) {
  const name6 = Object.getPrototypeOf(v)?.constructor?.name || "Object";
  const props = [];
  for (const k of Object.keys(v)) {
    props.push(`${echo$inspect(k)}: ${echo$inspect(v[k])}`);
  }
  const body = props.length ? " " + props.join(", ") + " " : "";
  const head = name6 === "Object" ? "" : name6 + " ";
  return `//js(${head}{${body}})`;
}
function echo$inspect(v) {
  const t = typeof v;
  if (v === true)
    return "True";
  if (v === false)
    return "False";
  if (v === null)
    return "//js(null)";
  if (v === void 0)
    return "Nil";
  if (t === "string")
    return echo$inspectString(v);
  if (t === "bigint" || t === "number")
    return v.toString();
  if (globalThis.Array.isArray(v))
    return `#(${v.map(echo$inspect).join(", ")})`;
  if (v instanceof List)
    return `[${v.toArray().map(echo$inspect).join(", ")}]`;
  if (v instanceof UtfCodepoint)
    return `//utfcodepoint(${String.fromCodePoint(v.value)})`;
  if (v instanceof BitArray)
    return echo$inspectBitArray(v);
  if (v instanceof CustomType)
    return echo$inspectCustomType(v);
  if (echo$isDict(v))
    return echo$inspectDict(v);
  if (v instanceof Set)
    return `//js(Set(${[...v].map(echo$inspect).join(", ")}))`;
  if (v instanceof RegExp)
    return `//js(${v})`;
  if (v instanceof Date)
    return `//js(Date("${v.toISOString()}"))`;
  if (v instanceof Function) {
    const args = [];
    for (const i of Array(v.length).keys())
      args.push(String.fromCharCode(i + 97));
    return `//fn(${args.join(", ")}) { ... }`;
  }
  return echo$inspectObject(v);
}
function echo$inspectBitArray(bitArray) {
  let endOfAlignedBytes = bitArray.bitOffset + 8 * Math.trunc(bitArray.bitSize / 8);
  let alignedBytes = bitArraySlice(
    bitArray,
    bitArray.bitOffset,
    endOfAlignedBytes
  );
  let remainingUnalignedBits = bitArray.bitSize % 8;
  if (remainingUnalignedBits > 0) {
    let remainingBits = bitArraySliceToInt(
      bitArray,
      endOfAlignedBytes,
      bitArray.bitSize,
      false,
      false
    );
    let alignedBytesArray = Array.from(alignedBytes.rawBuffer);
    let suffix = `${remainingBits}:size(${remainingUnalignedBits})`;
    if (alignedBytesArray.length === 0) {
      return `<<${suffix}>>`;
    } else {
      return `<<${Array.from(alignedBytes.rawBuffer).join(", ")}, ${suffix}>>`;
    }
  } else {
    return `<<${Array.from(alignedBytes.rawBuffer).join(", ")}>>`;
  }
}
function echo$isDict(value2) {
  try {
    return value2 instanceof Dict;
  } catch {
    return false;
  }
}

// build/dev/javascript/lustre/lustre/element/keyed.mjs
function do_extract_keyed_children(loop$key_children_pairs, loop$keyed_children, loop$children, loop$children_count) {
  while (true) {
    let key_children_pairs = loop$key_children_pairs;
    let keyed_children = loop$keyed_children;
    let children = loop$children;
    let children_count = loop$children_count;
    if (key_children_pairs instanceof Empty) {
      return [keyed_children, reverse(children), children_count];
    } else {
      let rest = key_children_pairs.tail;
      let key = key_children_pairs.head[0];
      let element$1 = key_children_pairs.head[1];
      let keyed_element = to_keyed(key, element$1);
      let _block;
      if (key === "") {
        _block = keyed_children;
      } else {
        _block = insert3(keyed_children, key, keyed_element);
      }
      let keyed_children$1 = _block;
      let children$1 = prepend(keyed_element, children);
      let children_count$1 = children_count + advance(keyed_element);
      loop$key_children_pairs = rest;
      loop$keyed_children = keyed_children$1;
      loop$children = children$1;
      loop$children_count = children_count$1;
    }
  }
}
function extract_keyed_children(children) {
  return do_extract_keyed_children(
    children,
    empty2(),
    empty_list,
    0
  );
}
function element5(tag, attributes, children) {
  let $ = extract_keyed_children(children);
  let keyed_children = $[0];
  let children$1 = $[1];
  return element(
    "",
    identity3,
    "",
    tag,
    attributes,
    children$1,
    keyed_children,
    false,
    false
  );
}
function fragment3(children) {
  let $ = extract_keyed_children(children);
  let keyed_children = $[0];
  let children$1 = $[1];
  let children_count = $[2];
  return fragment(
    "",
    identity3,
    children$1,
    keyed_children,
    children_count
  );
}
function ul(attributes, children) {
  return element5("ul", attributes, children);
}

// build/dev/javascript/lustre_ui/lustre/ui/data/bidict.mjs
function new$8() {
  return [new_map(), new_map()];
}
function has(bidict, key) {
  return has_key(bidict[0], key);
}
function get2(bidict, key) {
  return map_get(bidict[0], key);
}
function get_inverse(bidict, key) {
  return map_get(bidict[1], key);
}
function min_inverse(bidict, compare4) {
  let _pipe = map_to_list(bidict[1]);
  let _pipe$1 = sort(_pipe, (a, b) => {
    return compare4(a[0], b[0]);
  });
  let _pipe$2 = first(_pipe$1);
  return map3(_pipe$2, second);
}
function max_inverse(bidict, compare4) {
  let _pipe = map_to_list(bidict[1]);
  let _pipe$1 = sort(_pipe, (a, b) => {
    return compare4(b[0], a[0]);
  });
  let _pipe$2 = first(_pipe$1);
  return map3(_pipe$2, second);
}
function next(bidict, key, increment) {
  let _pipe = get2(bidict, key);
  let _pipe$1 = map3(_pipe, increment);
  return then$2(
    _pipe$1,
    (_capture) => {
      return get_inverse(bidict, _capture);
    }
  );
}
function set(bidict, key, value2) {
  return [
    insert(bidict[0], key, value2),
    insert(bidict[1], value2, key)
  ];
}
function from_list3(entries) {
  return fold2(
    entries,
    new$8(),
    (bidict, entry) => {
      return set(bidict, entry[0], entry[1]);
    }
  );
}
function indexed(values3) {
  return index_fold(
    values3,
    new$8(),
    (bidict, value2, index4) => {
      return set(bidict, value2, index4);
    }
  );
}

// build/dev/javascript/lustre/lustre/element/svg.mjs
var namespace = "http://www.w3.org/2000/svg";
function path(attrs) {
  return namespaced(namespace, "path", attrs, empty_list);
}

// build/dev/javascript/lustre_ui/lustre/ui/primitives/icon.mjs
function icon(attrs, path2) {
  return svg(
    prepend(
      attribute2("viewBox", "0 0 15 15"),
      prepend(
        attribute2("fill", "none"),
        prepend(class$("lustre-ui-icon"), attrs)
      )
    ),
    toList([
      path(
        toList([
          attribute2("d", path2),
          attribute2("fill", "currentColor"),
          attribute2("fill-rule", "evenodd"),
          attribute2("clip-rule", "evenodd")
        ])
      )
    ])
  );
}
function chevron_down(attrs) {
  return icon(
    attrs,
    "M3.13523 6.15803C3.3241 5.95657 3.64052 5.94637 3.84197 6.13523L7.5 9.56464L11.158 6.13523C11.3595 5.94637 11.6759 5.95657 11.8648 6.15803C12.0536 6.35949 12.0434 6.67591 11.842 6.86477L7.84197 10.6148C7.64964 10.7951 7.35036 10.7951 7.15803 10.6148L3.15803 6.86477C2.95657 6.67591 2.94637 6.35949 3.13523 6.15803Z"
  );
}
function check(attrs) {
  return icon(
    attrs,
    "M11.4669 3.72684C11.7558 3.91574 11.8369 4.30308 11.648 4.59198L7.39799 11.092C7.29783 11.2452 7.13556 11.3467 6.95402 11.3699C6.77247 11.3931 6.58989 11.3355 6.45446 11.2124L3.70446 8.71241C3.44905 8.48022 3.43023 8.08494 3.66242 7.82953C3.89461 7.57412 4.28989 7.55529 4.5453 7.78749L6.75292 9.79441L10.6018 3.90792C10.7907 3.61902 11.178 3.53795 11.4669 3.72684Z"
  );
}
function magnifying_glass(attrs) {
  return icon(
    attrs,
    "M10 6.5C10 8.433 8.433 10 6.5 10C4.567 10 3 8.433 3 6.5C3 4.567 4.567 3 6.5 3C8.433 3 10 4.567 10 6.5ZM9.30884 10.0159C8.53901 10.6318 7.56251 11 6.5 11C4.01472 11 2 8.98528 2 6.5C2 4.01472 4.01472 2 6.5 2C8.98528 2 11 4.01472 11 6.5C11 7.56251 10.6318 8.53901 10.0159 9.30884L12.8536 12.1464C13.0488 12.3417 13.0488 12.6583 12.8536 12.8536C12.6583 13.0488 12.3417 13.0488 12.1464 12.8536L9.30884 10.0159Z"
  );
}

// build/dev/javascript/lustre_ui/lustre/ui/accordion.mjs
var Model2 = class extends CustomType {
  constructor(options, expanded2, mode) {
    super();
    this.options = options;
    this.expanded = expanded2;
    this.mode = mode;
  }
};
var AtMostOne = class extends CustomType {
};
var ExactlyOne = class extends CustomType {
};
var Multi = class extends CustomType {
};
var Options = class extends CustomType {
  constructor(all, lookup_label, lookup_index) {
    super();
    this.all = all;
    this.lookup_label = lookup_label;
    this.lookup_index = lookup_index;
  }
};
var ParentChangedChildren = class extends CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
};
var ParentSetMode = class extends CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
};
var UserPressedDown = class extends CustomType {
  constructor($0, event4) {
    super();
    this[0] = $0;
    this.event = event4;
  }
};
var UserPressedEnd = class extends CustomType {
};
var UserPressedHome = class extends CustomType {
};
var UserPressedUp = class extends CustomType {
  constructor($0, event4) {
    super();
    this[0] = $0;
    this.event = event4;
  }
};
var UserToggledItem = class extends CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
};
function init3(_) {
  let options = new Options(toList([]), new$8(), new$8());
  let model = new Model2(options, new$(), new AtMostOne());
  let effect = none();
  return [model, effect];
}
function focus_trigger(key) {
  let selector = "[data-lustre-key=" + key + "] [part=accordion-trigger]";
  return focus2(selector);
}
function update4(model, msg) {
  if (msg instanceof ParentChangedChildren) {
    let all = msg[0];
    let lookup_label = from_list3(all);
    let lookup_index = indexed(map(all, first2));
    let options = new Options(all, lookup_label, lookup_index);
    let expanded2 = filter3(
      model.expanded,
      (_capture) => {
        return has(lookup_label, _capture);
      }
    );
    let keys2 = map(all, first2);
    let _block;
    let $ = model.mode;
    let $1 = size(expanded2);
    if ($ instanceof AtMostOne) {
      if ($1 === 0) {
        _block = expanded2;
      } else if ($1 === 1) {
        _block = expanded2;
      } else {
        let _pipe = find2(
          keys2,
          (_capture) => {
            return contains(expanded2, _capture);
          }
        );
        let _pipe$1 = map3(
          _pipe,
          (key) => {
            return from_list2(toList([key]));
          }
        );
        _block = unwrap(_pipe$1, new$());
      }
    } else if ($ instanceof ExactlyOne) {
      if ($1 === 0) {
        let _pipe = first(keys2);
        let _pipe$1 = map3(
          _pipe,
          (key) => {
            return from_list2(toList([key]));
          }
        );
        _block = unwrap(_pipe$1, new$());
      } else if ($1 === 1) {
        _block = expanded2;
      } else {
        let _pipe = find2(
          keys2,
          (_capture) => {
            return contains(expanded2, _capture);
          }
        );
        let _pipe$1 = map3(
          _pipe,
          (key) => {
            return from_list2(toList([key]));
          }
        );
        _block = unwrap(_pipe$1, new$());
      }
    } else {
      _block = expanded2;
    }
    let expanded$1 = _block;
    let _block$1;
    let _record = model;
    _block$1 = new Model2(options, expanded$1, _record.mode);
    let model$1 = _block$1;
    let effect = none();
    return [model$1, effect];
  } else if (msg instanceof ParentSetMode) {
    let mode = msg[0];
    let keys2 = map(model.options.all, first2);
    let _block;
    let $ = size(model.expanded);
    if (mode instanceof AtMostOne) {
      if ($ === 0) {
        _block = model.expanded;
      } else if ($ === 1) {
        _block = model.expanded;
      } else {
        let _pipe = find2(
          keys2,
          (_capture) => {
            return contains(model.expanded, _capture);
          }
        );
        let _pipe$1 = map3(
          _pipe,
          (key) => {
            return from_list2(toList([key]));
          }
        );
        _block = unwrap(_pipe$1, new$());
      }
    } else if (mode instanceof ExactlyOne) {
      if ($ === 0) {
        let _pipe = first(keys2);
        let _pipe$1 = map3(
          _pipe,
          (key) => {
            return from_list2(toList([key]));
          }
        );
        _block = unwrap(_pipe$1, new$());
      } else if ($ === 1) {
        _block = model.expanded;
      } else {
        let _pipe = find2(
          keys2,
          (_capture) => {
            return contains(model.expanded, _capture);
          }
        );
        let _pipe$1 = map3(
          _pipe,
          (key) => {
            return from_list2(toList([key]));
          }
        );
        _block = unwrap(_pipe$1, new$());
      }
    } else {
      _block = model.expanded;
    }
    let expanded2 = _block;
    let _block$1;
    let _record = model;
    _block$1 = new Model2(_record.options, expanded2, mode);
    let model$1 = _block$1;
    let effect = none();
    return [model$1, effect];
  } else if (msg instanceof UserPressedDown) {
    let key = msg[0];
    let event4 = msg.event;
    let effect = try$(
      get2(model.options.lookup_index, key),
      (index4) => {
        return map3(
          get_inverse(model.options.lookup_index, index4 + 1),
          (next2) => {
            return focus_trigger(next2);
          }
        );
      }
    );
    return [
      model,
      batch(
        toList([
          (() => {
            let _pipe = effect;
            return unwrap(_pipe, none());
          })(),
          prevent_default2(event4)
        ])
      )
    ];
  } else if (msg instanceof UserPressedEnd) {
    let effect = map3(
      max_inverse(model.options.lookup_index, compare2),
      (last) => {
        return focus_trigger(last);
      }
    );
    return [
      model,
      (() => {
        let _pipe = effect;
        return unwrap(_pipe, none());
      })()
    ];
  } else if (msg instanceof UserPressedHome) {
    let effect = map3(
      min_inverse(model.options.lookup_index, compare2),
      (first3) => {
        return focus_trigger(first3);
      }
    );
    return [
      model,
      (() => {
        let _pipe = effect;
        return unwrap(_pipe, none());
      })()
    ];
  } else if (msg instanceof UserPressedUp) {
    let key = msg[0];
    let event4 = msg.event;
    let effect = try$(
      get2(model.options.lookup_index, key),
      (index4) => {
        return map3(
          get_inverse(model.options.lookup_index, index4 - 1),
          (prev) => {
            return focus_trigger(prev);
          }
        );
      }
    );
    return [
      model,
      batch(
        toList([
          (() => {
            let _pipe = effect;
            return unwrap(_pipe, none());
          })(),
          prevent_default2(event4)
        ])
      )
    ];
  } else {
    let value2 = msg[0];
    let _block;
    let $ = contains(model.expanded, value2);
    let $1 = model.mode;
    if ($1 instanceof AtMostOne) {
      if ($) {
        _block = new$();
      } else {
        _block = from_list2(toList([value2]));
      }
    } else if ($1 instanceof ExactlyOne) {
      if ($) {
        _block = model.expanded;
      } else {
        _block = from_list2(toList([value2]));
      }
    } else if ($) {
      _block = delete$2(model.expanded, value2);
    } else {
      _block = insert2(model.expanded, value2);
    }
    let expanded2 = _block;
    let _block$1;
    let _record = model;
    _block$1 = new Model2(_record.options, expanded2, _record.mode);
    let model$1 = _block$1;
    let _block$2;
    let $2 = contains(expanded2, value2);
    if ($2) {
      _block$2 = emit("expand", string3(value2));
    } else {
      _block$2 = emit("collapse", string3(value2));
    }
    let effect = _block$2;
    return [model$1, effect];
  }
}
function handle_slot_change2() {
  return field(
    "target",
    assigned_elements2(
      field(
        "tagName",
        string2,
        (tag) => {
          return then$(
            attribute4("value"),
            (value2) => {
              return field(
                "textContent",
                string2,
                (label) => {
                  return success([tag, value2, label]);
                }
              );
            }
          );
        }
      ),
      true
    ),
    (options) => {
      let _pipe = options;
      let _pipe$1 = fold_right(
        _pipe,
        [toList([]), new$()],
        (acc, option) => {
          let tag = option[0];
          let value2 = option[1];
          let label = option[2];
          return guard(
            tag !== "LUSTRE-UI-ACCORDION-ITEM",
            acc,
            () => {
              return guard(
                contains(acc[1], value2),
                acc,
                () => {
                  let seen = insert2(acc[1], value2);
                  let options$1 = prepend([value2, label], acc[0]);
                  return [options$1, seen];
                }
              );
            }
          );
        }
      );
      let _pipe$2 = first2(_pipe$1);
      let _pipe$3 = new ParentChangedChildren(_pipe$2);
      return success(_pipe$3);
    }
  );
}
function handle_keydown3(id) {
  return then$(
    dynamic,
    (event4) => {
      return field(
        "key",
        string2,
        (key) => {
          if (key === "ArrowDown") {
            return success(new UserPressedDown(id, event4));
          } else if (key === "ArrowUp") {
            return success(new UserPressedUp(id, event4));
          } else if (key === "End") {
            return success(new UserPressedEnd());
          } else if (key === "Home") {
            return success(new UserPressedHome());
          } else {
            return failure(new UserPressedHome(), "");
          }
        }
      );
    }
  );
}
var name4 = "lustre-ui-accordion";
function view3(model) {
  return fragment2(
    toList([
      slot(
        toList([
          style("display", "none"),
          on("slotchange", handle_slot_change2())
        ]),
        toList([])
      ),
      fragment3(
        map(
          model.options.all,
          (_use0) => {
            let key = _use0[0];
            let label = _use0[1];
            let is_expanded = contains(model.expanded, key);
            let item$1 = element3(
              toList([
                expanded(is_expanded),
                on_change((_) => {
                  return new UserToggledItem(key);
                })
              ]),
              button(
                toList([
                  attribute2("part", "accordion-trigger"),
                  attribute2("tabindex", "0"),
                  on("keydown", handle_keydown3(key))
                ]),
                toList([
                  p(
                    toList([attribute2("part", "accordion-trigger-label")]),
                    toList([text3(label)])
                  ),
                  chevron_down(
                    toList([
                      attribute2(
                        "part",
                        (() => {
                          if (is_expanded) {
                            return "accordion-trigger-icon expanded";
                          } else {
                            return "accordion-trigger-icon";
                          }
                        })()
                      )
                    ])
                  )
                ])
              ),
              slot(
                toList([
                  attribute2("part", "accordion-content"),
                  name(key)
                ]),
                toList([])
              )
            );
            return [key, item$1];
          }
        )
      )
    ])
  );
}
function register3() {
  let $ = register();
  if ($ instanceof Ok) {
    let app = component(
      init3,
      update4,
      view3,
      toList([
        on_attribute_change(
          "mode",
          (value2) => {
            if (value2 === "at-most-one") {
              return new Ok(new ParentSetMode(new AtMostOne()));
            } else if (value2 === "exactly-one") {
              return new Ok(new ParentSetMode(new ExactlyOne()));
            } else if (value2 === "multi") {
              return new Ok(new ParentSetMode(new Multi()));
            } else {
              return new Error(void 0);
            }
          }
        )
      ])
    );
    return make_component(app, name4);
  } else {
    let $1 = $[0];
    if ($1 instanceof ComponentAlreadyRegistered) {
      let app = component(
        init3,
        update4,
        view3,
        toList([
          on_attribute_change(
            "mode",
            (value2) => {
              if (value2 === "at-most-one") {
                return new Ok(new ParentSetMode(new AtMostOne()));
              } else if (value2 === "exactly-one") {
                return new Ok(new ParentSetMode(new ExactlyOne()));
              } else if (value2 === "multi") {
                return new Ok(new ParentSetMode(new Multi()));
              } else {
                return new Error(void 0);
              }
            }
          )
        ])
      );
      return make_component(app, name4);
    } else {
      let error = $;
      return error;
    }
  }
}

// build/dev/javascript/lustre_ui/lustre/ui/input.mjs
function element6(attributes) {
  return input(
    prepend(class$("lustre-ui-input"), attributes)
  );
}
function container(attributes, children) {
  return div(
    prepend(class$("lustre-ui-input-container"), attributes),
    children
  );
}

// build/dev/javascript/lustre_ui/lustre/ui/combobox.mjs
var FILEPATH = "src/lustre/ui/combobox.gleam";
var Item = class extends CustomType {
  constructor(value2, label, content) {
    super();
    this.value = value2;
    this.label = label;
    this.content = content;
  }
};
var Model3 = class extends CustomType {
  constructor(expanded2, value2, placeholder, query, intent, intent_strategy, options) {
    super();
    this.expanded = expanded2;
    this.value = value2;
    this.placeholder = placeholder;
    this.query = query;
    this.intent = intent;
    this.intent_strategy = intent_strategy;
    this.options = options;
  }
};
var ByIndex = class extends CustomType {
};
var ByLength = class extends CustomType {
};
var Options2 = class extends CustomType {
  constructor(all, filtered, lookup_label, lookup_index) {
    super();
    this.all = all;
    this.filtered = filtered;
    this.lookup_label = lookup_label;
    this.lookup_index = lookup_index;
  }
};
var DomBlurredTrigger = class extends CustomType {
};
var DomFocusedTrigger = class extends CustomType {
};
var ParentChangedChildren2 = class extends CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
};
var ParentSetPlaceholder = class extends CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
};
var ParentSetStrategy = class extends CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
};
var ParentSetValue = class extends CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
};
var UserActivatedPopoverTrigger = class extends CustomType {
  constructor(input2) {
    super();
    this.input = input2;
  }
};
var UserChangedQuery = class extends CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
};
var UserClosedMenu = class extends CustomType {
};
var UserHoveredOption = class extends CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
};
var UserOpenedMenu = class extends CustomType {
};
var UserPressedDown2 = class extends CustomType {
  constructor(event4) {
    super();
    this.event = event4;
  }
};
var UserPressedEnd2 = class extends CustomType {
  constructor(event4) {
    super();
    this.event = event4;
  }
};
var UserPressedEnter = class extends CustomType {
  constructor(event4) {
    super();
    this.event = event4;
  }
};
var UserPressedEscape = class extends CustomType {
  constructor(event4, trigger) {
    super();
    this.event = event4;
    this.trigger = trigger;
  }
};
var UserPressedHome2 = class extends CustomType {
  constructor(event4) {
    super();
    this.event = event4;
  }
};
var UserPressedUp2 = class extends CustomType {
  constructor(event4) {
    super();
    this.event = event4;
  }
};
var UserSelectedOption = class extends CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
};
function init4(_) {
  let model = new Model3(
    false,
    "",
    "Select an option...",
    "",
    new None(),
    new ByIndex(),
    new Options2(toList([]), toList([]), new$8(), new$8())
  );
  let effect = batch(toList([set_pseudo_state2("empty")]));
  return [model, effect];
}
function contains_query(option, query) {
  let _pipe = option.label;
  let _pipe$1 = lowercase(_pipe);
  return contains_string(_pipe$1, query);
}
function intent_from_query(query, strategy, options) {
  return guard(
    query === "",
    new None(),
    () => {
      let query$1 = lowercase(query);
      let compare_options = (a, b) => {
        let a_label = lowercase(a.label);
        let b_label = lowercase(b.label);
        let a_starts = starts_with(a_label, query$1);
        let b_starts = starts_with(b_label, query$1);
        let $ = get2(options.lookup_index, a.value);
        if (!($ instanceof Ok)) {
          throw makeError(
            "let_assert",
            FILEPATH,
            "lustre/ui/combobox",
            513,
            "intent_from_query",
            "Pattern match failed, no pattern matched the value.",
            {
              value: $,
              start: 14126,
              end: 14192,
              pattern_start: 14137,
              pattern_end: 14148
            }
          );
        }
        let a_index = $[0];
        let $1 = get2(options.lookup_index, b.value);
        if (!($1 instanceof Ok)) {
          throw makeError(
            "let_assert",
            FILEPATH,
            "lustre/ui/combobox",
            514,
            "intent_from_query",
            "Pattern match failed, no pattern matched the value.",
            {
              value: $1,
              start: 14197,
              end: 14263,
              pattern_start: 14208,
              pattern_end: 14219
            }
          );
        }
        let b_index = $1[0];
        if (b_starts) {
          if (!a_starts) {
            return new Gt();
          } else if (strategy instanceof ByIndex) {
            return compare2(a_index, b_index);
          } else {
            return compare2(
              string_length(a_label),
              string_length(b_label)
            );
          }
        } else if (a_starts) {
          return new Lt();
        } else if (strategy instanceof ByIndex) {
          return compare2(a_index, b_index);
        } else {
          return compare2(string_length(a_label), string_length(b_label));
        }
      };
      let _pipe = options.all;
      let _pipe$1 = filter2(
        _pipe,
        (_capture) => {
          return contains_query(_capture, query$1);
        }
      );
      let _pipe$2 = sort(_pipe$1, compare_options);
      let _pipe$3 = first(_pipe$2);
      let _pipe$4 = map3(_pipe$3, (option) => {
        return option.value;
      });
      return from_result(_pipe$4);
    }
  );
}
function update5(model, msg) {
  let $ = echo2(msg, "src/lustre/ui/combobox.gleam", 316);
  if ($ instanceof DomBlurredTrigger) {
    return [model, remove_pseudo_state2("trigger-focus")];
  } else if ($ instanceof DomFocusedTrigger) {
    return [model, set_pseudo_state2("trigger-focus")];
  } else if ($ instanceof ParentChangedChildren2) {
    let all = $[0];
    let lookup_label = from_list3(
      map(all, (item) => {
        return [item.value, item.label];
      })
    );
    let lookup_index = indexed(
      map(all, (item) => {
        return item.value;
      })
    );
    let filtered = filter2(
      all,
      (option) => {
        let _pipe = lowercase(option.label);
        return contains_string(_pipe, lowercase(model.query));
      }
    );
    let options = new Options2(all, filtered, lookup_label, lookup_index);
    let intent = new None();
    let _block;
    let _record = model;
    _block = new Model3(
      _record.expanded,
      _record.value,
      _record.placeholder,
      _record.query,
      intent,
      _record.intent_strategy,
      options
    );
    let model$1 = _block;
    let effect = none();
    return [model$1, effect];
  } else if ($ instanceof ParentSetPlaceholder) {
    let placeholder$1 = $[0];
    return [
      (() => {
        let _record = model;
        return new Model3(
          _record.expanded,
          _record.value,
          placeholder$1,
          _record.query,
          _record.intent,
          _record.intent_strategy,
          _record.options
        );
      })(),
      none()
    ];
  } else if ($ instanceof ParentSetStrategy) {
    let strategy = $[0];
    return [
      (() => {
        let _record = model;
        return new Model3(
          _record.expanded,
          _record.value,
          _record.placeholder,
          _record.query,
          _record.intent,
          strategy,
          _record.options
        );
      })(),
      none()
    ];
  } else if ($ instanceof ParentSetValue) {
    let value$1 = $[0];
    let _block;
    let _record = model;
    _block = new Model3(
      _record.expanded,
      value$1,
      _record.placeholder,
      _record.query,
      new Some(value$1),
      _record.intent_strategy,
      _record.options
    );
    let model$1 = _block;
    let _block$1;
    if (value$1 === "") {
      _block$1 = set_pseudo_state2("empty");
    } else {
      _block$1 = remove_pseudo_state2("empty");
    }
    let effect = _block$1;
    return [model$1, effect];
  } else if ($ instanceof UserActivatedPopoverTrigger) {
    let input2 = $.input;
    let effect = after_paint(
      (_, _1) => {
        return focus(input2);
      }
    );
    return [model, effect];
  } else if ($ instanceof UserChangedQuery) {
    let query = $[0];
    let filtered = filter2(
      model.options.all,
      (option) => {
        let _pipe = lowercase(option.label);
        return contains_string(_pipe, lowercase(query));
      }
    );
    let _block;
    let _record = model.options;
    _block = new Options2(
      _record.all,
      filtered,
      _record.lookup_label,
      _record.lookup_index
    );
    let options = _block;
    let intent = intent_from_query(query, model.intent_strategy, model.options);
    let _block$1;
    let _record$1 = model;
    _block$1 = new Model3(
      _record$1.expanded,
      _record$1.value,
      _record$1.placeholder,
      query,
      intent,
      _record$1.intent_strategy,
      options
    );
    let model$1 = _block$1;
    let effect = none();
    return [model$1, effect];
  } else if ($ instanceof UserClosedMenu) {
    let _block;
    let _record = model;
    _block = new Model3(
      false,
      _record.value,
      _record.placeholder,
      _record.query,
      new None(),
      _record.intent_strategy,
      _record.options
    );
    let model$1 = _block;
    let effect = remove_pseudo_state2("expanded");
    return [model$1, effect];
  } else if ($ instanceof UserHoveredOption) {
    let intent = $[0];
    return [
      (() => {
        let _record = model;
        return new Model3(
          _record.expanded,
          _record.value,
          _record.placeholder,
          _record.query,
          new Some(intent),
          _record.intent_strategy,
          _record.options
        );
      })(),
      none()
    ];
  } else if ($ instanceof UserOpenedMenu) {
    let _block;
    let _record = model;
    _block = new Model3(
      true,
      _record.value,
      _record.placeholder,
      _record.query,
      _record.intent,
      _record.intent_strategy,
      _record.options
    );
    let model$1 = _block;
    let effect = set_pseudo_state2("expanded");
    return [model$1, effect];
  } else if ($ instanceof UserPressedDown2) {
    let event4 = $.event;
    let _block;
    let $1 = model.intent;
    if ($1 instanceof Some) {
      let intent2 = $1[0];
      let _pipe = next(
        model.options.lookup_index,
        intent2,
        (_capture) => {
          return add(_capture, 1);
        }
      );
      let _pipe$1 = or(_pipe, new Ok(intent2));
      _block = from_result(_pipe$1);
    } else {
      let _pipe = min_inverse(model.options.lookup_index, compare2);
      _block = from_result(_pipe);
    }
    let intent = _block;
    let _block$1;
    let _record = model;
    _block$1 = new Model3(
      _record.expanded,
      _record.value,
      _record.placeholder,
      _record.query,
      intent,
      _record.intent_strategy,
      _record.options
    );
    let model$1 = _block$1;
    let effect = prevent_default2(event4);
    return [model$1, effect];
  } else if ($ instanceof UserPressedEnd2) {
    let event4 = $.event;
    let _block;
    let _pipe = model.options.lookup_index;
    let _pipe$1 = max_inverse(_pipe, compare2);
    _block = from_result(_pipe$1);
    let intent = _block;
    let _block$1;
    let _record = model;
    _block$1 = new Model3(
      _record.expanded,
      _record.value,
      _record.placeholder,
      _record.query,
      intent,
      _record.intent_strategy,
      _record.options
    );
    let model$1 = _block$1;
    let effect = prevent_default2(event4);
    return [model$1, effect];
  } else if ($ instanceof UserPressedEnter) {
    let event4 = $.event;
    let _block;
    let $1 = model.intent;
    if ($1 instanceof Some) {
      let value$1 = $1[0];
      _block = batch(
        toList([
          emit(
            "change",
            object2(toList([["value", string3(value$1)]]))
          ),
          prevent_default2(event4)
        ])
      );
    } else {
      _block = prevent_default2(event4);
    }
    let effect = _block;
    return [model, effect];
  } else if ($ instanceof UserPressedEscape) {
    let event4 = $.event;
    let trigger = $.trigger;
    let _block;
    let _record = model;
    _block = new Model3(
      false,
      _record.value,
      _record.placeholder,
      _record.query,
      new None(),
      _record.intent_strategy,
      _record.options
    );
    let model$1 = _block;
    let effect = batch(
      toList([
        remove_pseudo_state2("expanded"),
        prevent_default2(event4),
        after_paint((_, _1) => {
          return focus(trigger);
        })
      ])
    );
    return [model$1, effect];
  } else if ($ instanceof UserPressedHome2) {
    let event4 = $.event;
    let _block;
    let _pipe = model.options.lookup_index;
    let _pipe$1 = min_inverse(_pipe, compare2);
    _block = from_result(_pipe$1);
    let intent = _block;
    let _block$1;
    let _record = model;
    _block$1 = new Model3(
      _record.expanded,
      _record.value,
      _record.placeholder,
      _record.query,
      intent,
      _record.intent_strategy,
      _record.options
    );
    let model$1 = _block$1;
    let effect = prevent_default2(event4);
    return [model$1, effect];
  } else if ($ instanceof UserPressedUp2) {
    let event4 = $.event;
    let _block;
    let $1 = model.intent;
    if ($1 instanceof Some) {
      let intent2 = $1[0];
      let _pipe = next(
        model.options.lookup_index,
        intent2,
        (_capture) => {
          return subtract(_capture, 1);
        }
      );
      let _pipe$1 = or(_pipe, new Ok(intent2));
      _block = from_result(_pipe$1);
    } else {
      let _pipe = max_inverse(model.options.lookup_index, compare2);
      _block = from_result(_pipe);
    }
    let intent = _block;
    let _block$1;
    let _record = model;
    _block$1 = new Model3(
      _record.expanded,
      _record.value,
      _record.placeholder,
      _record.query,
      intent,
      _record.intent_strategy,
      _record.options
    );
    let model$1 = _block$1;
    let effect = prevent_default2(event4);
    return [model$1, effect];
  } else {
    let value$1 = $[0];
    let _block;
    let _pipe = value$1;
    let _pipe$1 = ((_capture) => {
      return get2(model.options.lookup_label, _capture);
    })(_pipe);
    _block = from_result(_pipe$1);
    let intent = _block;
    let _block$1;
    let _record = model;
    _block$1 = new Model3(
      _record.expanded,
      _record.value,
      _record.placeholder,
      _record.query,
      intent,
      _record.intent_strategy,
      _record.options
    );
    let model$1 = _block$1;
    let effect = emit(
      "change",
      object2(toList([["value", string3(value$1)]]))
    );
    return [model$1, effect];
  }
}
function handle_slot_change3() {
  return field(
    "target",
    assigned_elements2(
      field(
        "tagName",
        string2,
        (tag) => {
          return then$(
            attribute4("value"),
            (value2) => {
              return field(
                "textContent",
                string2,
                (label) => {
                  return success([tag, value2, label]);
                }
              );
            }
          );
        }
      ),
      true
    ),
    (options) => {
      let _pipe = options;
      let _pipe$1 = fold_right(
        _pipe,
        [toList([]), new$()],
        (acc, option) => {
          let tag = option[0];
          let value$1 = option[1];
          let label = option[2];
          return guard(
            tag !== "LUSTRE-UI-COMBOBOX-OPTION",
            acc,
            () => {
              return guard(
                contains(acc[1], value$1),
                acc,
                () => {
                  let seen = insert2(acc[1], value$1);
                  let options$1 = prepend(
                    new Item(value$1, label, toList([])),
                    acc[0]
                  );
                  return [options$1, seen];
                }
              );
            }
          );
        }
      );
      let _pipe$2 = first2(_pipe$1);
      let _pipe$3 = new ParentChangedChildren2(_pipe$2);
      return success(_pipe$3);
    }
  );
}
function handle_popover_click(will_open) {
  return field(
    "currentTarget",
    child("input", nil(), dynamic),
    (input2) => {
      if (will_open) {
        return success(new UserActivatedPopoverTrigger(input2));
      } else {
        return failure(new UserActivatedPopoverTrigger(input2), "");
      }
    }
  );
}
function handle_popover_keydown(will_open) {
  return field(
    "key",
    string2,
    (key) => {
      return field(
        "currentTarget",
        child("input", nil(), dynamic),
        (input2) => {
          if (key === "Enter") {
            if (will_open) {
              return success(new UserActivatedPopoverTrigger(input2));
            } else {
              return failure(new UserActivatedPopoverTrigger(input2), "");
            }
          } else if (key === " ") {
            if (will_open) {
              return success(new UserActivatedPopoverTrigger(input2));
            } else {
              return failure(new UserActivatedPopoverTrigger(input2), "");
            }
          } else {
            return failure(new UserActivatedPopoverTrigger(input2), "");
          }
        }
      );
    }
  );
}
function view_trigger3(value2, placeholder, options) {
  let _block;
  let _pipe = value2;
  let _pipe$1 = ((_capture) => {
    return get2(options.lookup_label, _capture);
  })(_pipe);
  _block = unwrap(_pipe$1, placeholder);
  let label = _block;
  return button(
    toList([
      attribute2("part", "combobox-trigger"),
      attribute2("tabindex", "0"),
      on_focus(new DomFocusedTrigger()),
      on_blur(new DomBlurredTrigger())
    ]),
    toList([
      span(
        toList([
          attribute2("part", "combobox-trigger-label"),
          class$(
            (() => {
              if (label === "") {
                return "empty";
              } else {
                return "";
              }
            })()
          )
        ]),
        toList([text3(label)])
      ),
      chevron_down(toList([attribute2("part", "combobox-trigger-icon")]))
    ])
  );
}
function handle_input_keydown() {
  return then$(
    dynamic,
    (event4) => {
      return field(
        "key",
        string2,
        (key) => {
          if (key === "ArrowDown") {
            return success(new UserPressedDown2(event4));
          } else if (key === "ArrowEnd") {
            return success(new UserPressedEnd2(event4));
          } else if (key === "Enter") {
            return success(new UserPressedEnter(event4));
          } else if (key === "Escape") {
            return field(
              "target",
              child("button", nil(), dynamic),
              (trigger) => {
                return success(new UserPressedEscape(event4, trigger));
              }
            );
          } else if (key === "Home") {
            return success(new UserPressedHome2(event4));
          } else if (key === "ArrowUp") {
            return success(new UserPressedUp2(event4));
          } else if (key === "Tab") {
            return success(new UserClosedMenu());
          } else {
            return failure(new UserClosedMenu(), "");
          }
        }
      );
    }
  );
}
function view_input(query) {
  return container(
    toList([attribute2("part", "combobox-input")]),
    toList([
      magnifying_glass(toList([])),
      element6(
        toList([
          styles(
            toList([
              ["width", "100%"],
              ["border-bottom-left-radius", "0px"],
              ["border-bottom-right-radius", "0px"]
            ])
          ),
          autocomplete("off"),
          on_input((var0) => {
            return new UserChangedQuery(var0);
          }),
          on("keydown", handle_input_keydown()),
          value(query)
        ])
      )
    ])
  );
}
var name5 = "lustre-ui-combobox";
function view_option(option, value2, intent, last) {
  let is_selected = option.value === value2;
  let is_intent = isEqual(new Some(option.value), intent);
  let _block;
  if (is_selected) {
    _block = check;
  } else {
    _block = (_capture) => {
      return span(_capture, toList([]));
    };
  }
  let icon2 = _block;
  let parts = toList([
    "combobox-option",
    (() => {
      if (is_intent) {
        return "intent";
      } else {
        return "";
      }
    })(),
    (() => {
      if (last) {
        return "last";
      } else {
        return "";
      }
    })()
  ]);
  return li(
    toList([
      attribute2("part", join(parts, " ")),
      attribute2("value", option.value),
      on_mouse_over(new UserHoveredOption(option.value)),
      on_mouse_down(new UserSelectedOption(option.value))
    ]),
    toList([
      icon2(
        toList([
          styles(toList([["height", "1rem"], ["width", "1rem"]]))
        ])
      ),
      span(
        toList([style("flex", "1 1 0%")]),
        toList([
          element2(
            "slot",
            toList([name("option-" + option.value)]),
            toList([text3(option.label)])
          )
        ])
      )
    ])
  );
}
function do_view_options(options, value2, intent) {
  if (options instanceof Empty) {
    return toList([]);
  } else {
    let $ = options.tail;
    if ($ instanceof Empty) {
      let option$1 = options.head;
      return toList([
        [option$1.value, view_option(option$1, value2, intent, true)]
      ]);
    } else {
      let option$1 = options.head;
      let rest = $;
      return prepend(
        [option$1.label, view_option(option$1, value2, intent, false)],
        do_view_options(rest, value2, intent)
      );
    }
  }
}
function view_options(options, value2, intent) {
  return ul(toList([]), do_view_options(options.filtered, value2, intent));
}
function view4(model) {
  return fragment2(
    toList([
      slot(
        toList([
          style("display", "none"),
          on("slotchange", handle_slot_change3())
        ]),
        toList([])
      ),
      element4(
        toList([
          anchor(new BottomMiddle()),
          equal_width(),
          gap("var(--padding-y)"),
          on_close(new UserClosedMenu()),
          on_open(new UserOpenedMenu()),
          open(model.expanded),
          on("click", handle_popover_click(!model.expanded)),
          on("keydown", handle_popover_keydown(!model.expanded))
        ]),
        view_trigger3(model.value, model.placeholder, model.options),
        div(
          toList([attribute2("part", "combobox-options")]),
          toList([
            view_input(model.query),
            view_options(model.options, model.value, model.intent)
          ])
        )
      )
    ])
  );
}
function register4() {
  let $ = register2();
  if ($ instanceof Ok) {
    let app = component(
      init4,
      update5,
      view4,
      toList([
        adopt_styles(false),
        on_attribute_change(
          "value",
          (value2) => {
            return new Ok(new ParentSetValue(value2));
          }
        ),
        on_attribute_change(
          "placeholder",
          (value2) => {
            return new Ok(new ParentSetPlaceholder(value2));
          }
        ),
        on_attribute_change(
          "strategy",
          (value2) => {
            if (value2 === "by-length") {
              return new Ok(new ParentSetStrategy(new ByLength()));
            } else if (value2 === "by-index") {
              return new Ok(new ParentSetStrategy(new ByIndex()));
            } else {
              return new Error(void 0);
            }
          }
        )
      ])
    );
    return make_component(app, name5);
  } else {
    let $1 = $[0];
    if ($1 instanceof ComponentAlreadyRegistered) {
      let app = component(
        init4,
        update5,
        view4,
        toList([
          adopt_styles(false),
          on_attribute_change(
            "value",
            (value2) => {
              return new Ok(new ParentSetValue(value2));
            }
          ),
          on_attribute_change(
            "placeholder",
            (value2) => {
              return new Ok(new ParentSetPlaceholder(value2));
            }
          ),
          on_attribute_change(
            "strategy",
            (value2) => {
              if (value2 === "by-length") {
                return new Ok(new ParentSetStrategy(new ByLength()));
              } else if (value2 === "by-index") {
                return new Ok(new ParentSetStrategy(new ByIndex()));
              } else {
                return new Error(void 0);
              }
            }
          )
        ])
      );
      return make_component(app, name5);
    } else {
      let error = $;
      return error;
    }
  }
}
function echo2(value2, file, line) {
  const grey = "\x1B[90m";
  const reset_color = "\x1B[39m";
  const file_line = `${file}:${line}`;
  const string_value = echo$inspect2(value2);
  if (globalThis.process?.stderr?.write) {
    const string5 = `${grey}${file_line}${reset_color}
${string_value}
`;
    process.stderr.write(string5);
  } else if (globalThis.Deno) {
    const string5 = `${grey}${file_line}${reset_color}
${string_value}
`;
    globalThis.Deno.stderr.writeSync(new TextEncoder().encode(string5));
  } else {
    const string5 = `${file_line}
${string_value}`;
    globalThis.console.log(string5);
  }
  return value2;
}
function echo$inspectString2(str) {
  let new_str = '"';
  for (let i = 0; i < str.length; i++) {
    let char = str[i];
    if (char == "\n")
      new_str += "\\n";
    else if (char == "\r")
      new_str += "\\r";
    else if (char == "	")
      new_str += "\\t";
    else if (char == "\f")
      new_str += "\\f";
    else if (char == "\\")
      new_str += "\\\\";
    else if (char == '"')
      new_str += '\\"';
    else if (char < " " || char > "~" && char < "\xA0") {
      new_str += "\\u{" + char.charCodeAt(0).toString(16).toUpperCase().padStart(4, "0") + "}";
    } else {
      new_str += char;
    }
  }
  new_str += '"';
  return new_str;
}
function echo$inspectDict2(map4) {
  let body = "dict.from_list([";
  let first3 = true;
  let key_value_pairs = [];
  map4.forEach((value2, key) => {
    key_value_pairs.push([key, value2]);
  });
  key_value_pairs.sort();
  key_value_pairs.forEach(([key, value2]) => {
    if (!first3)
      body = body + ", ";
    body = body + "#(" + echo$inspect2(key) + ", " + echo$inspect2(value2) + ")";
    first3 = false;
  });
  return body + "])";
}
function echo$inspectCustomType2(record) {
  const props = globalThis.Object.keys(record).map((label) => {
    const value2 = echo$inspect2(record[label]);
    return isNaN(parseInt(label)) ? `${label}: ${value2}` : value2;
  }).join(", ");
  return props ? `${record.constructor.name}(${props})` : record.constructor.name;
}
function echo$inspectObject2(v) {
  const name6 = Object.getPrototypeOf(v)?.constructor?.name || "Object";
  const props = [];
  for (const k of Object.keys(v)) {
    props.push(`${echo$inspect2(k)}: ${echo$inspect2(v[k])}`);
  }
  const body = props.length ? " " + props.join(", ") + " " : "";
  const head = name6 === "Object" ? "" : name6 + " ";
  return `//js(${head}{${body}})`;
}
function echo$inspect2(v) {
  const t = typeof v;
  if (v === true)
    return "True";
  if (v === false)
    return "False";
  if (v === null)
    return "//js(null)";
  if (v === void 0)
    return "Nil";
  if (t === "string")
    return echo$inspectString2(v);
  if (t === "bigint" || t === "number")
    return v.toString();
  if (globalThis.Array.isArray(v))
    return `#(${v.map(echo$inspect2).join(", ")})`;
  if (v instanceof List)
    return `[${v.toArray().map(echo$inspect2).join(", ")}]`;
  if (v instanceof UtfCodepoint)
    return `//utfcodepoint(${String.fromCodePoint(v.value)})`;
  if (v instanceof BitArray)
    return echo$inspectBitArray2(v);
  if (v instanceof CustomType)
    return echo$inspectCustomType2(v);
  if (echo$isDict2(v))
    return echo$inspectDict2(v);
  if (v instanceof Set)
    return `//js(Set(${[...v].map(echo$inspect2).join(", ")}))`;
  if (v instanceof RegExp)
    return `//js(${v})`;
  if (v instanceof Date)
    return `//js(Date("${v.toISOString()}"))`;
  if (v instanceof Function) {
    const args = [];
    for (const i of Array(v.length).keys())
      args.push(String.fromCharCode(i + 97));
    return `//fn(${args.join(", ")}) { ... }`;
  }
  return echo$inspectObject2(v);
}
function echo$inspectBitArray2(bitArray) {
  let endOfAlignedBytes = bitArray.bitOffset + 8 * Math.trunc(bitArray.bitSize / 8);
  let alignedBytes = bitArraySlice(
    bitArray,
    bitArray.bitOffset,
    endOfAlignedBytes
  );
  let remainingUnalignedBits = bitArray.bitSize % 8;
  if (remainingUnalignedBits > 0) {
    let remainingBits = bitArraySliceToInt(
      bitArray,
      endOfAlignedBytes,
      bitArray.bitSize,
      false,
      false
    );
    let alignedBytesArray = Array.from(alignedBytes.rawBuffer);
    let suffix = `${remainingBits}:size(${remainingUnalignedBits})`;
    if (alignedBytesArray.length === 0) {
      return `<<${suffix}>>`;
    } else {
      return `<<${Array.from(alignedBytes.rawBuffer).join(", ")}, ${suffix}>>`;
    }
  } else {
    return `<<${Array.from(alignedBytes.rawBuffer).join(", ")}>>`;
  }
}
function echo$isDict2(value2) {
  try {
    return value2 instanceof Dict;
  } catch {
    return false;
  }
}

// src/lustre_ui_components.mjs
register();
register2();
register3();
register4();
