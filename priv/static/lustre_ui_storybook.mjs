// build/dev/javascript/prelude.mjs
var CustomType = class {
  withFields(fields) {
    let properties = Object.keys(this).map(
      (label2) => label2 in fields ? fields[label2] : this[label2]
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
    let current2 = this;
    while (desired-- > 0 && current2) current2 = current2.tail;
    return current2 !== void 0;
  }
  // @internal
  hasLength(desired) {
    let current2 = this;
    while (desired-- > 0 && current2) current2 = current2.tail;
    return desired === -1 && current2 instanceof Empty;
  }
  // @internal
  countLength() {
    let current2 = this;
    let length4 = 0;
    while (current2) {
      current2 = current2.tail;
      length4++;
    }
    return length4 - 1;
  }
};
function prepend(element15, tail) {
  return new NonEmpty(element15, tail);
}
function toList(elements, tail) {
  return List.fromArray(elements, tail);
}
var ListIterator = class {
  #current;
  constructor(current2) {
    this.#current = current2;
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
  byteAt(index5) {
    if (index5 < 0 || index5 >= this.byteSize) {
      return void 0;
    }
    return bitArrayByteAt(this.rawBuffer, this.bitOffset, index5);
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
        const a2 = bitArrayByteAt(this.rawBuffer, this.bitOffset, i);
        const b = bitArrayByteAt(other.rawBuffer, other.bitOffset, i);
        if (a2 !== b) {
          return false;
        }
      }
      const trailingBitsCount = this.bitSize % 8;
      if (trailingBitsCount) {
        const a2 = bitArrayByteAt(
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
        if (a2 >> unusedLowBitCount !== b >> unusedLowBitCount) {
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
function bitArrayByteAt(buffer, bitOffset, index5) {
  if (bitOffset === 0) {
    return buffer[index5] ?? 0;
  } else {
    const a2 = buffer[index5] << bitOffset & 255;
    const b = buffer[index5 + 1] >> 8 - bitOffset;
    return a2 | b;
  }
}
var UtfCodepoint = class {
  constructor(value3) {
    this.value = value3;
  }
};
var isBitArrayDeprecationMessagePrinted = {};
function bitArrayPrintDeprecationWarning(name6, message2) {
  if (isBitArrayDeprecationMessagePrinted[name6]) {
    return;
  }
  console.warn(
    `Deprecated BitArray.${name6} property used in JavaScript FFI code. ${message2}.`
  );
  isBitArrayDeprecationMessagePrinted[name6] = true;
}
function bitArraySlice(bitArray, start6, end) {
  end ??= bitArray.bitSize;
  bitArrayValidateRange(bitArray, start6, end);
  if (start6 === end) {
    return new BitArray(new Uint8Array());
  }
  if (start6 === 0 && end === bitArray.bitSize) {
    return bitArray;
  }
  start6 += bitArray.bitOffset;
  end += bitArray.bitOffset;
  const startByteIndex = Math.trunc(start6 / 8);
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
  return new BitArray(buffer, end - start6, start6 % 8);
}
function bitArraySliceToInt(bitArray, start6, end, isBigEndian, isSigned) {
  bitArrayValidateRange(bitArray, start6, end);
  if (start6 === end) {
    return 0;
  }
  start6 += bitArray.bitOffset;
  end += bitArray.bitOffset;
  const isStartByteAligned = start6 % 8 === 0;
  const isEndByteAligned = end % 8 === 0;
  if (isStartByteAligned && isEndByteAligned) {
    return intFromAlignedSlice(
      bitArray,
      start6 / 8,
      end / 8,
      isBigEndian,
      isSigned
    );
  }
  const size3 = end - start6;
  const startByteIndex = Math.trunc(start6 / 8);
  const endByteIndex = Math.trunc((end - 1) / 8);
  if (startByteIndex == endByteIndex) {
    const mask2 = 255 >> start6 % 8;
    const unusedLowBitCount = (8 - end % 8) % 8;
    let value3 = (bitArray.rawBuffer[startByteIndex] & mask2) >> unusedLowBitCount;
    if (isSigned) {
      const highBit = 2 ** (size3 - 1);
      if (value3 >= highBit) {
        value3 -= highBit * 2;
      }
    }
    return value3;
  }
  if (size3 <= 53) {
    return intFromUnalignedSliceUsingNumber(
      bitArray.rawBuffer,
      start6,
      end,
      isBigEndian,
      isSigned
    );
  } else {
    return intFromUnalignedSliceUsingBigInt(
      bitArray.rawBuffer,
      start6,
      end,
      isBigEndian,
      isSigned
    );
  }
}
function intFromAlignedSlice(bitArray, start6, end, isBigEndian, isSigned) {
  const byteSize = end - start6;
  if (byteSize <= 6) {
    return intFromAlignedSliceUsingNumber(
      bitArray.rawBuffer,
      start6,
      end,
      isBigEndian,
      isSigned
    );
  } else {
    return intFromAlignedSliceUsingBigInt(
      bitArray.rawBuffer,
      start6,
      end,
      isBigEndian,
      isSigned
    );
  }
}
function intFromAlignedSliceUsingNumber(buffer, start6, end, isBigEndian, isSigned) {
  const byteSize = end - start6;
  let value3 = 0;
  if (isBigEndian) {
    for (let i = start6; i < end; i++) {
      value3 *= 256;
      value3 += buffer[i];
    }
  } else {
    for (let i = end - 1; i >= start6; i--) {
      value3 *= 256;
      value3 += buffer[i];
    }
  }
  if (isSigned) {
    const highBit = 2 ** (byteSize * 8 - 1);
    if (value3 >= highBit) {
      value3 -= highBit * 2;
    }
  }
  return value3;
}
function intFromAlignedSliceUsingBigInt(buffer, start6, end, isBigEndian, isSigned) {
  const byteSize = end - start6;
  let value3 = 0n;
  if (isBigEndian) {
    for (let i = start6; i < end; i++) {
      value3 *= 256n;
      value3 += BigInt(buffer[i]);
    }
  } else {
    for (let i = end - 1; i >= start6; i--) {
      value3 *= 256n;
      value3 += BigInt(buffer[i]);
    }
  }
  if (isSigned) {
    const highBit = 1n << BigInt(byteSize * 8 - 1);
    if (value3 >= highBit) {
      value3 -= highBit * 2n;
    }
  }
  return Number(value3);
}
function intFromUnalignedSliceUsingNumber(buffer, start6, end, isBigEndian, isSigned) {
  const isStartByteAligned = start6 % 8 === 0;
  let size3 = end - start6;
  let byteIndex = Math.trunc(start6 / 8);
  let value3 = 0;
  if (isBigEndian) {
    if (!isStartByteAligned) {
      const leadingBitsCount = 8 - start6 % 8;
      value3 = buffer[byteIndex++] & (1 << leadingBitsCount) - 1;
      size3 -= leadingBitsCount;
    }
    while (size3 >= 8) {
      value3 *= 256;
      value3 += buffer[byteIndex++];
      size3 -= 8;
    }
    if (size3 > 0) {
      value3 *= 2 ** size3;
      value3 += buffer[byteIndex] >> 8 - size3;
    }
  } else {
    if (isStartByteAligned) {
      let size4 = end - start6;
      let scale = 1;
      while (size4 >= 8) {
        value3 += buffer[byteIndex++] * scale;
        scale *= 256;
        size4 -= 8;
      }
      value3 += (buffer[byteIndex] >> 8 - size4) * scale;
    } else {
      const highBitsCount = start6 % 8;
      const lowBitsCount = 8 - highBitsCount;
      let size4 = end - start6;
      let scale = 1;
      while (size4 >= 8) {
        const byte = buffer[byteIndex] << highBitsCount | buffer[byteIndex + 1] >> lowBitsCount;
        value3 += (byte & 255) * scale;
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
        value3 += trailingByte * scale;
      }
    }
  }
  if (isSigned) {
    const highBit = 2 ** (end - start6 - 1);
    if (value3 >= highBit) {
      value3 -= highBit * 2;
    }
  }
  return value3;
}
function intFromUnalignedSliceUsingBigInt(buffer, start6, end, isBigEndian, isSigned) {
  const isStartByteAligned = start6 % 8 === 0;
  let size3 = end - start6;
  let byteIndex = Math.trunc(start6 / 8);
  let value3 = 0n;
  if (isBigEndian) {
    if (!isStartByteAligned) {
      const leadingBitsCount = 8 - start6 % 8;
      value3 = BigInt(buffer[byteIndex++] & (1 << leadingBitsCount) - 1);
      size3 -= leadingBitsCount;
    }
    while (size3 >= 8) {
      value3 *= 256n;
      value3 += BigInt(buffer[byteIndex++]);
      size3 -= 8;
    }
    if (size3 > 0) {
      value3 <<= BigInt(size3);
      value3 += BigInt(buffer[byteIndex] >> 8 - size3);
    }
  } else {
    if (isStartByteAligned) {
      let size4 = end - start6;
      let shift = 0n;
      while (size4 >= 8) {
        value3 += BigInt(buffer[byteIndex++]) << shift;
        shift += 8n;
        size4 -= 8;
      }
      value3 += BigInt(buffer[byteIndex] >> 8 - size4) << shift;
    } else {
      const highBitsCount = start6 % 8;
      const lowBitsCount = 8 - highBitsCount;
      let size4 = end - start6;
      let shift = 0n;
      while (size4 >= 8) {
        const byte = buffer[byteIndex] << highBitsCount | buffer[byteIndex + 1] >> lowBitsCount;
        value3 += BigInt(byte & 255) << shift;
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
        value3 += BigInt(trailingByte) << shift;
      }
    }
  }
  if (isSigned) {
    const highBit = 2n ** BigInt(end - start6 - 1);
    if (value3 >= highBit) {
      value3 -= highBit * 2n;
    }
  }
  return Number(value3);
}
function bitArrayValidateRange(bitArray, start6, end) {
  if (start6 < 0 || start6 > bitArray.bitSize || end < start6 || end > bitArray.bitSize) {
    const msg = `Invalid bit array slice: start = ${start6}, end = ${end}, bit size = ${bitArray.bitSize}`;
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
  constructor(value3) {
    super();
    this[0] = value3;
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
    let a2 = values3.pop();
    let b = values3.pop();
    if (a2 === b) continue;
    if (!isObject(a2) || !isObject(b)) return false;
    let unequal = !structurallyCompatibleObjects(a2, b) || unequalDates(a2, b) || unequalBuffers(a2, b) || unequalArrays(a2, b) || unequalMaps(a2, b) || unequalSets(a2, b) || unequalRegExps(a2, b);
    if (unequal) return false;
    const proto = Object.getPrototypeOf(a2);
    if (proto !== null && typeof proto.equals === "function") {
      try {
        if (a2.equals(b)) continue;
        else return false;
      } catch {
      }
    }
    let [keys2, get5] = getters(a2);
    for (let k of keys2(a2)) {
      values3.push(get5(a2, k), get5(b, k));
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
function unequalDates(a2, b) {
  return a2 instanceof Date && (a2 > b || a2 < b);
}
function unequalBuffers(a2, b) {
  return !(a2 instanceof BitArray) && a2.buffer instanceof ArrayBuffer && a2.BYTES_PER_ELEMENT && !(a2.byteLength === b.byteLength && a2.every((n, i) => n === b[i]));
}
function unequalArrays(a2, b) {
  return Array.isArray(a2) && a2.length !== b.length;
}
function unequalMaps(a2, b) {
  return a2 instanceof Map && a2.size !== b.size;
}
function unequalSets(a2, b) {
  return a2 instanceof Set && (a2.size != b.size || [...a2].some((e) => !b.has(e)));
}
function unequalRegExps(a2, b) {
  return a2 instanceof RegExp && (a2.source !== b.source || a2.flags !== b.flags);
}
function isObject(a2) {
  return typeof a2 === "object" && a2 !== null;
}
function structurallyCompatibleObjects(a2, b) {
  if (typeof a2 !== "object" && typeof b !== "object" && (!a2 || !b))
    return false;
  let nonstructural = [Promise, WeakSet, WeakMap, Function];
  if (nonstructural.some((c) => a2 instanceof c)) return false;
  return a2.constructor === b.constructor;
}
function divideFloat(a2, b) {
  if (b === 0) {
    return 0;
  } else {
    return a2 / b;
  }
}
function makeError(variant, file, module, line, fn, message2, extra) {
  let error = new globalThis.Error(message2);
  error.gleam_error = variant;
  error.file = file;
  error.module = module;
  error.line = line;
  error.function = fn;
  error.fn = fn;
  for (let k in extra) error[k] = extra[k];
  return error;
}

// build/dev/javascript/gleam_stdlib/gleam/option.mjs
var Some = class extends CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
};
var None = class extends CustomType {
};
function to_result(option3, e) {
  if (option3 instanceof Some) {
    let a2 = option3[0];
    return new Ok(a2);
  } else {
    return new Error(e);
  }
}
function from_result(result) {
  if (result instanceof Ok) {
    let a2 = result[0];
    return new Some(a2);
  } else {
    return new None();
  }
}
function unwrap(option3, default$2) {
  if (option3 instanceof Some) {
    let x = option3[0];
    return x;
  } else {
    return default$2;
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
function hashMerge(a2, b) {
  return a2 ^ b + 2654435769 + (a2 << 6) + (a2 >> 2) | 0;
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
      const code2 = o.hashCode(o);
      if (typeof code2 === "number") {
        return code2;
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
  if (u === null) return 1108378658;
  if (u === void 0) return 1108378659;
  if (u === true) return 1108378657;
  if (u === false) return 1108378656;
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
    const item3 = items[i];
    if (item3 === void 0) {
      continue;
    }
    if (item3.type === ENTRY) {
      fn(item3.v, item3.k);
      continue;
    }
    forEach(item3, fn);
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

// build/dev/javascript/gleam_stdlib/gleam/order.mjs
var Lt = class extends CustomType {
};
var Eq = class extends CustomType {
};
var Gt = class extends CustomType {
};

// build/dev/javascript/gleam_stdlib/gleam/float.mjs
function negate(x) {
  return -1 * x;
}
function round2(x) {
  let $ = x >= 0;
  if ($) {
    return round(x);
  } else {
    return 0 - round(negate(x));
  }
}
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
function divide(a2, b) {
  if (b === 0) {
    return new Error(void 0);
  } else {
    let b$1 = b;
    return new Ok(divideFloat(a2, b$1));
  }
}

// build/dev/javascript/gleam_stdlib/gleam/int.mjs
function compare(a2, b) {
  let $ = a2 === b;
  if ($) {
    return new Eq();
  } else {
    let $1 = a2 < b;
    if ($1) {
      return new Lt();
    } else {
      return new Gt();
    }
  }
}
function min(a2, b) {
  let $ = a2 < b;
  if ($) {
    return a2;
  } else {
    return b;
  }
}
function max(a2, b) {
  let $ = a2 > b;
  if ($) {
    return a2;
  } else {
    return b;
  }
}
function add(a2, b) {
  return a2 + b;
}
function subtract(a2, b) {
  return a2 - b;
}

// build/dev/javascript/gleam_stdlib/gleam/list.mjs
var Ascending = class extends CustomType {
};
var Descending = class extends CustomType {
};
function length_loop(loop$list, loop$count) {
  while (true) {
    let list4 = loop$list;
    let count = loop$count;
    if (list4 instanceof Empty) {
      return count;
    } else {
      let list$1 = list4.tail;
      loop$list = list$1;
      loop$count = count + 1;
    }
  }
}
function length(list4) {
  return length_loop(list4, 0);
}
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
function is_empty(list4) {
  return isEqual(list4, toList([]));
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
function filter(list4, predicate) {
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
function prepend2(list4, item3) {
  return prepend(item3, list4);
}
function flatten_loop(loop$lists, loop$acc) {
  while (true) {
    let lists = loop$lists;
    let acc = loop$acc;
    if (lists instanceof Empty) {
      return reverse(acc);
    } else {
      let list4 = lists.head;
      let further_lists = lists.tail;
      loop$lists = further_lists;
      loop$acc = reverse_and_prepend(list4, acc);
    }
  }
}
function flatten(lists) {
  return flatten_loop(lists, toList([]));
}
function flat_map(list4, fun) {
  return flatten(map(list4, fun));
}
function fold(loop$list, loop$initial, loop$fun) {
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
    let index5 = loop$index;
    if (over instanceof Empty) {
      return acc;
    } else {
      let first$1 = over.head;
      let rest$1 = over.tail;
      loop$over = rest$1;
      loop$acc = with$(acc, first$1, index5);
      loop$with = with$;
      loop$index = index5 + 1;
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
function find_map(loop$list, loop$fun) {
  while (true) {
    let list4 = loop$list;
    let fun = loop$fun;
    if (list4 instanceof Empty) {
      return new Error(void 0);
    } else {
      let first$1 = list4.head;
      let rest$1 = list4.tail;
      let $ = fun(first$1);
      if ($ instanceof Ok) {
        let first$2 = $[0];
        return new Ok(first$2);
      } else {
        loop$list = rest$1;
        loop$fun = fun;
      }
    }
  }
}
function sequences(loop$list, loop$compare, loop$growing, loop$direction, loop$prev, loop$acc) {
  while (true) {
    let list4 = loop$list;
    let compare5 = loop$compare;
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
      let $ = compare5(prev, new$1);
      if (direction instanceof Ascending) {
        if ($ instanceof Lt) {
          loop$list = rest$1;
          loop$compare = compare5;
          loop$growing = growing$1;
          loop$direction = direction;
          loop$prev = new$1;
          loop$acc = acc;
        } else if ($ instanceof Eq) {
          loop$list = rest$1;
          loop$compare = compare5;
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
            let $1 = compare5(new$1, next2);
            if ($1 instanceof Lt) {
              _block$1 = new Ascending();
            } else if ($1 instanceof Eq) {
              _block$1 = new Ascending();
            } else {
              _block$1 = new Descending();
            }
            let direction$1 = _block$1;
            loop$list = rest$2;
            loop$compare = compare5;
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
          let $1 = compare5(new$1, next2);
          if ($1 instanceof Lt) {
            _block$1 = new Ascending();
          } else if ($1 instanceof Eq) {
            _block$1 = new Ascending();
          } else {
            _block$1 = new Descending();
          }
          let direction$1 = _block$1;
          loop$list = rest$2;
          loop$compare = compare5;
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
          let $1 = compare5(new$1, next2);
          if ($1 instanceof Lt) {
            _block$1 = new Ascending();
          } else if ($1 instanceof Eq) {
            _block$1 = new Ascending();
          } else {
            _block$1 = new Descending();
          }
          let direction$1 = _block$1;
          loop$list = rest$2;
          loop$compare = compare5;
          loop$growing = toList([new$1]);
          loop$direction = direction$1;
          loop$prev = next2;
          loop$acc = acc$1;
        }
      } else {
        loop$list = rest$1;
        loop$compare = compare5;
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
    let compare5 = loop$compare;
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
      let $ = compare5(first1, first22);
      if ($ instanceof Lt) {
        loop$list1 = rest1;
        loop$list2 = list22;
        loop$compare = compare5;
        loop$acc = prepend(first1, acc);
      } else if ($ instanceof Eq) {
        loop$list1 = list1;
        loop$list2 = rest2;
        loop$compare = compare5;
        loop$acc = prepend(first22, acc);
      } else {
        loop$list1 = list1;
        loop$list2 = rest2;
        loop$compare = compare5;
        loop$acc = prepend(first22, acc);
      }
    }
  }
}
function merge_ascending_pairs(loop$sequences, loop$compare, loop$acc) {
  while (true) {
    let sequences2 = loop$sequences;
    let compare5 = loop$compare;
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
          compare5,
          toList([])
        );
        loop$sequences = rest$1;
        loop$compare = compare5;
        loop$acc = prepend(descending, acc);
      }
    }
  }
}
function merge_descendings(loop$list1, loop$list2, loop$compare, loop$acc) {
  while (true) {
    let list1 = loop$list1;
    let list22 = loop$list2;
    let compare5 = loop$compare;
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
      let $ = compare5(first1, first22);
      if ($ instanceof Lt) {
        loop$list1 = list1;
        loop$list2 = rest2;
        loop$compare = compare5;
        loop$acc = prepend(first22, acc);
      } else if ($ instanceof Eq) {
        loop$list1 = rest1;
        loop$list2 = list22;
        loop$compare = compare5;
        loop$acc = prepend(first1, acc);
      } else {
        loop$list1 = rest1;
        loop$list2 = list22;
        loop$compare = compare5;
        loop$acc = prepend(first1, acc);
      }
    }
  }
}
function merge_descending_pairs(loop$sequences, loop$compare, loop$acc) {
  while (true) {
    let sequences2 = loop$sequences;
    let compare5 = loop$compare;
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
          compare5,
          toList([])
        );
        loop$sequences = rest$1;
        loop$compare = compare5;
        loop$acc = prepend(ascending, acc);
      }
    }
  }
}
function merge_all(loop$sequences, loop$direction, loop$compare) {
  while (true) {
    let sequences2 = loop$sequences;
    let direction = loop$direction;
    let compare5 = loop$compare;
    if (sequences2 instanceof Empty) {
      return toList([]);
    } else if (direction instanceof Ascending) {
      let $ = sequences2.tail;
      if ($ instanceof Empty) {
        let sequence = sequences2.head;
        return sequence;
      } else {
        let sequences$1 = merge_ascending_pairs(sequences2, compare5, toList([]));
        loop$sequences = sequences$1;
        loop$direction = new Descending();
        loop$compare = compare5;
      }
    } else {
      let $ = sequences2.tail;
      if ($ instanceof Empty) {
        let sequence = sequences2.head;
        return reverse(sequence);
      } else {
        let sequences$1 = merge_descending_pairs(sequences2, compare5, toList([]));
        loop$sequences = sequences$1;
        loop$direction = new Ascending();
        loop$compare = compare5;
      }
    }
  }
}
function sort(list4, compare5) {
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
      let $1 = compare5(x, y);
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
        compare5,
        toList([x]),
        direction,
        y,
        toList([])
      );
      return merge_all(sequences$1, new Ascending(), compare5);
    }
  }
}
function key_find(keyword_list, desired_key) {
  return find_map(
    keyword_list,
    (keyword) => {
      let key = keyword[0];
      let value3 = keyword[1];
      let $ = isEqual(key, desired_key);
      if ($) {
        return new Ok(value3);
      } else {
        return new Error(void 0);
      }
    }
  );
}

// build/dev/javascript/gleam_stdlib/gleam/string.mjs
function replace(string5, pattern, substitute) {
  let _pipe = string5;
  let _pipe$1 = identity(_pipe);
  let _pipe$2 = string_replace(_pipe$1, pattern, substitute);
  return identity(_pipe$2);
}
function slice(string5, idx, len) {
  let $ = len < 0;
  if ($) {
    return "";
  } else {
    let $1 = idx < 0;
    if ($1) {
      let translated_idx = string_length(string5) + idx;
      let $2 = translated_idx < 0;
      if ($2) {
        return "";
      } else {
        return string_slice(string5, translated_idx, len);
      }
    } else {
      return string_slice(string5, idx, len);
    }
  }
}
function drop_end(string5, num_graphemes) {
  let $ = num_graphemes < 0;
  if ($) {
    return string5;
  } else {
    return slice(string5, 0, string_length(string5) - num_graphemes);
  }
}
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
    let separator2 = loop$separator;
    let accumulator = loop$accumulator;
    if (strings instanceof Empty) {
      return accumulator;
    } else {
      let string5 = strings.head;
      let strings$1 = strings.tail;
      loop$strings = strings$1;
      loop$separator = separator2;
      loop$accumulator = accumulator + separator2 + string5;
    }
  }
}
function join(strings, separator2) {
  if (strings instanceof Empty) {
    return "";
  } else {
    let first$1 = strings.head;
    let rest = strings.tail;
    return join_loop(rest, separator2, first$1);
  }
}
function split2(x, substring) {
  if (substring === "") {
    return graphemes(x);
  } else {
    let _pipe = x;
    let _pipe$1 = identity(_pipe);
    let _pipe$2 = split(_pipe$1, substring);
    return map(_pipe$2, identity);
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
function run(data, decoder2) {
  let $ = decoder2.function(data);
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
function map2(decoder2, transformer) {
  return new Decoder(
    (d) => {
      let $ = decoder2.function(d);
      let data = $[0];
      let errors = $[1];
      return [transformer(data), errors];
    }
  );
}
function then$(decoder2, next2) {
  return new Decoder(
    (dynamic_data) => {
      let $ = decoder2.function(dynamic_data);
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
      let decoder2 = decoders.head;
      let decoders$1 = decoders.tail;
      let $ = decoder2.function(data);
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
  let decoder2 = one_of(
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
      let $ = run(key$1, decoder2);
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
        let default$2 = $1[0];
        let _pipe = [
          default$2,
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
          let default$2 = $12[0];
          let _pipe = [
            default$2,
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
function float_to_string(float4) {
  const string5 = float4.toString().replace("+", "");
  if (string5.indexOf(".") >= 0) {
    return string5;
  } else {
    const index5 = string5.indexOf("e");
    if (index5 >= 0) {
      return string5.slice(0, index5) + ".0" + string5.slice(index5);
    } else {
      return string5 + ".0";
    }
  }
}
function string_replace(string5, target, substitute) {
  if (typeof string5.replaceAll !== "undefined") {
    return string5.replaceAll(target, substitute);
  }
  return string5.replace(
    // $& means the whole matched string
    new RegExp(target.replace(/[.*+?^${}()|[\]\\]/g, "\\$&"), "g"),
    substitute
  );
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
function graphemes(string5) {
  const iterator = graphemes_iterator(string5);
  if (iterator) {
    return List.fromArray(Array.from(iterator).map((item3) => item3.segment));
  } else {
    return List.fromArray(string5.match(/./gsu));
  }
}
var segmenter = void 0;
function graphemes_iterator(string5) {
  if (globalThis.Intl && Intl.Segmenter) {
    segmenter ||= new Intl.Segmenter();
    return segmenter.segment(string5)[Symbol.iterator]();
  }
}
function pop_codeunit(str) {
  return [str.charCodeAt(0) | 0, str.slice(1)];
}
function lowercase(string5) {
  return string5.toLowerCase();
}
function split(xs, pattern) {
  return List.fromArray(xs.split(pattern));
}
function string_slice(string5, idx, len) {
  if (len <= 0 || idx >= string5.length) {
    return "";
  }
  const iterator = graphemes_iterator(string5);
  if (iterator) {
    while (idx-- > 0) {
      iterator.next();
    }
    let result = "";
    while (len-- > 0) {
      const v = iterator.next().value;
      if (v === void 0) {
        break;
      }
      result += v.segment;
    }
    return result;
  } else {
    return string5.match(/./gsu).slice(idx, idx + len).join("");
  }
}
function string_codeunit_slice(str, from2, length4) {
  return str.slice(from2, from2 + length4);
}
function contains_string(haystack, needle) {
  return haystack.indexOf(needle) >= 0;
}
function starts_with(haystack, needle) {
  return haystack.startsWith(needle);
}
function split_once(haystack, needle) {
  const index5 = haystack.indexOf(needle);
  if (index5 >= 0) {
    const before = haystack.slice(0, index5);
    const after = haystack.slice(index5 + needle.length);
    return new Ok([before, after]);
  } else {
    return new Error(Nil);
  }
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
function round(float4) {
  return Math.round(float4);
}
function new_map() {
  return Dict.new();
}
function map_size(map6) {
  return map6.size;
}
function map_to_list(map6) {
  return List.fromArray(map6.entries());
}
function map_remove(key, map6) {
  return map6.delete(key);
}
function map_get(map6, key) {
  const value3 = map6.get(key, NOT_FOUND);
  if (value3 === NOT_FOUND) {
    return new Error(Nil);
  }
  return new Ok(value3);
}
function map_insert(key, value3, map6) {
  return map6.set(key, value3);
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
    if (entry === token2) return new Ok(new None());
    return new Ok(new Some(entry));
  }
  const key_is_int = Number.isInteger(key);
  if (key_is_int && key >= 0 && key < 8 && data instanceof List) {
    let i = 0;
    for (const value3 of data) {
      if (i === key) return new Ok(new Some(value3));
      i++;
    }
    return new Error("Indexable");
  }
  if (key_is_int && Array.isArray(data) || data && typeof data === "object" || data && Object.getPrototypeOf(data) === Object.prototype) {
    if (key in data) return new Ok(new Some(data[key]));
    return new Ok(new None());
  }
  return new Error(key_is_int ? "Indexable" : "Dict");
}
function int(data) {
  if (Number.isInteger(data)) return new Ok(data);
  return new Error(0);
}
function string(data) {
  if (typeof data === "string") return new Ok(data);
  return new Error("");
}

// build/dev/javascript/gleam_stdlib/gleam/dict.mjs
function is_empty2(dict2) {
  return map_size(dict2) === 0;
}
function do_has_key(key, dict2) {
  return !isEqual(map_get(dict2, key), new Error(void 0));
}
function has_key(dict2, key) {
  return do_has_key(key, dict2);
}
function insert(dict2, key, value3) {
  return map_insert(key, value3, dict2);
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
function fold2(dict2, initial, fun) {
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
  return fold2(dict2, new_map(), insert$1);
}
function filter2(dict2, predicate) {
  return do_filter(predicate, dict2);
}

// build/dev/javascript/gleam_stdlib/gleam/dynamic.mjs
function nil() {
  return identity(void 0);
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
function map_error(result, fun) {
  if (result instanceof Ok) {
    let x = result[0];
    return new Ok(x);
  } else {
    let error = result[0];
    return new Error(fun(error));
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
function unwrap2(result, default$2) {
  if (result instanceof Ok) {
    let v = result[0];
    return v;
  } else {
    return default$2;
  }
}
function unwrap_both(result) {
  if (result instanceof Ok) {
    let a2 = result[0];
    return a2;
  } else {
    let a2 = result[0];
    return a2;
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
function identity2(x) {
  return x;
}

// build/dev/javascript/gleam_json/gleam_json_ffi.mjs
function json_to_string(json2) {
  return JSON.stringify(json2);
}
function object(entries) {
  return Object.fromEntries(entries);
}
function identity3(x) {
  return x;
}
function do_null() {
  return null;
}
function decode(string5) {
  try {
    const result = JSON.parse(string5);
    return new Ok(result);
  } catch (err) {
    return new Error(getJsonDecodeError(err, string5));
  }
}
function getJsonDecodeError(stdErr, json2) {
  if (isUnexpectedEndOfInput(stdErr)) return new UnexpectedEndOfInput();
  return toUnexpectedByteError(stdErr, json2);
}
function isUnexpectedEndOfInput(err) {
  const unexpectedEndOfInputRegex = /((unexpected (end|eof))|(end of data)|(unterminated string)|(json( parse error|\.parse)\: expected '(\:|\}|\])'))/i;
  return unexpectedEndOfInputRegex.test(err.message);
}
function toUnexpectedByteError(err, json2) {
  let converters = [
    v8UnexpectedByteError,
    oldV8UnexpectedByteError,
    jsCoreUnexpectedByteError,
    spidermonkeyUnexpectedByteError
  ];
  for (let converter of converters) {
    let result = converter(err, json2);
    if (result) return result;
  }
  return new UnexpectedByte("", 0);
}
function v8UnexpectedByteError(err) {
  const regex = /unexpected token '(.)', ".+" is not valid JSON/i;
  const match = regex.exec(err.message);
  if (!match) return null;
  const byte = toHex(match[1]);
  return new UnexpectedByte(byte, -1);
}
function oldV8UnexpectedByteError(err) {
  const regex = /unexpected token (.) in JSON at position (\d+)/i;
  const match = regex.exec(err.message);
  if (!match) return null;
  const byte = toHex(match[1]);
  const position = Number(match[2]);
  return new UnexpectedByte(byte, position);
}
function spidermonkeyUnexpectedByteError(err, json2) {
  const regex = /(unexpected character|expected .*) at line (\d+) column (\d+)/i;
  const match = regex.exec(err.message);
  if (!match) return null;
  const line = Number(match[2]);
  const column = Number(match[3]);
  const position = getPositionFromMultiline(line, column, json2);
  const byte = toHex(json2[position]);
  return new UnexpectedByte(byte, position);
}
function jsCoreUnexpectedByteError(err) {
  const regex = /unexpected (identifier|token) "(.)"/i;
  const match = regex.exec(err.message);
  if (!match) return null;
  const byte = toHex(match[2]);
  return new UnexpectedByte(byte, 0);
}
function toHex(char) {
  return "0x" + char.charCodeAt(0).toString(16).toUpperCase();
}
function getPositionFromMultiline(line, column, string5) {
  if (line === 1) return column - 1;
  let currentLn = 1;
  let position = 0;
  string5.split("").find((char, idx) => {
    if (char === "\n") currentLn += 1;
    if (currentLn === line) {
      position = idx + column;
      return true;
    }
    return false;
  });
  return position;
}

// build/dev/javascript/gleam_json/gleam/json.mjs
var UnexpectedEndOfInput = class extends CustomType {
};
var UnexpectedByte = class extends CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
};
var UnableToDecode = class extends CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
};
function do_parse(json2, decoder2) {
  return then$2(
    decode(json2),
    (dynamic_value) => {
      let _pipe = run(dynamic_value, decoder2);
      return map_error(
        _pipe,
        (var0) => {
          return new UnableToDecode(var0);
        }
      );
    }
  );
}
function parse(json2, decoder2) {
  return do_parse(json2, decoder2);
}
function to_string3(json2) {
  return json_to_string(json2);
}
function string3(input3) {
  return identity3(input3);
}
function bool2(input3) {
  return identity3(input3);
}
function int3(input3) {
  return identity3(input3);
}
function null$() {
  return do_null();
}
function object2(entries) {
  return object(entries);
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
function size(set3) {
  return map_size(set3.dict);
}
function contains(set3, member) {
  let _pipe = set3.dict;
  let _pipe$1 = map_get(_pipe, member);
  return is_ok(_pipe$1);
}
function delete$2(set3, member) {
  return new Set2(delete$(set3.dict, member));
}
function filter3(set3, predicate) {
  return new Set2(filter2(set3.dict, (m, _) => {
    return predicate(m);
  }));
}
var token = void 0;
function insert2(set3, member) {
  return new Set2(insert(set3.dict, member, token));
}
function from_list2(members) {
  let dict2 = fold(
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
function compare3(a2, b) {
  if (a2.name === b.name) {
    return EQ;
  } else if (a2.name < b.name) {
    return LT;
  } else {
    return GT;
  }
}

// build/dev/javascript/lustre/lustre/vdom/vattr.mjs
var Attribute = class extends CustomType {
  constructor(kind, name6, value3) {
    super();
    this.kind = kind;
    this.name = name6;
    this.value = value3;
  }
};
var Property = class extends CustomType {
  constructor(kind, name6, value3) {
    super();
    this.kind = kind;
    this.name = name6;
    this.value = value3;
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
  constructor(prevent_default3, stop_propagation, message2) {
    super();
    this.prevent_default = prevent_default3;
    this.stop_propagation = stop_propagation;
    this.message = message2;
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
                  let value3 = class1 + " " + class2;
                  let attribute$1 = new Attribute(kind, "class", value3);
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
                  let style22 = $4.value;
                  let value3 = style1 + ";" + style22;
                  let attribute$1 = new Attribute(kind, "style", value3);
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
      let _pipe$1 = sort(_pipe, (a2, b) => {
        return compare3(b, a2);
      });
      return merge(_pipe$1, empty_list);
    }
  }
}
var attribute_kind = 0;
function attribute(name6, value3) {
  return new Attribute(attribute_kind, name6, value3);
}
var property_kind = 1;
function property(name6, value3) {
  return new Property(property_kind, name6, value3);
}
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
function attribute2(name6, value3) {
  return attribute(name6, value3);
}
function property2(name6, value3) {
  return property(name6, value3);
}
function class$(name6) {
  return attribute2("class", name6);
}
function do_classes(loop$names, loop$class) {
  while (true) {
    let names = loop$names;
    let class$2 = loop$class;
    if (names instanceof Empty) {
      return class$2;
    } else {
      let $ = names.head[1];
      if ($) {
        let rest = names.tail;
        let name$1 = names.head[0];
        return class$2 + name$1 + " " + do_classes(rest, class$2);
      } else {
        let rest = names.tail;
        loop$names = rest;
        loop$class = class$2;
      }
    }
  }
}
function classes(names) {
  return class$(do_classes(names, ""));
}
function style(property3, value3) {
  if (property3 === "") {
    return class$("");
  } else if (value3 === "") {
    return class$("");
  } else {
    return attribute2("style", property3 + ":" + value3 + ";");
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
function title(text4) {
  return attribute2("title", text4);
}
function href(url) {
  return attribute2("href", url);
}
function alt(text4) {
  return attribute2("alt", text4);
}
function src(url) {
  return attribute2("src", url);
}
function autocomplete(value3) {
  return attribute2("autocomplete", value3);
}
function name(element_name) {
  return attribute2("name", element_name);
}
function placeholder(text4) {
  return attribute2("placeholder", text4);
}
function type_(control_type) {
  return attribute2("type", control_type);
}
function value(control_value) {
  return attribute2("value", control_value);
}
function role(name6) {
  return attribute2("role", name6);
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
    let dispatch2 = actions.dispatch;
    return effect(dispatch2);
  };
  let _record = empty;
  return new Effect(toList([task]), _record.before_paint, _record.after_paint);
}
function before_paint(effect) {
  let task = (actions) => {
    let root3 = actions.root();
    let dispatch2 = actions.dispatch;
    return effect(dispatch2, root3);
  };
  let _record = empty;
  return new Effect(_record.synchronous, toList([task]), _record.after_paint);
}
function after_paint(effect) {
  let task = (actions) => {
    let root3 = actions.root();
    let dispatch2 = actions.dispatch;
    return effect(dispatch2, root3);
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
  return fold(
    effects,
    empty,
    (acc, eff) => {
      return new Effect(
        fold(eff.synchronous, acc.synchronous, prepend2),
        fold(eff.before_paint, acc.before_paint, prepend2),
        fold(eff.after_paint, acc.after_paint, prepend2)
      );
    }
  );
}

// build/dev/javascript/lustre/lustre/internals/mutable_map.ffi.mjs
function empty2() {
  return null;
}
function get(map6, key) {
  const value3 = map6?.get(key);
  if (value3 != null) {
    return new Ok(value3);
  } else {
    return new Error(void 0);
  }
}
function insert3(map6, key, value3) {
  map6 ??= /* @__PURE__ */ new Map();
  map6.set(key, value3);
  return map6;
}
function remove(map6, key) {
  map6?.delete(key);
  return map6;
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
  constructor(index5, parent) {
    super();
    this.index = index5;
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
function add3(parent, index5, key) {
  if (key === "") {
    return new Index(index5, parent);
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
      let index5 = path2.index;
      let parent = path2.parent;
      loop$path = parent;
      loop$acc = prepend(
        separator_element,
        prepend(to_string(index5), acc)
      );
    }
  }
}
function to_string4(path2) {
  return do_to_string(path2, toList([]));
}
function matches(path2, candidates) {
  if (candidates instanceof Empty) {
    return false;
  } else {
    return do_matches(to_string4(path2), candidates);
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
  constructor(kind, key, mapper, content3) {
    super();
    this.kind = kind;
    this.key = key;
    this.mapper = mapper;
    this.content = content3;
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
function text(key, mapper, content3) {
  return new Text(text_kind, key, mapper, content3);
}
var unsafe_inner_html_kind = 3;
function unsafe_inner_html(key, mapper, namespace2, tag, attributes, inner_html) {
  return new UnsafeInnerHtml(
    unsafe_inner_html_kind,
    key,
    mapper,
    namespace2,
    tag,
    prepare(attributes),
    inner_html
  );
}
function set_fragment_key(loop$key, loop$children, loop$index, loop$new_children, loop$keyed_children) {
  while (true) {
    let key = loop$key;
    let children = loop$children;
    let index5 = loop$index;
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
          let child_key = key + "::" + to_string(index5);
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
          let index$1 = index5 + 1;
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
            let index$1 = index5 + 1;
            loop$key = key;
            loop$children = children$1;
            loop$index = index$1;
            loop$new_children = new_children$1;
            loop$keyed_children = keyed_children$1;
          } else {
            let node$2 = $;
            let children$1 = children.tail;
            let new_children$1 = prepend(node$2, new_children);
            let index$1 = index5 + 1;
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
          let index$1 = index5 + 1;
          loop$key = key;
          loop$children = children$1;
          loop$index = index$1;
          loop$new_children = new_children$1;
          loop$keyed_children = keyed_children$1;
        } else {
          let node$1 = $;
          let children$1 = children.tail;
          let new_children$1 = prepend(node$1, new_children);
          let index$1 = index5 + 1;
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
var isReferenceEqual = (a2, b) => a2 === b;
var isEqual2 = (a2, b) => {
  if (a2 === b) {
    return true;
  }
  if (a2 == null || b == null) {
    return false;
  }
  const type = typeof a2;
  if (type !== typeof b) {
    return false;
  }
  if (type !== "object") {
    return false;
  }
  const ctor = a2.constructor;
  if (ctor !== b.constructor) {
    return false;
  }
  if (Array.isArray(a2)) {
    return areArraysEqual(a2, b);
  }
  return areObjectsEqual(a2, b);
};
var areArraysEqual = (a2, b) => {
  let index5 = a2.length;
  if (index5 !== b.length) {
    return false;
  }
  while (index5--) {
    if (!isEqual2(a2[index5], b[index5])) {
      return false;
    }
  }
  return true;
};
var areObjectsEqual = (a2, b) => {
  const properties = Object.keys(a2);
  let index5 = properties.length;
  if (Object.keys(b).length !== index5) {
    return false;
  }
  while (index5--) {
    const property3 = properties[index5];
    if (!Object.hasOwn(b, property3)) {
      return false;
    }
    if (!isEqual2(a2[property3], b[property3])) {
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
  return fold(
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
          identity2(mapper)(handler2.message)
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
  return fold(
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
  let $ = isReferenceEqual(mapper, identity2);
  let $1 = isReferenceEqual(child_mapper, identity2);
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
function add_child(events, mapper, parent, index5, child2) {
  let handlers = do_add_child(events.handlers, mapper, parent, index5, child2);
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
    identity2,
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
    identity2,
    namespace2,
    tag,
    attributes,
    children,
    empty2(),
    false,
    false
  );
}
function text2(content3) {
  return text("", identity2, content3);
}
function none2() {
  return text("", identity2, "");
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
    identity2,
    children,
    empty2(),
    count_fragment_children(children, 0)
  );
}
function unsafe_raw_html(namespace2, tag, attributes, inner_html) {
  return unsafe_inner_html(
    "",
    identity2,
    namespace2,
    tag,
    attributes,
    inner_html
  );
}

// build/dev/javascript/lustre/lustre/element/html.mjs
function text3(content3) {
  return text2(content3);
}
function style2(attrs, css2) {
  return unsafe_raw_html("", "style", attrs, css2);
}
function article(attrs, children) {
  return element2("article", attrs, children);
}
function aside(attrs, children) {
  return element2("aside", attrs, children);
}
function footer(attrs, children) {
  return element2("footer", attrs, children);
}
function header(attrs, children) {
  return element2("header", attrs, children);
}
function h1(attrs, children) {
  return element2("h1", attrs, children);
}
function h2(attrs, children) {
  return element2("h2", attrs, children);
}
function main(attrs, children) {
  return element2("main", attrs, children);
}
function nav(attrs, children) {
  return element2("nav", attrs, children);
}
function section(attrs, children) {
  return element2("section", attrs, children);
}
function div(attrs, children) {
  return element2("div", attrs, children);
}
function hr(attrs) {
  return element2("hr", attrs, empty_list);
}
function li(attrs, children) {
  return element2("li", attrs, children);
}
function ol(attrs, children) {
  return element2("ol", attrs, children);
}
function p(attrs, children) {
  return element2("p", attrs, children);
}
function ul(attrs, children) {
  return element2("ul", attrs, children);
}
function a(attrs, children) {
  return element2("a", attrs, children);
}
function small(attrs, children) {
  return element2("small", attrs, children);
}
function span(attrs, children) {
  return element2("span", attrs, children);
}
function img(attrs) {
  return element2("img", attrs, empty_list);
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
function label(attrs, children) {
  return element2("label", attrs, children);
}
function slot(attrs, fallback) {
  return element2("slot", attrs, fallback);
}

// build/dev/javascript/lustre/lustre/vdom/patch.mjs
var Patch = class extends CustomType {
  constructor(index5, removed, changes, children) {
    super();
    this.index = index5;
    this.removed = removed;
    this.changes = changes;
    this.children = children;
  }
};
var ReplaceText = class extends CustomType {
  constructor(kind, content3) {
    super();
    this.kind = kind;
    this.content = content3;
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
function new$5(index5, removed, changes, children) {
  return new Patch(index5, removed, changes, children);
}
var replace_text_kind = 0;
function replace_text(content3) {
  return new ReplaceText(replace_text_kind, content3);
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
    identity2,
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
  constructor(root3, dispatch2, { useServerEvents = false, exposeKeys = false } = {}) {
    this.#root = root3;
    this.#dispatch = dispatch2;
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
        const index5 = child2.index | 0;
        const next2 = lastChild && lastIndex - index5 === 1 ? lastChild.previousSibling : childAt(node, index5);
        self.#stack.push({ node: next2, patch: child2 });
        lastChild = next2;
        lastIndex = index5;
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
  #replaceText(node, content3) {
    node.data = content3 ?? "";
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
  #createChild(parent, index5, vnode) {
    switch (vnode.kind) {
      case element_kind: {
        const node = createChildElement(parent, index5, vnode);
        this.#createAttributes(node, vnode);
        this.#insert(node, vnode.children);
        return node;
      }
      case text_kind: {
        return createChildText(parent, index5, vnode);
      }
      case fragment_kind: {
        const node = createDocumentFragment();
        const head = createChildText(parent, index5, vnode);
        appendChild(node, head);
        let childIndex = index5 + 1;
        iterate(vnode.children, (child2) => {
          appendChild(node, this.#createChild(parent, childIndex, child2));
          childIndex += advance(child2);
        });
        return node;
      }
      case unsafe_inner_html_kind: {
        const node = createChildElement(parent, index5, vnode);
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
      value: value3,
      prevent_default: prevent,
      stop_propagation: stop,
      immediate: immediate2,
      include,
      debounce: debounceDelay,
      throttle: throttleDelay
    } = attribute5;
    switch (kind) {
      case attribute_kind: {
        const valueOrDefault = value3 ?? "";
        if (name6 === "virtual:defaultValue") {
          node.defaultValue = valueOrDefault;
          return;
        }
        if (valueOrDefault !== node.getAttribute(name6)) {
          node.setAttribute(name6, valueOrDefault);
        }
        SYNCED_ATTRIBUTES[name6]?.added?.(node, value3);
        break;
      }
      case property_kind:
        node[name6] = value3;
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
          if (prevent.kind === always_kind) event4.preventDefault();
          if (stop.kind === always_kind) event4.stopPropagation();
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
              if (event4 === throttles.get(type)?.lastEvent) return;
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
var createChildElement = (parent, index5, { key, tag, namespace: namespace2 }) => {
  const node = document2().createElementNS(namespace2 || NAMESPACE_HTML, tag);
  initialiseMetadata(parent, node, index5, key);
  return node;
};
var createChildText = (parent, index5, { key, content: content3 }) => {
  const node = document2().createTextNode(content3 ?? "");
  initialiseMetadata(parent, node, index5, key);
  return node;
};
var createDocumentFragment = () => document2().createDocumentFragment();
var childAt = (node, at) => node.childNodes[at | 0];
var meta = Symbol("lustre");
var initialiseMetadata = (parent, node, index5 = 0, key = "") => {
  const segment = `${key || index5}`;
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
    for (let i = 0, input3 = event4, output = data; i < path2.length; i++) {
      if (i === path2.length - 1) {
        output[path2[i]] = input3[path2[i]];
        break;
      }
      output = output[path2[i]] ??= {};
      input3 = input3[path2[i]];
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
    added(node, value3) {
      node[name6] = value3;
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
    const empty4 = emptyTextNode(root3);
    root3.appendChild(empty4);
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
var virtualiseNode = (parent, node, index5) => {
  switch (node.nodeType) {
    case ELEMENT_NODE: {
      const key = node.getAttribute("data-lustre-key");
      initialiseMetadata(parent, node, index5, key);
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
      initialiseMetadata(parent, node, index5);
      return node.data ? text2(node.data) : null;
    case DOCUMENT_FRAGMENT_NODE:
      initialiseMetadata(parent, node, index5);
      return node.childNodes.length > 0 ? fragment2(virtualiseChildNodes(node)) : null;
    default:
      return null;
  }
};
var INPUT_ELEMENTS = ["input", "select", "textarea"];
var virtualiseInputEvents = (tag, node) => {
  const value3 = node.value;
  const checked2 = node.checked;
  if (tag === "input" && node.type === "checkbox" && !checked2) return;
  if (tag === "input" && node.type === "radio" && !checked2) return;
  if (node.type !== "checkbox" && node.type !== "radio" && !value3) return;
  queueMicrotask(() => {
    node.value = value3;
    node.checked = checked2;
    node.dispatchEvent(new Event("input", { bubbles: true }));
    node.dispatchEvent(new Event("change", { bubbles: true }));
    if (document2().activeElement !== node) {
      node.dispatchEvent(new Event("blur", { bubbles: true }));
    }
  });
};
var virtualiseChildNodes = (node) => {
  let children = null;
  let index5 = 0;
  let child2 = node.firstChild;
  let ptr = null;
  while (child2) {
    const vnode = virtualiseNode(node, child2, index5);
    const next2 = child2.nextSibling;
    if (vnode) {
      const list_node = new NonEmpty(vnode, null);
      if (ptr) {
        ptr = ptr.tail = list_node;
      } else {
        ptr = children = list_node;
      }
      index5 += 1;
    } else {
      node.removeChild(child2);
    }
    child2 = next2;
  }
  if (!ptr) return empty_list;
  ptr.tail = empty_list;
  return children;
};
var virtualiseAttributes = (node) => {
  let index5 = node.attributes.length;
  let attributes = empty_list;
  while (index5-- > 0) {
    attributes = new NonEmpty(
      virtualiseAttribute(node.attributes[index5]),
      attributes
    );
  }
  return attributes;
};
var virtualiseAttribute = (attr) => {
  const name6 = attr.localName;
  const value3 = attr.value;
  return attribute2(name6, value3);
};

// build/dev/javascript/lustre/lustre/runtime/client/runtime.ffi.mjs
var is_browser = () => !!document2();
var is_registered = (name6) => is_browser() && customElements.get(name6);
var Runtime = class {
  constructor(root3, [model, effects], view8, update7) {
    this.root = root3;
    this.#model = model;
    this.#view = view8;
    this.#update = update7;
    this.#reconciler = new Reconciler(this.root, (event4, path2, name6) => {
      const [events, result] = handle(this.#events, path2, name6, event4);
      this.#events = events;
      if (result.isOk()) {
        const handler = result[0];
        if (handler.stop_propagation) event4.stopPropagation();
        if (handler.prevent_default) event4.preventDefault();
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
      if (!this.#queue.length) break;
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
var send = (runtime, message2) => {
  runtime.send(message2);
};
function makeEffect(synchronous) {
  return {
    synchronous,
    after_paint: empty_list,
    before_paint: empty_list
  };
}
function listAppend(a2, b) {
  if (a2 instanceof Empty) {
    return b;
  } else if (b instanceof Empty) {
    return a2;
  } else {
    return append(a2, b);
  }
}
var copiedStyleSheets = /* @__PURE__ */ new WeakMap();
async function adoptStylesheets(shadowRoot) {
  const pendingParentStylesheets = [];
  for (const node of document2().querySelectorAll(
    "link[rel=stylesheet], style"
  )) {
    if (node.sheet) continue;
    pendingParentStylesheets.push(
      new Promise((resolve2, reject2) => {
        node.addEventListener("load", resolve2);
        node.addEventListener("error", reject2);
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
  constructor(message2) {
    super();
    this.message = message2;
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
var make_component = ({ init: init8, update: update7, view: view8, config }, name6) => {
  if (!is_browser()) return new Error(new NotABrowser());
  if (!name6.includes("-")) return new Error(new BadComponentName(name6));
  if (customElements.get(name6)) {
    return new Error(new ComponentAlreadyRegistered(name6));
  }
  const [model, effects] = init8(void 0);
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
        view8,
        update7
      );
    }
    adoptedCallback() {
      if (config.adopt_styles) {
        this.#adoptStyleSheets();
      }
    }
    attributeChangedCallback(name7, _, value3) {
      const decoded = config.attributes.get(name7)(value3);
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
    send(message2) {
      switch (message2.constructor) {
        case EffectDispatchedMessage: {
          this.dispatch(message2.message, false);
          break;
        }
        case EffectEmitEvent: {
          this.emit(message2.name, message2.data);
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
  config.properties.forEach((decoder2, name7) => {
    Object.defineProperty(component2.prototype, name7, {
      get() {
        return this[`_${name7}`];
      },
      set(value3) {
        this[`_${name7}`] = value3;
        const decoded = run(value3, decoder2);
        if (decoded.constructor === Ok) {
          this.dispatch(decoded[0]);
        }
      }
    });
  });
  customElements.define(name6, component2);
  return new Ok(void 0);
};
var set_pseudo_state = (root3, value3) => {
  if (!is_browser()) return;
  if (root3 instanceof ShadowRoot) {
    root3.host.internals.states.add(value3);
  }
};
var remove_pseudo_state = (root3, value3) => {
  if (!is_browser()) return;
  if (root3 instanceof ShadowRoot) {
    root3.host.internals.states.delete(value3);
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
  let init8 = new Config2(
    false,
    true,
    empty_dict(),
    empty_dict(),
    false,
    option_none,
    option_none,
    option_none
  );
  return fold(
    options,
    init8,
    (config, option3) => {
      return option3.apply(config);
    }
  );
}
function on_attribute_change(name6, decoder2) {
  return new Option(
    (config) => {
      let attributes = insert(config.attributes, name6, decoder2);
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
function on_property_change(name6, decoder2) {
  return new Option(
    (config) => {
      let properties = insert(config.properties, name6, decoder2);
      let _record = config;
      return new Config2(
        _record.open_shadow_root,
        _record.adopt_styles,
        _record.attributes,
        properties,
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
function set_pseudo_state2(value3) {
  return before_paint(
    (_, root3) => {
      return set_pseudo_state(root3, value3);
    }
  );
}
function remove_pseudo_state2(value3) {
  return before_paint(
    (_, root3) => {
      return remove_pseudo_state(root3, value3);
    }
  );
}

// build/dev/javascript/lustre/lustre/runtime/client/spa.ffi.mjs
var Spa = class _Spa {
  static start({ init: init8, update: update7, view: view8 }, selector, flags) {
    if (!is_browser()) return new Error(new NotABrowser());
    const root3 = selector instanceof HTMLElement ? selector : document2().querySelector(selector);
    if (!root3) return new Error(new ElementNotFound(selector));
    return new Ok(new _Spa(root3, init8(flags), update7, view8));
  }
  #runtime;
  constructor(root3, [init8, effects], update7, view8) {
    this.#runtime = new Runtime(root3, [init8, effects], view8, update7);
  }
  send(message2) {
    switch (message2.constructor) {
      case EffectDispatchedMessage: {
        this.dispatch(message2.message, false);
        break;
      }
      case EffectEmitEvent: {
        this.emit(message2.name, message2.data);
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
  constructor(init8, update7, view8, config) {
    super();
    this.init = init8;
    this.update = update7;
    this.view = view8;
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
function component(init8, update7, view8, options) {
  return new App(init8, update7, view8, new$6(options));
}
function application(init8, update7, view8) {
  return new App(init8, update7, view8, new$6(empty_list));
}
function dispatch(msg) {
  return new EffectDispatchedMessage(msg);
}
function start3(app, selector, start_args) {
  return guard(
    !is_browser(),
    new Error(new NotABrowser()),
    () => {
      return start(app, selector, start_args);
    }
  );
}

// build/dev/javascript/gleam_stdlib/gleam/pair.mjs
function first2(pair) {
  let a2 = pair[0];
  return a2;
}
function second(pair) {
  let a2 = pair[1];
  return a2;
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
function on_click(msg) {
  return on("click", success(msg));
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
      (value3) => {
        return success(msg(value3));
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

// build/dev/javascript/gleam_stdlib/gleam/uri.mjs
var Uri = class extends CustomType {
  constructor(scheme, userinfo, host, port, path2, query, fragment4) {
    super();
    this.scheme = scheme;
    this.userinfo = userinfo;
    this.host = host;
    this.port = port;
    this.path = path2;
    this.query = query;
    this.fragment = fragment4;
  }
};
function is_valid_host_within_brackets_char(char) {
  return 48 >= char && char <= 57 || 65 >= char && char <= 90 || 97 >= char && char <= 122 || char === 58 || char === 46;
}
function parse_fragment(rest, pieces) {
  return new Ok(
    (() => {
      let _record = pieces;
      return new Uri(
        _record.scheme,
        _record.userinfo,
        _record.host,
        _record.port,
        _record.path,
        _record.query,
        new Some(rest)
      );
    })()
  );
}
function parse_query_with_question_mark_loop(loop$original, loop$uri_string, loop$pieces, loop$size) {
  while (true) {
    let original = loop$original;
    let uri_string = loop$uri_string;
    let pieces = loop$pieces;
    let size3 = loop$size;
    if (uri_string.startsWith("#")) {
      if (size3 === 0) {
        let rest = uri_string.slice(1);
        return parse_fragment(rest, pieces);
      } else {
        let rest = uri_string.slice(1);
        let query = string_codeunit_slice(original, 0, size3);
        let _block;
        let _record = pieces;
        _block = new Uri(
          _record.scheme,
          _record.userinfo,
          _record.host,
          _record.port,
          _record.path,
          new Some(query),
          _record.fragment
        );
        let pieces$1 = _block;
        return parse_fragment(rest, pieces$1);
      }
    } else if (uri_string === "") {
      return new Ok(
        (() => {
          let _record = pieces;
          return new Uri(
            _record.scheme,
            _record.userinfo,
            _record.host,
            _record.port,
            _record.path,
            new Some(original),
            _record.fragment
          );
        })()
      );
    } else {
      let $ = pop_codeunit(uri_string);
      let rest = $[1];
      loop$original = original;
      loop$uri_string = rest;
      loop$pieces = pieces;
      loop$size = size3 + 1;
    }
  }
}
function parse_query_with_question_mark(uri_string, pieces) {
  return parse_query_with_question_mark_loop(uri_string, uri_string, pieces, 0);
}
function parse_path_loop(loop$original, loop$uri_string, loop$pieces, loop$size) {
  while (true) {
    let original = loop$original;
    let uri_string = loop$uri_string;
    let pieces = loop$pieces;
    let size3 = loop$size;
    if (uri_string.startsWith("?")) {
      let rest = uri_string.slice(1);
      let path2 = string_codeunit_slice(original, 0, size3);
      let _block;
      let _record = pieces;
      _block = new Uri(
        _record.scheme,
        _record.userinfo,
        _record.host,
        _record.port,
        path2,
        _record.query,
        _record.fragment
      );
      let pieces$1 = _block;
      return parse_query_with_question_mark(rest, pieces$1);
    } else if (uri_string.startsWith("#")) {
      let rest = uri_string.slice(1);
      let path2 = string_codeunit_slice(original, 0, size3);
      let _block;
      let _record = pieces;
      _block = new Uri(
        _record.scheme,
        _record.userinfo,
        _record.host,
        _record.port,
        path2,
        _record.query,
        _record.fragment
      );
      let pieces$1 = _block;
      return parse_fragment(rest, pieces$1);
    } else if (uri_string === "") {
      return new Ok(
        (() => {
          let _record = pieces;
          return new Uri(
            _record.scheme,
            _record.userinfo,
            _record.host,
            _record.port,
            original,
            _record.query,
            _record.fragment
          );
        })()
      );
    } else {
      let $ = pop_codeunit(uri_string);
      let rest = $[1];
      loop$original = original;
      loop$uri_string = rest;
      loop$pieces = pieces;
      loop$size = size3 + 1;
    }
  }
}
function parse_path(uri_string, pieces) {
  return parse_path_loop(uri_string, uri_string, pieces, 0);
}
function parse_port_loop(loop$uri_string, loop$pieces, loop$port) {
  while (true) {
    let uri_string = loop$uri_string;
    let pieces = loop$pieces;
    let port = loop$port;
    if (uri_string.startsWith("0")) {
      let rest = uri_string.slice(1);
      loop$uri_string = rest;
      loop$pieces = pieces;
      loop$port = port * 10;
    } else if (uri_string.startsWith("1")) {
      let rest = uri_string.slice(1);
      loop$uri_string = rest;
      loop$pieces = pieces;
      loop$port = port * 10 + 1;
    } else if (uri_string.startsWith("2")) {
      let rest = uri_string.slice(1);
      loop$uri_string = rest;
      loop$pieces = pieces;
      loop$port = port * 10 + 2;
    } else if (uri_string.startsWith("3")) {
      let rest = uri_string.slice(1);
      loop$uri_string = rest;
      loop$pieces = pieces;
      loop$port = port * 10 + 3;
    } else if (uri_string.startsWith("4")) {
      let rest = uri_string.slice(1);
      loop$uri_string = rest;
      loop$pieces = pieces;
      loop$port = port * 10 + 4;
    } else if (uri_string.startsWith("5")) {
      let rest = uri_string.slice(1);
      loop$uri_string = rest;
      loop$pieces = pieces;
      loop$port = port * 10 + 5;
    } else if (uri_string.startsWith("6")) {
      let rest = uri_string.slice(1);
      loop$uri_string = rest;
      loop$pieces = pieces;
      loop$port = port * 10 + 6;
    } else if (uri_string.startsWith("7")) {
      let rest = uri_string.slice(1);
      loop$uri_string = rest;
      loop$pieces = pieces;
      loop$port = port * 10 + 7;
    } else if (uri_string.startsWith("8")) {
      let rest = uri_string.slice(1);
      loop$uri_string = rest;
      loop$pieces = pieces;
      loop$port = port * 10 + 8;
    } else if (uri_string.startsWith("9")) {
      let rest = uri_string.slice(1);
      loop$uri_string = rest;
      loop$pieces = pieces;
      loop$port = port * 10 + 9;
    } else if (uri_string.startsWith("?")) {
      let rest = uri_string.slice(1);
      let _block;
      let _record = pieces;
      _block = new Uri(
        _record.scheme,
        _record.userinfo,
        _record.host,
        new Some(port),
        _record.path,
        _record.query,
        _record.fragment
      );
      let pieces$1 = _block;
      return parse_query_with_question_mark(rest, pieces$1);
    } else if (uri_string.startsWith("#")) {
      let rest = uri_string.slice(1);
      let _block;
      let _record = pieces;
      _block = new Uri(
        _record.scheme,
        _record.userinfo,
        _record.host,
        new Some(port),
        _record.path,
        _record.query,
        _record.fragment
      );
      let pieces$1 = _block;
      return parse_fragment(rest, pieces$1);
    } else if (uri_string.startsWith("/")) {
      let _block;
      let _record = pieces;
      _block = new Uri(
        _record.scheme,
        _record.userinfo,
        _record.host,
        new Some(port),
        _record.path,
        _record.query,
        _record.fragment
      );
      let pieces$1 = _block;
      return parse_path(uri_string, pieces$1);
    } else if (uri_string === "") {
      return new Ok(
        (() => {
          let _record = pieces;
          return new Uri(
            _record.scheme,
            _record.userinfo,
            _record.host,
            new Some(port),
            _record.path,
            _record.query,
            _record.fragment
          );
        })()
      );
    } else {
      return new Error(void 0);
    }
  }
}
function parse_port(uri_string, pieces) {
  if (uri_string.startsWith(":0")) {
    let rest = uri_string.slice(2);
    return parse_port_loop(rest, pieces, 0);
  } else if (uri_string.startsWith(":1")) {
    let rest = uri_string.slice(2);
    return parse_port_loop(rest, pieces, 1);
  } else if (uri_string.startsWith(":2")) {
    let rest = uri_string.slice(2);
    return parse_port_loop(rest, pieces, 2);
  } else if (uri_string.startsWith(":3")) {
    let rest = uri_string.slice(2);
    return parse_port_loop(rest, pieces, 3);
  } else if (uri_string.startsWith(":4")) {
    let rest = uri_string.slice(2);
    return parse_port_loop(rest, pieces, 4);
  } else if (uri_string.startsWith(":5")) {
    let rest = uri_string.slice(2);
    return parse_port_loop(rest, pieces, 5);
  } else if (uri_string.startsWith(":6")) {
    let rest = uri_string.slice(2);
    return parse_port_loop(rest, pieces, 6);
  } else if (uri_string.startsWith(":7")) {
    let rest = uri_string.slice(2);
    return parse_port_loop(rest, pieces, 7);
  } else if (uri_string.startsWith(":8")) {
    let rest = uri_string.slice(2);
    return parse_port_loop(rest, pieces, 8);
  } else if (uri_string.startsWith(":9")) {
    let rest = uri_string.slice(2);
    return parse_port_loop(rest, pieces, 9);
  } else if (uri_string.startsWith(":")) {
    return new Error(void 0);
  } else if (uri_string.startsWith("?")) {
    let rest = uri_string.slice(1);
    return parse_query_with_question_mark(rest, pieces);
  } else if (uri_string.startsWith("#")) {
    let rest = uri_string.slice(1);
    return parse_fragment(rest, pieces);
  } else if (uri_string.startsWith("/")) {
    return parse_path(uri_string, pieces);
  } else if (uri_string === "") {
    return new Ok(pieces);
  } else {
    return new Error(void 0);
  }
}
function parse_host_outside_of_brackets_loop(loop$original, loop$uri_string, loop$pieces, loop$size) {
  while (true) {
    let original = loop$original;
    let uri_string = loop$uri_string;
    let pieces = loop$pieces;
    let size3 = loop$size;
    if (uri_string === "") {
      return new Ok(
        (() => {
          let _record = pieces;
          return new Uri(
            _record.scheme,
            _record.userinfo,
            new Some(original),
            _record.port,
            _record.path,
            _record.query,
            _record.fragment
          );
        })()
      );
    } else if (uri_string.startsWith(":")) {
      let host = string_codeunit_slice(original, 0, size3);
      let _block;
      let _record = pieces;
      _block = new Uri(
        _record.scheme,
        _record.userinfo,
        new Some(host),
        _record.port,
        _record.path,
        _record.query,
        _record.fragment
      );
      let pieces$1 = _block;
      return parse_port(uri_string, pieces$1);
    } else if (uri_string.startsWith("/")) {
      let host = string_codeunit_slice(original, 0, size3);
      let _block;
      let _record = pieces;
      _block = new Uri(
        _record.scheme,
        _record.userinfo,
        new Some(host),
        _record.port,
        _record.path,
        _record.query,
        _record.fragment
      );
      let pieces$1 = _block;
      return parse_path(uri_string, pieces$1);
    } else if (uri_string.startsWith("?")) {
      let rest = uri_string.slice(1);
      let host = string_codeunit_slice(original, 0, size3);
      let _block;
      let _record = pieces;
      _block = new Uri(
        _record.scheme,
        _record.userinfo,
        new Some(host),
        _record.port,
        _record.path,
        _record.query,
        _record.fragment
      );
      let pieces$1 = _block;
      return parse_query_with_question_mark(rest, pieces$1);
    } else if (uri_string.startsWith("#")) {
      let rest = uri_string.slice(1);
      let host = string_codeunit_slice(original, 0, size3);
      let _block;
      let _record = pieces;
      _block = new Uri(
        _record.scheme,
        _record.userinfo,
        new Some(host),
        _record.port,
        _record.path,
        _record.query,
        _record.fragment
      );
      let pieces$1 = _block;
      return parse_fragment(rest, pieces$1);
    } else {
      let $ = pop_codeunit(uri_string);
      let rest = $[1];
      loop$original = original;
      loop$uri_string = rest;
      loop$pieces = pieces;
      loop$size = size3 + 1;
    }
  }
}
function parse_host_within_brackets_loop(loop$original, loop$uri_string, loop$pieces, loop$size) {
  while (true) {
    let original = loop$original;
    let uri_string = loop$uri_string;
    let pieces = loop$pieces;
    let size3 = loop$size;
    if (uri_string === "") {
      return new Ok(
        (() => {
          let _record = pieces;
          return new Uri(
            _record.scheme,
            _record.userinfo,
            new Some(uri_string),
            _record.port,
            _record.path,
            _record.query,
            _record.fragment
          );
        })()
      );
    } else if (uri_string.startsWith("]")) {
      if (size3 === 0) {
        let rest = uri_string.slice(1);
        return parse_port(rest, pieces);
      } else {
        let rest = uri_string.slice(1);
        let host = string_codeunit_slice(original, 0, size3 + 1);
        let _block;
        let _record = pieces;
        _block = new Uri(
          _record.scheme,
          _record.userinfo,
          new Some(host),
          _record.port,
          _record.path,
          _record.query,
          _record.fragment
        );
        let pieces$1 = _block;
        return parse_port(rest, pieces$1);
      }
    } else if (uri_string.startsWith("/")) {
      if (size3 === 0) {
        return parse_path(uri_string, pieces);
      } else {
        let host = string_codeunit_slice(original, 0, size3);
        let _block;
        let _record = pieces;
        _block = new Uri(
          _record.scheme,
          _record.userinfo,
          new Some(host),
          _record.port,
          _record.path,
          _record.query,
          _record.fragment
        );
        let pieces$1 = _block;
        return parse_path(uri_string, pieces$1);
      }
    } else if (uri_string.startsWith("?")) {
      if (size3 === 0) {
        let rest = uri_string.slice(1);
        return parse_query_with_question_mark(rest, pieces);
      } else {
        let rest = uri_string.slice(1);
        let host = string_codeunit_slice(original, 0, size3);
        let _block;
        let _record = pieces;
        _block = new Uri(
          _record.scheme,
          _record.userinfo,
          new Some(host),
          _record.port,
          _record.path,
          _record.query,
          _record.fragment
        );
        let pieces$1 = _block;
        return parse_query_with_question_mark(rest, pieces$1);
      }
    } else if (uri_string.startsWith("#")) {
      if (size3 === 0) {
        let rest = uri_string.slice(1);
        return parse_fragment(rest, pieces);
      } else {
        let rest = uri_string.slice(1);
        let host = string_codeunit_slice(original, 0, size3);
        let _block;
        let _record = pieces;
        _block = new Uri(
          _record.scheme,
          _record.userinfo,
          new Some(host),
          _record.port,
          _record.path,
          _record.query,
          _record.fragment
        );
        let pieces$1 = _block;
        return parse_fragment(rest, pieces$1);
      }
    } else {
      let $ = pop_codeunit(uri_string);
      let char = $[0];
      let rest = $[1];
      let $1 = is_valid_host_within_brackets_char(char);
      if ($1) {
        loop$original = original;
        loop$uri_string = rest;
        loop$pieces = pieces;
        loop$size = size3 + 1;
      } else {
        return parse_host_outside_of_brackets_loop(
          original,
          original,
          pieces,
          0
        );
      }
    }
  }
}
function parse_host_within_brackets(uri_string, pieces) {
  return parse_host_within_brackets_loop(uri_string, uri_string, pieces, 0);
}
function parse_host_outside_of_brackets(uri_string, pieces) {
  return parse_host_outside_of_brackets_loop(uri_string, uri_string, pieces, 0);
}
function parse_host(uri_string, pieces) {
  if (uri_string.startsWith("[")) {
    return parse_host_within_brackets(uri_string, pieces);
  } else if (uri_string.startsWith(":")) {
    let _block;
    let _record = pieces;
    _block = new Uri(
      _record.scheme,
      _record.userinfo,
      new Some(""),
      _record.port,
      _record.path,
      _record.query,
      _record.fragment
    );
    let pieces$1 = _block;
    return parse_port(uri_string, pieces$1);
  } else if (uri_string === "") {
    return new Ok(
      (() => {
        let _record = pieces;
        return new Uri(
          _record.scheme,
          _record.userinfo,
          new Some(""),
          _record.port,
          _record.path,
          _record.query,
          _record.fragment
        );
      })()
    );
  } else {
    return parse_host_outside_of_brackets(uri_string, pieces);
  }
}
function parse_userinfo_loop(loop$original, loop$uri_string, loop$pieces, loop$size) {
  while (true) {
    let original = loop$original;
    let uri_string = loop$uri_string;
    let pieces = loop$pieces;
    let size3 = loop$size;
    if (uri_string.startsWith("@")) {
      if (size3 === 0) {
        let rest = uri_string.slice(1);
        return parse_host(rest, pieces);
      } else {
        let rest = uri_string.slice(1);
        let userinfo = string_codeunit_slice(original, 0, size3);
        let _block;
        let _record = pieces;
        _block = new Uri(
          _record.scheme,
          new Some(userinfo),
          _record.host,
          _record.port,
          _record.path,
          _record.query,
          _record.fragment
        );
        let pieces$1 = _block;
        return parse_host(rest, pieces$1);
      }
    } else if (uri_string === "") {
      return parse_host(original, pieces);
    } else if (uri_string.startsWith("/")) {
      return parse_host(original, pieces);
    } else if (uri_string.startsWith("?")) {
      return parse_host(original, pieces);
    } else if (uri_string.startsWith("#")) {
      return parse_host(original, pieces);
    } else {
      let $ = pop_codeunit(uri_string);
      let rest = $[1];
      loop$original = original;
      loop$uri_string = rest;
      loop$pieces = pieces;
      loop$size = size3 + 1;
    }
  }
}
function parse_authority_pieces(string5, pieces) {
  return parse_userinfo_loop(string5, string5, pieces, 0);
}
function parse_authority_with_slashes(uri_string, pieces) {
  if (uri_string === "//") {
    return new Ok(
      (() => {
        let _record = pieces;
        return new Uri(
          _record.scheme,
          _record.userinfo,
          new Some(""),
          _record.port,
          _record.path,
          _record.query,
          _record.fragment
        );
      })()
    );
  } else if (uri_string.startsWith("//")) {
    let rest = uri_string.slice(2);
    return parse_authority_pieces(rest, pieces);
  } else {
    return parse_path(uri_string, pieces);
  }
}
function parse_scheme_loop(loop$original, loop$uri_string, loop$pieces, loop$size) {
  while (true) {
    let original = loop$original;
    let uri_string = loop$uri_string;
    let pieces = loop$pieces;
    let size3 = loop$size;
    if (uri_string.startsWith("/")) {
      if (size3 === 0) {
        return parse_authority_with_slashes(uri_string, pieces);
      } else {
        let scheme = string_codeunit_slice(original, 0, size3);
        let _block;
        let _record = pieces;
        _block = new Uri(
          new Some(lowercase(scheme)),
          _record.userinfo,
          _record.host,
          _record.port,
          _record.path,
          _record.query,
          _record.fragment
        );
        let pieces$1 = _block;
        return parse_authority_with_slashes(uri_string, pieces$1);
      }
    } else if (uri_string.startsWith("?")) {
      if (size3 === 0) {
        let rest = uri_string.slice(1);
        return parse_query_with_question_mark(rest, pieces);
      } else {
        let rest = uri_string.slice(1);
        let scheme = string_codeunit_slice(original, 0, size3);
        let _block;
        let _record = pieces;
        _block = new Uri(
          new Some(lowercase(scheme)),
          _record.userinfo,
          _record.host,
          _record.port,
          _record.path,
          _record.query,
          _record.fragment
        );
        let pieces$1 = _block;
        return parse_query_with_question_mark(rest, pieces$1);
      }
    } else if (uri_string.startsWith("#")) {
      if (size3 === 0) {
        let rest = uri_string.slice(1);
        return parse_fragment(rest, pieces);
      } else {
        let rest = uri_string.slice(1);
        let scheme = string_codeunit_slice(original, 0, size3);
        let _block;
        let _record = pieces;
        _block = new Uri(
          new Some(lowercase(scheme)),
          _record.userinfo,
          _record.host,
          _record.port,
          _record.path,
          _record.query,
          _record.fragment
        );
        let pieces$1 = _block;
        return parse_fragment(rest, pieces$1);
      }
    } else if (uri_string.startsWith(":")) {
      if (size3 === 0) {
        return new Error(void 0);
      } else {
        let rest = uri_string.slice(1);
        let scheme = string_codeunit_slice(original, 0, size3);
        let _block;
        let _record = pieces;
        _block = new Uri(
          new Some(lowercase(scheme)),
          _record.userinfo,
          _record.host,
          _record.port,
          _record.path,
          _record.query,
          _record.fragment
        );
        let pieces$1 = _block;
        return parse_authority_with_slashes(rest, pieces$1);
      }
    } else if (uri_string === "") {
      return new Ok(
        (() => {
          let _record = pieces;
          return new Uri(
            _record.scheme,
            _record.userinfo,
            _record.host,
            _record.port,
            original,
            _record.query,
            _record.fragment
          );
        })()
      );
    } else {
      let $ = pop_codeunit(uri_string);
      let rest = $[1];
      loop$original = original;
      loop$uri_string = rest;
      loop$pieces = pieces;
      loop$size = size3 + 1;
    }
  }
}
function remove_dot_segments_loop(loop$input, loop$accumulator) {
  while (true) {
    let input3 = loop$input;
    let accumulator = loop$accumulator;
    if (input3 instanceof Empty) {
      return reverse(accumulator);
    } else {
      let segment = input3.head;
      let rest = input3.tail;
      let _block;
      if (segment === "") {
        let accumulator$12 = accumulator;
        _block = accumulator$12;
      } else if (segment === ".") {
        let accumulator$12 = accumulator;
        _block = accumulator$12;
      } else if (segment === "..") {
        if (accumulator instanceof Empty) {
          _block = toList([]);
        } else {
          let accumulator$12 = accumulator.tail;
          _block = accumulator$12;
        }
      } else {
        let segment$1 = segment;
        let accumulator$12 = accumulator;
        _block = prepend(segment$1, accumulator$12);
      }
      let accumulator$1 = _block;
      loop$input = rest;
      loop$accumulator = accumulator$1;
    }
  }
}
function remove_dot_segments(input3) {
  return remove_dot_segments_loop(input3, toList([]));
}
function path_segments(path2) {
  return remove_dot_segments(split2(path2, "/"));
}
function to_string6(uri) {
  let _block;
  let $ = uri.fragment;
  if ($ instanceof Some) {
    let fragment4 = $[0];
    _block = toList(["#", fragment4]);
  } else {
    _block = toList([]);
  }
  let parts = _block;
  let _block$1;
  let $1 = uri.query;
  if ($1 instanceof Some) {
    let query = $1[0];
    _block$1 = prepend("?", prepend(query, parts));
  } else {
    _block$1 = parts;
  }
  let parts$1 = _block$1;
  let parts$2 = prepend(uri.path, parts$1);
  let _block$2;
  let $2 = uri.host;
  let $3 = starts_with(uri.path, "/");
  if (!$3) {
    if ($2 instanceof Some) {
      let host = $2[0];
      if (host !== "") {
        _block$2 = prepend("/", parts$2);
      } else {
        _block$2 = parts$2;
      }
    } else {
      _block$2 = parts$2;
    }
  } else {
    _block$2 = parts$2;
  }
  let parts$3 = _block$2;
  let _block$3;
  let $4 = uri.host;
  let $5 = uri.port;
  if ($5 instanceof Some) {
    if ($4 instanceof Some) {
      let port = $5[0];
      _block$3 = prepend(":", prepend(to_string(port), parts$3));
    } else {
      _block$3 = parts$3;
    }
  } else {
    _block$3 = parts$3;
  }
  let parts$4 = _block$3;
  let _block$4;
  let $6 = uri.scheme;
  let $7 = uri.userinfo;
  let $8 = uri.host;
  if ($8 instanceof Some) {
    if ($7 instanceof Some) {
      if ($6 instanceof Some) {
        let h = $8[0];
        let u = $7[0];
        let s = $6[0];
        _block$4 = prepend(
          s,
          prepend(
            "://",
            prepend(u, prepend("@", prepend(h, parts$4)))
          )
        );
      } else {
        _block$4 = parts$4;
      }
    } else if ($6 instanceof Some) {
      let h = $8[0];
      let s = $6[0];
      _block$4 = prepend(s, prepend("://", prepend(h, parts$4)));
    } else {
      let h = $8[0];
      _block$4 = prepend("//", prepend(h, parts$4));
    }
  } else if ($7 instanceof Some) {
    if ($6 instanceof Some) {
      let s = $6[0];
      _block$4 = prepend(s, prepend(":", parts$4));
    } else {
      _block$4 = parts$4;
    }
  } else if ($6 instanceof Some) {
    let s = $6[0];
    _block$4 = prepend(s, prepend(":", parts$4));
  } else {
    _block$4 = parts$4;
  }
  let parts$5 = _block$4;
  return concat2(parts$5);
}
var empty3 = /* @__PURE__ */ new Uri(
  /* @__PURE__ */ new None(),
  /* @__PURE__ */ new None(),
  /* @__PURE__ */ new None(),
  /* @__PURE__ */ new None(),
  "",
  /* @__PURE__ */ new None(),
  /* @__PURE__ */ new None()
);
function parse2(uri_string) {
  return parse_scheme_loop(uri_string, uri_string, empty3, 0);
}

// build/dev/javascript/modem/modem.ffi.mjs
var defaults = {
  handle_external_links: false,
  handle_internal_links: true
};
var initial_location = globalThis?.window?.location?.href;
var do_initial_uri = () => {
  if (!initial_location) {
    return new Error(void 0);
  } else {
    return new Ok(uri_from_url(new URL(initial_location)));
  }
};
var do_init = (dispatch2, options = defaults) => {
  document.addEventListener("click", (event4) => {
    const a2 = find_anchor(event4.target);
    if (!a2) return;
    try {
      const url = new URL(a2.href);
      const uri = uri_from_url(url);
      const is_external = url.host !== window.location.host;
      if (!options.handle_external_links && is_external) return;
      if (!options.handle_internal_links && !is_external) return;
      event4.preventDefault();
      if (!is_external) {
        window.history.pushState({}, "", a2.href);
        window.requestAnimationFrame(() => {
          if (url.hash) {
            document.getElementById(url.hash.slice(1))?.scrollIntoView();
          }
        });
      }
      return dispatch2(uri);
    } catch {
      return;
    }
  });
  window.addEventListener("popstate", (e) => {
    e.preventDefault();
    const url = new URL(window.location.href);
    const uri = uri_from_url(url);
    window.requestAnimationFrame(() => {
      if (url.hash) {
        document.getElementById(url.hash.slice(1))?.scrollIntoView();
      }
    });
    dispatch2(uri);
  });
  window.addEventListener("modem-push", ({ detail }) => {
    dispatch2(detail);
  });
  window.addEventListener("modem-replace", ({ detail }) => {
    dispatch2(detail);
  });
};
var find_anchor = (el) => {
  if (!el || el.tagName === "BODY") {
    return null;
  } else if (el.tagName === "A") {
    return el;
  } else {
    return find_anchor(el.parentElement);
  }
};
var uri_from_url = (url) => {
  return new Uri(
    /* scheme   */
    url.protocol ? new Some(url.protocol.slice(0, -1)) : new None(),
    /* userinfo */
    new None(),
    /* host     */
    url.hostname ? new Some(url.hostname) : new None(),
    /* port     */
    url.port ? new Some(Number(url.port)) : new None(),
    /* path     */
    url.pathname,
    /* query    */
    url.search ? new Some(url.search.slice(1)) : new None(),
    /* fragment */
    url.hash ? new Some(url.hash.slice(1)) : new None()
  );
};

// build/dev/javascript/modem/modem.mjs
function init(handler) {
  return from(
    (dispatch2) => {
      return guard(
        !is_browser(),
        void 0,
        () => {
          return do_init(
            (uri) => {
              let _pipe = uri;
              let _pipe$1 = handler(_pipe);
              return dispatch2(_pipe$1);
            }
          );
        }
      );
    }
  );
}

// build/dev/javascript/gleam_regexp/gleam_regexp_ffi.mjs
function compile(pattern, options) {
  try {
    let flags = "gu";
    if (options.case_insensitive) flags += "i";
    if (options.multi_line) flags += "m";
    return new Ok(new RegExp(pattern, flags));
  } catch (error) {
    const number = (error.columnNumber || 0) | 0;
    return new Error(new CompileError(error.message, number));
  }
}
function replace3(regex, original_string, replacement) {
  regex.lastIndex = 0;
  return original_string.replaceAll(regex, replacement);
}

// build/dev/javascript/gleam_regexp/gleam/regexp.mjs
var CompileError = class extends CustomType {
  constructor(error, byte_index) {
    super();
    this.error = error;
    this.byte_index = byte_index;
  }
};
var Options = class extends CustomType {
  constructor(case_insensitive, multi_line) {
    super();
    this.case_insensitive = case_insensitive;
    this.multi_line = multi_line;
  }
};
function compile2(pattern, options) {
  return compile(pattern, options);
}
function from_string(pattern) {
  return compile2(pattern, new Options(false, false));
}

// build/dev/javascript/lustre_fable/lustre/fable/route.mjs
var Index2 = class extends CustomType {
};
var Chapter = class extends CustomType {
  constructor(chapter2) {
    super();
    this.chapter = chapter2;
  }
};
var Story = class extends CustomType {
  constructor(chapter2, story3) {
    super();
    this.chapter = chapter2;
    this.story = story3;
  }
};
var NotFound = class extends CustomType {
};
function parse3(uri) {
  let $ = path_segments(uri.path);
  if ($ instanceof Empty) {
    return new Index2();
  } else {
    let $1 = $.tail;
    if ($1 instanceof Empty) {
      return new NotFound();
    } else {
      let $2 = $1.tail;
      if ($2 instanceof Empty) {
        let $3 = $.head;
        if ($3 === "chapter") {
          let chapter2 = $1.head;
          return new Chapter(chapter2);
        } else {
          return new NotFound();
        }
      } else {
        let $3 = $2.tail;
        if ($3 instanceof Empty) {
          return new NotFound();
        } else {
          let $4 = $3.tail;
          if ($4 instanceof Empty) {
            let $5 = $2.head;
            if ($5 === "story") {
              let $6 = $.head;
              if ($6 === "chapter") {
                let chapter2 = $1.head;
                let story3 = $3.head;
                return new Story(chapter2, story3);
              } else {
                return new NotFound();
              }
            } else {
              return new NotFound();
            }
          } else {
            return new NotFound();
          }
        }
      }
    }
  }
}
function href2(route) {
  return href(
    (() => {
      if (route instanceof Index2) {
        return "/";
      } else if (route instanceof Chapter) {
        let chapter2 = route.chapter;
        return "/chapter/" + chapter2;
      } else if (route instanceof Story) {
        let chapter2 = route.chapter;
        let story3 = route.story;
        return "/chapter/" + chapter2 + "/story/" + story3;
      } else {
        return "#";
      }
    })()
  );
}

// build/dev/javascript/gleam_http/gleam/http.mjs
var Get = class extends CustomType {
};
var Post = class extends CustomType {
};
var Head = class extends CustomType {
};
var Put = class extends CustomType {
};
var Delete = class extends CustomType {
};
var Trace = class extends CustomType {
};
var Connect = class extends CustomType {
};
var Options2 = class extends CustomType {
};
var Patch2 = class extends CustomType {
};
var Http = class extends CustomType {
};
var Https = class extends CustomType {
};
function method_to_string(method) {
  if (method instanceof Get) {
    return "GET";
  } else if (method instanceof Post) {
    return "POST";
  } else if (method instanceof Head) {
    return "HEAD";
  } else if (method instanceof Put) {
    return "PUT";
  } else if (method instanceof Delete) {
    return "DELETE";
  } else if (method instanceof Trace) {
    return "TRACE";
  } else if (method instanceof Connect) {
    return "CONNECT";
  } else if (method instanceof Options2) {
    return "OPTIONS";
  } else if (method instanceof Patch2) {
    return "PATCH";
  } else {
    let s = method[0];
    return s;
  }
}
function scheme_to_string(scheme) {
  if (scheme instanceof Http) {
    return "http";
  } else {
    return "https";
  }
}
function scheme_from_string(scheme) {
  let $ = lowercase(scheme);
  if ($ === "http") {
    return new Ok(new Http());
  } else if ($ === "https") {
    return new Ok(new Https());
  } else {
    return new Error(void 0);
  }
}

// build/dev/javascript/gleam_http/gleam/http/request.mjs
var Request = class extends CustomType {
  constructor(method, headers, body, scheme, host, port, path2, query) {
    super();
    this.method = method;
    this.headers = headers;
    this.body = body;
    this.scheme = scheme;
    this.host = host;
    this.port = port;
    this.path = path2;
    this.query = query;
  }
};
function to_uri(request) {
  return new Uri(
    new Some(scheme_to_string(request.scheme)),
    new None(),
    new Some(request.host),
    request.port,
    request.path,
    request.query,
    new None()
  );
}
function from_uri(uri) {
  return then$2(
    (() => {
      let _pipe = uri.scheme;
      let _pipe$1 = unwrap(_pipe, "");
      return scheme_from_string(_pipe$1);
    })(),
    (scheme) => {
      return then$2(
        (() => {
          let _pipe = uri.host;
          return to_result(_pipe, void 0);
        })(),
        (host) => {
          let req = new Request(
            new Get(),
            toList([]),
            "",
            scheme,
            host,
            uri.port,
            uri.path,
            uri.query
          );
          return new Ok(req);
        }
      );
    }
  );
}

// build/dev/javascript/gleam_http/gleam/http/response.mjs
var Response = class extends CustomType {
  constructor(status, headers, body) {
    super();
    this.status = status;
    this.headers = headers;
    this.body = body;
  }
};
function get_header(response, key) {
  return key_find(response.headers, lowercase(key));
}

// build/dev/javascript/gleam_javascript/gleam_javascript_ffi.mjs
var PromiseLayer = class _PromiseLayer {
  constructor(promise) {
    this.promise = promise;
  }
  static wrap(value3) {
    return value3 instanceof Promise ? new _PromiseLayer(value3) : value3;
  }
  static unwrap(value3) {
    return value3 instanceof _PromiseLayer ? value3.promise : value3;
  }
};
function resolve(value3) {
  return Promise.resolve(PromiseLayer.wrap(value3));
}
function then_await(promise, fn) {
  return promise.then((value3) => fn(PromiseLayer.unwrap(value3)));
}
function map_promise(promise, fn) {
  return promise.then(
    (value3) => PromiseLayer.wrap(fn(PromiseLayer.unwrap(value3)))
  );
}

// build/dev/javascript/gleam_javascript/gleam/javascript/promise.mjs
function tap(promise, callback) {
  let _pipe = promise;
  return map_promise(
    _pipe,
    (a2) => {
      callback(a2);
      return a2;
    }
  );
}
function try_await(promise, callback) {
  let _pipe = promise;
  return then_await(
    _pipe,
    (result) => {
      if (result instanceof Ok) {
        let a2 = result[0];
        return callback(a2);
      } else {
        let e = result[0];
        return resolve(new Error(e));
      }
    }
  );
}

// build/dev/javascript/gleam_fetch/gleam_fetch_ffi.mjs
async function raw_send(request) {
  try {
    return new Ok(await fetch(request));
  } catch (error) {
    return new Error(new NetworkError(error.toString()));
  }
}
function from_fetch_response(response) {
  return new Response(
    response.status,
    List.fromArray([...response.headers]),
    response
  );
}
function request_common(request) {
  let url = to_string6(to_uri(request));
  let method = method_to_string(request.method).toUpperCase();
  let options = {
    headers: make_headers(request.headers),
    method
  };
  return [url, options];
}
function to_fetch_request(request) {
  let [url, options] = request_common(request);
  if (options.method !== "GET" && options.method !== "HEAD") options.body = request.body;
  return new globalThis.Request(url, options);
}
function make_headers(headersList) {
  let headers = new globalThis.Headers();
  for (let [k, v] of headersList) headers.append(k.toLowerCase(), v);
  return headers;
}
async function read_text_body(response) {
  let body;
  try {
    body = await response.body.text();
  } catch (error) {
    return new Error(new UnableToReadBody());
  }
  return new Ok(response.withFields({ body }));
}

// build/dev/javascript/gleam_fetch/gleam/fetch.mjs
var NetworkError = class extends CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
};
var UnableToReadBody = class extends CustomType {
};
function send2(request) {
  let _pipe = request;
  let _pipe$1 = to_fetch_request(_pipe);
  let _pipe$2 = raw_send(_pipe$1);
  return try_await(
    _pipe$2,
    (resp) => {
      return resolve(new Ok(from_fetch_response(resp)));
    }
  );
}

// build/dev/javascript/rsvp/rsvp.ffi.mjs
var from_relative_url = (url_string) => {
  if (!globalThis.location) return new Error(void 0);
  const url = new URL(url_string, globalThis.location.href);
  const uri = uri_from_url2(url);
  return new Ok(uri);
};
var uri_from_url2 = (url) => {
  const optional2 = (value3) => value3 ? new Some(value3) : new None();
  return new Uri(
    /* scheme   */
    optional2(url.protocol?.slice(0, -1)),
    /* userinfo */
    new None(),
    /* host     */
    optional2(url.hostname),
    /* port     */
    optional2(url.port && Number(url.port)),
    /* path     */
    url.pathname,
    /* query    */
    optional2(url.search?.slice(1)),
    /* fragment */
    optional2(url.hash?.slice(1))
  );
};

// build/dev/javascript/rsvp/rsvp.mjs
var BadBody = class extends CustomType {
};
var BadUrl = class extends CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
};
var HttpError = class extends CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
};
var NetworkError2 = class extends CustomType {
};
var UnhandledResponse = class extends CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
};
var Handler2 = class extends CustomType {
  constructor(run2) {
    super();
    this.run = run2;
  }
};
function expect_ok_response(handler) {
  return new Handler2(
    (result) => {
      return handler(
        try$(
          result,
          (response) => {
            let $ = response.status;
            let code2 = $;
            if (code2 >= 200 && code2 < 300) {
              return new Ok(response);
            } else {
              let code$1 = $;
              if (code$1 >= 400 && code$1 < 600) {
                return new Error(new HttpError(response));
              } else {
                return new Error(new UnhandledResponse(response));
              }
            }
          }
        )
      );
    }
  );
}
function expect_text_response(handler) {
  return expect_ok_response(
    (result) => {
      return handler(
        try$(
          result,
          (response) => {
            let $ = get_header(response, "content-type");
            if ($ instanceof Ok) {
              let $1 = $[0];
              if ($1.startsWith("text/")) {
                return new Ok(response);
              } else {
                return new Error(new UnhandledResponse(response));
              }
            } else {
              return new Error(new UnhandledResponse(response));
            }
          }
        )
      );
    }
  );
}
function expect_text(handler) {
  return expect_text_response(
    (result) => {
      let _pipe = result;
      let _pipe$1 = map3(_pipe, (response) => {
        return response.body;
      });
      return handler(_pipe$1);
    }
  );
}
function do_send(request, handler) {
  return from(
    (dispatch2) => {
      let _pipe = send2(request);
      let _pipe$1 = try_await(_pipe, read_text_body);
      let _pipe$2 = map_promise(
        _pipe$1,
        (_capture) => {
          return map_error(
            _capture,
            (error) => {
              if (error instanceof NetworkError) {
                return new NetworkError2();
              } else if (error instanceof UnableToReadBody) {
                return new BadBody();
              } else {
                return new BadBody();
              }
            }
          );
        }
      );
      let _pipe$3 = map_promise(_pipe$2, handler.run);
      tap(_pipe$3, dispatch2);
      return void 0;
    }
  );
}
function send3(request, handler) {
  return do_send(request, handler);
}
function reject(err, handler) {
  return from(
    (dispatch2) => {
      let _pipe = new Error(err);
      let _pipe$1 = handler.run(_pipe);
      return dispatch2(_pipe$1);
    }
  );
}
function to_uri2(uri_string) {
  let _block;
  if (uri_string.startsWith("./")) {
    _block = from_relative_url(uri_string);
  } else if (uri_string.startsWith("/")) {
    _block = from_relative_url(uri_string);
  } else {
    _block = parse2(uri_string);
  }
  let _pipe = _block;
  return replace_error(_pipe, new BadUrl(uri_string));
}
function get2(url, handler) {
  let $ = to_uri2(url);
  if ($ instanceof Ok) {
    let uri = $[0];
    let _pipe = from_uri(uri);
    let _pipe$1 = map3(
      _pipe,
      (_capture) => {
        return send3(_capture, handler);
      }
    );
    let _pipe$2 = map_error(
      _pipe$1,
      (_) => {
        return reject(new BadUrl(url), handler);
      }
    );
    return unwrap_both(_pipe$2);
  } else {
    let err = $[0];
    return reject(err, handler);
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
function element3(tag, attributes, children) {
  let $ = extract_keyed_children(children);
  let keyed_children = $[0];
  let children$1 = $[1];
  return element(
    "",
    identity2,
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
    identity2,
    children$1,
    keyed_children,
    children_count
  );
}
function ul2(attributes, children) {
  return element3("ul", attributes, children);
}
function div2(attributes, children) {
  return element3("div", attributes, children);
}

// build/dev/javascript/lustre/lustre/element/svg.mjs
var namespace = "http://www.w3.org/2000/svg";
function circle(attrs) {
  return namespaced(namespace, "circle", attrs, empty_list);
}
function rect(attrs) {
  return namespaced(namespace, "rect", attrs, empty_list);
}
function path(attrs) {
  return namespaced(namespace, "path", attrs, empty_list);
}

// build/dev/javascript/lustre_fable/lustre/fable/ui/icon.mjs
function sidebar(attributes) {
  return svg(
    prepend(
      attribute2("width", "24"),
      prepend(
        attribute2("height", "24"),
        prepend(
          attribute2("viewBox", "0 0 24 24"),
          prepend(
            attribute2("fill", "none"),
            prepend(
              attribute2("stroke", "currentColor"),
              prepend(
                attribute2("stroke-width", "2"),
                prepend(
                  attribute2("stroke-linecap", "round"),
                  prepend(attribute2("stroke-linejoin", "round"), attributes)
                )
              )
            )
          )
        )
      )
    ),
    toList([
      rect(
        toList([
          attribute2("width", "18"),
          attribute2("height", "18"),
          attribute2("x", "3"),
          attribute2("y", "3"),
          attribute2("rx", "2")
        ])
      ),
      path(toList([attribute2("d", "M15 3v18")]))
    ])
  );
}
function hamburger(attributes) {
  return svg(
    prepend(
      attribute2("width", "24"),
      prepend(
        attribute2("height", "24"),
        prepend(
          attribute2("viewBox", "0 0 24 24"),
          prepend(
            attribute2("fill", "none"),
            prepend(
              attribute2("stroke", "currentColor"),
              prepend(
                attribute2("stroke-width", "2"),
                prepend(
                  attribute2("stroke-linecap", "round"),
                  prepend(attribute2("stroke-linejoin", "round"), attributes)
                )
              )
            )
          )
        )
      )
    ),
    toList([
      path(toList([attribute2("d", "M4 12h16")])),
      path(toList([attribute2("d", "M4 18h16")])),
      path(toList([attribute2("d", "M4 6h16")]))
    ])
  );
}
function search(attributes) {
  return svg(
    prepend(
      attribute2("width", "24"),
      prepend(
        attribute2("height", "24"),
        prepend(
          attribute2("viewBox", "0 0 24 24"),
          prepend(
            attribute2("fill", "none"),
            prepend(
              attribute2("stroke", "currentColor"),
              prepend(
                attribute2("stroke-width", "2"),
                prepend(
                  attribute2("stroke-linecap", "round"),
                  prepend(attribute2("stroke-linejoin", "round"), attributes)
                )
              )
            )
          )
        )
      )
    ),
    toList([
      path(toList([attribute2("d", "m21 21-4.34-4.34")])),
      circle(
        toList([
          attribute2("cx", "11"),
          attribute2("cy", "11"),
          attribute2("r", "8")
        ])
      )
    ])
  );
}
function lock(attributes) {
  return svg(
    prepend(
      attribute2("width", "24"),
      prepend(
        attribute2("height", "24"),
        prepend(
          attribute2("viewBox", "0 0 24 24"),
          prepend(
            attribute2("fill", "none"),
            prepend(
              attribute2("stroke", "currentColor"),
              prepend(
                attribute2("stroke-width", "2"),
                prepend(
                  attribute2("stroke-linecap", "round"),
                  prepend(attribute2("stroke-linejoin", "round"), attributes)
                )
              )
            )
          )
        )
      )
    ),
    toList([
      rect(
        toList([
          attribute2("width", "18"),
          attribute2("height", "11"),
          attribute2("x", "3"),
          attribute2("y", "11"),
          attribute2("rx", "2"),
          attribute2("ry", "2")
        ])
      ),
      path(toList([attribute2("d", "M7 11V7a5 5 0 0 1 10 0v4")]))
    ])
  );
}

// build/dev/javascript/lustre_fable/lustre/fable/ui/layout.mjs
var Layout = class extends CustomType {
  constructor(is_mobile, is_sidebar_open) {
    super();
    this.is_mobile = is_mobile;
    this.is_sidebar_open = is_sidebar_open;
  }
};
function view_container(layout, children) {
  let _block;
  let $ = layout.is_sidebar_open;
  if ($) {
    _block = "30ch";
  } else {
    _block = "0px";
  }
  let sidebar_width = _block;
  let _block$1;
  let $1 = layout.is_mobile;
  let $2 = layout.is_sidebar_open;
  if ($1) {
    if ($2) {
      _block$1 = "calc(100vh - 3rem)";
    } else {
      _block$1 = "0px";
    }
  } else {
    _block$1 = "100%";
  }
  let sidebar_height = _block$1;
  return div2(
    toList([
      style("--sidebar-width", sidebar_width),
      style("--sidebar-height", sidebar_height),
      class$("h-screen lg:transition-[grid-template-columns]"),
      class$("grid grid-rows-[3rem_1fr] grid-cols-[1fr]"),
      class$("lg:grid-cols-[var(--sidebar-width)_1fr]")
    ]),
    children
  );
}
function view_header(content3) {
  return header(
    toList([
      class$("flex items-center px-4 border-b"),
      class$("lg:col-start-2")
    ]),
    content3
  );
}
function view_sidebar(content3) {
  return aside(
    toList([
      class$(
        "\n        overflow-hidden text-sm max-h-[var(--sidebar-height)] bg-white z-10\n        col-start-1 row-start-2 transition-[height]\n\n        lg:row-start-1 lg:row-span-2 lg:border-r\n        "
      )
    ]),
    toList([
      div(
        toList([class$("min-w-[30ch] *:px-4 space-y-4")]),
        content3
      )
    ])
  );
}
function view_content(content3) {
  return main(
    toList([
      class$("col-start-1 row-start-2 overflow-auto"),
      class$("lg:col-start-2")
    ]),
    content3
  );
}
function view_story_scene(scene2) {
  return main(
    toList([
      class$("p-4 grid grid-cols-1 grid-rows-1 place-items-center")
    ]),
    toList([scene2])
  );
}
function view_story_controls(controls) {
  return aside(
    toList([
      class$("p-4 border-t flex flex-col gap-4 h-full"),
      class$("@3xl:border-t-0 @3xl:border-l")
    ]),
    toList([controls])
  );
}
function story(scene2, controls) {
  let should_show_controls = !isEqual(controls, none2());
  return div(
    toList([class$("@container h-full")]),
    toList([
      div(
        toList([
          classes(
            toList([
              ["h-full grid grid-cols-1 @3xl:grid-rows-1", true],
              ["grid-rows-[1fr_300px]", should_show_controls],
              ["@3xl:grid-cols-[1fr_300px]", should_show_controls]
            ])
          )
        ]),
        toList([view_story_scene(scene2), view_story_controls(controls)])
      )
    ])
  );
}
var css = '/*! tailwindcss v4.1.8 | MIT License | https://tailwindcss.com */\n@layer properties{@supports (((-webkit-hyphens:none)) and (not (margin-trim:inline))) or ((-moz-orient:inline) and (not (color:rgb(from red r g b)))){*,:before,:after,::backdrop{--tw-space-y-reverse:0;--tw-border-style:solid;--tw-font-weight:initial;--tw-shadow:0 0 #0000;--tw-shadow-color:initial;--tw-shadow-alpha:100%;--tw-inset-shadow:0 0 #0000;--tw-inset-shadow-color:initial;--tw-inset-shadow-alpha:100%;--tw-ring-color:initial;--tw-ring-shadow:0 0 #0000;--tw-inset-ring-color:initial;--tw-inset-ring-shadow:0 0 #0000;--tw-ring-inset:initial;--tw-ring-offset-width:0px;--tw-ring-offset-color:#fff;--tw-ring-offset-shadow:0 0 #0000;--tw-blur:initial;--tw-brightness:initial;--tw-contrast:initial;--tw-grayscale:initial;--tw-hue-rotate:initial;--tw-invert:initial;--tw-opacity:initial;--tw-saturate:initial;--tw-sepia:initial;--tw-drop-shadow:initial;--tw-drop-shadow-color:initial;--tw-drop-shadow-alpha:100%;--tw-drop-shadow-size:initial}}}@layer theme{:root,:host{--font-sans:ui-sans-serif,system-ui,sans-serif,"Apple Color Emoji","Segoe UI Emoji","Segoe UI Symbol","Noto Color Emoji";--font-mono:ui-monospace,SFMono-Regular,Menlo,Monaco,Consolas,"Liberation Mono","Courier New",monospace;--color-blue-50:oklch(97% .014 254.604);--color-blue-500:oklch(62.3% .214 259.815);--color-stone-50:oklch(98.5% .001 106.423);--color-stone-100:oklch(97% .001 106.424);--color-stone-200:oklch(92.3% .003 48.717);--color-white:#fff;--spacing:.25rem;--text-sm:.875rem;--text-sm--line-height:calc(1.25/.875);--text-lg:1.125rem;--text-lg--line-height:calc(1.75/1.125);--font-weight-semibold:600;--radius-sm:.25rem;--default-transition-duration:.15s;--default-transition-timing-function:cubic-bezier(.4,0,.2,1);--default-font-family:var(--font-sans);--default-mono-font-family:var(--font-mono)}}@layer base{*,:after,:before,::backdrop{box-sizing:border-box;border:0 solid;margin:0;padding:0}::file-selector-button{box-sizing:border-box;border:0 solid;margin:0;padding:0}html,:host{-webkit-text-size-adjust:100%;tab-size:4;line-height:1.5;font-family:var(--default-font-family,ui-sans-serif,system-ui,sans-serif,"Apple Color Emoji","Segoe UI Emoji","Segoe UI Symbol","Noto Color Emoji");font-feature-settings:var(--default-font-feature-settings,normal);font-variation-settings:var(--default-font-variation-settings,normal);-webkit-tap-highlight-color:transparent}hr{height:0;color:inherit;border-top-width:1px}abbr:where([title]){-webkit-text-decoration:underline dotted;text-decoration:underline dotted}h1,h2,h3,h4,h5,h6{font-size:inherit;font-weight:inherit}a{color:inherit;-webkit-text-decoration:inherit;-webkit-text-decoration:inherit;-webkit-text-decoration:inherit;text-decoration:inherit}b,strong{font-weight:bolder}code,kbd,samp,pre{font-family:var(--default-mono-font-family,ui-monospace,SFMono-Regular,Menlo,Monaco,Consolas,"Liberation Mono","Courier New",monospace);font-feature-settings:var(--default-mono-font-feature-settings,normal);font-variation-settings:var(--default-mono-font-variation-settings,normal);font-size:1em}small{font-size:80%}sub,sup{vertical-align:baseline;font-size:75%;line-height:0;position:relative}sub{bottom:-.25em}sup{top:-.5em}table{text-indent:0;border-color:inherit;border-collapse:collapse}:-moz-focusring{outline:auto}progress{vertical-align:baseline}summary{display:list-item}ol,ul,menu{list-style:none}img,svg,video,canvas,audio,iframe,embed,object{vertical-align:middle;display:block}img,video{max-width:100%;height:auto}button,input,select,optgroup,textarea{font:inherit;font-feature-settings:inherit;font-variation-settings:inherit;letter-spacing:inherit;color:inherit;opacity:1;background-color:#0000;border-radius:0}::file-selector-button{font:inherit;font-feature-settings:inherit;font-variation-settings:inherit;letter-spacing:inherit;color:inherit;opacity:1;background-color:#0000;border-radius:0}:where(select:is([multiple],[size])) optgroup{font-weight:bolder}:where(select:is([multiple],[size])) optgroup option{padding-inline-start:20px}::file-selector-button{margin-inline-end:4px}::placeholder{opacity:1}@supports (not ((-webkit-appearance:-apple-pay-button))) or (contain-intrinsic-size:1px){::placeholder{color:currentColor}@supports (color:color-mix(in lab, red, red)){::placeholder{color:color-mix(in oklab,currentcolor 50%,transparent)}}}textarea{resize:vertical}::-webkit-search-decoration{-webkit-appearance:none}::-webkit-date-and-time-value{min-height:1lh;text-align:inherit}::-webkit-datetime-edit{display:inline-flex}::-webkit-datetime-edit-fields-wrapper{padding:0}::-webkit-datetime-edit{padding-block:0}::-webkit-datetime-edit-year-field{padding-block:0}::-webkit-datetime-edit-month-field{padding-block:0}::-webkit-datetime-edit-day-field{padding-block:0}::-webkit-datetime-edit-hour-field{padding-block:0}::-webkit-datetime-edit-minute-field{padding-block:0}::-webkit-datetime-edit-second-field{padding-block:0}::-webkit-datetime-edit-millisecond-field{padding-block:0}::-webkit-datetime-edit-meridiem-field{padding-block:0}:-moz-ui-invalid{box-shadow:none}button,input:where([type=button],[type=reset],[type=submit]){appearance:button}::file-selector-button{appearance:button}::-webkit-inner-spin-button{height:auto}::-webkit-outer-spin-button{height:auto}[hidden]:where(:not([hidden=until-found])){display:none!important}*,:after,:before,::backdrop{border-color:var(--color-stone-200,currentColor)}::file-selector-button{border-color:var(--color-stone-200,currentColor)}}@layer components;@layer utilities{.\\@container{container-type:inline-size}.absolute{position:absolute}.relative{position:relative}.-top-2{top:calc(var(--spacing)*-2)}.right-2{right:calc(var(--spacing)*2)}.z-10{z-index:10}.col-start-1{grid-column-start:1}.row-start-2{grid-row-start:2}.block{display:block}.flex{display:flex}.grid{display:grid}.inline-grid{display:inline-grid}.size-3{width:calc(var(--spacing)*3);height:calc(var(--spacing)*3)}.size-4{width:calc(var(--spacing)*4);height:calc(var(--spacing)*4)}.h-full{height:100%}.h-px{height:1px}.h-screen{height:100vh}.max-h-\\[var\\(--sidebar-height\\)\\]{max-height:var(--sidebar-height)}.min-h-12{min-height:calc(var(--spacing)*12)}.w-full{width:100%}.min-w-\\[30ch\\]{min-width:30ch}.min-w-max{min-width:max-content}.flex-1{flex:1}.border-collapse{border-collapse:collapse}.cursor-pointer{cursor:pointer}.grid-cols-1{grid-template-columns:repeat(1,minmax(0,1fr))}.grid-cols-\\[1fr\\]{grid-template-columns:1fr}.grid-rows-1{grid-template-rows:repeat(1,minmax(0,1fr))}.grid-rows-\\[1fr_300px\\]{grid-template-rows:1fr 300px}.grid-rows-\\[3rem_1fr\\]{grid-template-rows:3rem 1fr}.flex-col{flex-direction:column}.place-items-center{place-items:center}.items-center{align-items:center}.justify-center{justify-content:center}.gap-2{gap:calc(var(--spacing)*2)}.gap-4{gap:calc(var(--spacing)*4)}:where(.space-y-2>:not(:last-child)){--tw-space-y-reverse:0;margin-block-start:calc(calc(var(--spacing)*2)*var(--tw-space-y-reverse));margin-block-end:calc(calc(var(--spacing)*2)*calc(1 - var(--tw-space-y-reverse)))}:where(.space-y-4>:not(:last-child)){--tw-space-y-reverse:0;margin-block-start:calc(calc(var(--spacing)*4)*var(--tw-space-y-reverse));margin-block-end:calc(calc(var(--spacing)*4)*calc(1 - var(--tw-space-y-reverse)))}.overflow-auto{overflow:auto}.overflow-hidden{overflow:hidden}.overflow-y-auto{overflow-y:auto}.rounded{border-radius:.25rem}.rounded-sm{border-radius:var(--radius-sm)}.border{border-style:var(--tw-border-style);border-width:1px}.border-t{border-top-style:var(--tw-border-style);border-top-width:1px}.border-b{border-bottom-style:var(--tw-border-style);border-bottom-width:1px}.border-dashed{--tw-border-style:dashed;border-style:dashed}.border-blue-500\\/0{border-color:#0000}@supports (color:color-mix(in lab, red, red)){.border-blue-500\\/0{border-color:color-mix(in oklab,var(--color-blue-500)0%,transparent)}}.bg-blue-50{background-color:var(--color-blue-50)}.bg-stone-100{background-color:var(--color-stone-100)}.bg-stone-200{background-color:var(--color-stone-200)}.bg-white{background-color:var(--color-white)}.p-1{padding:calc(var(--spacing)*1)}.p-2{padding:calc(var(--spacing)*2)}.p-4{padding:calc(var(--spacing)*4)}.px-2{padding-inline:calc(var(--spacing)*2)}.px-3{padding-inline:calc(var(--spacing)*3)}.px-4{padding-inline:calc(var(--spacing)*4)}.py-1{padding-block:calc(var(--spacing)*1)}.py-2{padding-block:calc(var(--spacing)*2)}.py-4{padding-block:calc(var(--spacing)*4)}.pl-2{padding-left:calc(var(--spacing)*2)}.text-center{text-align:center}.text-justify{text-align:justify}.text-lg{font-size:var(--text-lg);line-height:var(--tw-leading,var(--text-lg--line-height))}.text-sm{font-size:var(--text-sm);line-height:var(--tw-leading,var(--text-sm--line-height))}.font-semibold{--tw-font-weight:var(--font-weight-semibold);font-weight:var(--font-weight-semibold)}.text-blue-500{color:var(--color-blue-500)}.lowercase{text-transform:lowercase}.underline{text-decoration-line:underline}.shadow{--tw-shadow:0 1px 3px 0 var(--tw-shadow-color,#0000001a),0 1px 2px -1px var(--tw-shadow-color,#0000001a);box-shadow:var(--tw-inset-shadow),var(--tw-inset-ring-shadow),var(--tw-ring-offset-shadow),var(--tw-ring-shadow),var(--tw-shadow)}.filter{filter:var(--tw-blur,)var(--tw-brightness,)var(--tw-contrast,)var(--tw-grayscale,)var(--tw-hue-rotate,)var(--tw-invert,)var(--tw-saturate,)var(--tw-sepia,)var(--tw-drop-shadow,)}.transition{transition-property:color,background-color,border-color,outline-color,text-decoration-color,fill,stroke,--tw-gradient-from,--tw-gradient-via,--tw-gradient-to,opacity,box-shadow,transform,translate,scale,rotate,filter,-webkit-backdrop-filter,backdrop-filter,display,visibility,content-visibility,overlay,pointer-events;transition-timing-function:var(--tw-ease,var(--default-transition-timing-function));transition-duration:var(--tw-duration,var(--default-transition-duration))}.transition-\\[height\\]{transition-property:height;transition-timing-function:var(--tw-ease,var(--default-transition-timing-function));transition-duration:var(--tw-duration,var(--default-transition-duration))}:is(.\\*\\:px-4>*){padding-inline:calc(var(--spacing)*4)}.focus-within\\:border-blue-500:focus-within{border-color:var(--color-blue-500)}@media (hover:hover){.hover\\:border-blue-500\\/100:hover{border-color:var(--color-blue-500)}.hover\\:bg-stone-50:hover{background-color:var(--color-stone-50)}.hover\\:underline:hover{text-decoration-line:underline}}.focus\\:border-blue-500:focus{border-color:var(--color-blue-500)}.focus\\:outline-none:focus{--tw-outline-style:none;outline-style:none}@media (min-width:64rem){.lg\\:col-start-2{grid-column-start:2}.lg\\:row-span-2{grid-row:span 2/span 2}.lg\\:row-start-1{grid-row-start:1}.lg\\:grid-cols-\\[var\\(--sidebar-width\\)_1fr\\]{grid-template-columns:var(--sidebar-width)1fr}.lg\\:border-r{border-right-style:var(--tw-border-style);border-right-width:1px}.lg\\:transition-\\[grid-template-columns\\]{transition-property:grid-template-columns;transition-timing-function:var(--tw-ease,var(--default-transition-timing-function));transition-duration:var(--tw-duration,var(--default-transition-duration))}}@container (min-width:48rem){.\\@3xl\\:grid-cols-\\[1fr_300px\\]{grid-template-columns:1fr 300px}.\\@3xl\\:grid-rows-1{grid-template-rows:repeat(1,minmax(0,1fr))}.\\@3xl\\:border-t-0{border-top-style:var(--tw-border-style);border-top-width:0}.\\@3xl\\:border-l{border-left-style:var(--tw-border-style);border-left-width:1px}}}@property --tw-space-y-reverse{syntax:"*";inherits:false;initial-value:0}@property --tw-border-style{syntax:"*";inherits:false;initial-value:solid}@property --tw-font-weight{syntax:"*";inherits:false}@property --tw-shadow{syntax:"*";inherits:false;initial-value:0 0 #0000}@property --tw-shadow-color{syntax:"*";inherits:false}@property --tw-shadow-alpha{syntax:"<percentage>";inherits:false;initial-value:100%}@property --tw-inset-shadow{syntax:"*";inherits:false;initial-value:0 0 #0000}@property --tw-inset-shadow-color{syntax:"*";inherits:false}@property --tw-inset-shadow-alpha{syntax:"<percentage>";inherits:false;initial-value:100%}@property --tw-ring-color{syntax:"*";inherits:false}@property --tw-ring-shadow{syntax:"*";inherits:false;initial-value:0 0 #0000}@property --tw-inset-ring-color{syntax:"*";inherits:false}@property --tw-inset-ring-shadow{syntax:"*";inherits:false;initial-value:0 0 #0000}@property --tw-ring-inset{syntax:"*";inherits:false}@property --tw-ring-offset-width{syntax:"<length>";inherits:false;initial-value:0}@property --tw-ring-offset-color{syntax:"*";inherits:false;initial-value:#fff}@property --tw-ring-offset-shadow{syntax:"*";inherits:false;initial-value:0 0 #0000}@property --tw-blur{syntax:"*";inherits:false}@property --tw-brightness{syntax:"*";inherits:false}@property --tw-contrast{syntax:"*";inherits:false}@property --tw-grayscale{syntax:"*";inherits:false}@property --tw-hue-rotate{syntax:"*";inherits:false}@property --tw-invert{syntax:"*";inherits:false}@property --tw-opacity{syntax:"*";inherits:false}@property --tw-saturate{syntax:"*";inherits:false}@property --tw-sepia{syntax:"*";inherits:false}@property --tw-drop-shadow{syntax:"*";inherits:false}@property --tw-drop-shadow-color{syntax:"*";inherits:false}@property --tw-drop-shadow-alpha{syntax:"<percentage>";inherits:false;initial-value:100%}@property --tw-drop-shadow-size{syntax:"*";inherits:false}';
function shell(layout, handle_sidebar_toggle, header_content, sidebar_content, main_content) {
  let header_sidebar_toggle = button(
    toList([
      on_click(handle_sidebar_toggle),
      class$("p-1 border rounded")
    ]),
    toList([
      (() => {
        let $2 = layout.is_mobile;
        if ($2) {
          return hamburger(toList([class$("size-4")]));
        } else {
          return sidebar(toList([class$("size-4")]));
        }
      })()
    ])
  );
  let _block;
  let $ = layout.is_mobile;
  if ($) {
    _block = "mobile-sidebar";
  } else {
    _block = "desktop-sidebar";
  }
  let sidebar_key = _block;
  return fragment2(
    toList([
      style2(toList([]), css),
      view_container(
        layout,
        toList([
          [
            "header",
            view_header(prepend(header_sidebar_toggle, header_content))
          ],
          [sidebar_key, view_sidebar(sidebar_content)],
          ["content", view_content(main_content)]
        ])
      )
    ])
  );
}

// build/dev/javascript/lustre_fable/lustre/fable/story.mjs
var FILEPATH = "src/lustre/fable/story.gleam";
var Story2 = class extends CustomType {
  constructor(title3, route, component2, scene2) {
    super();
    this.title = title3;
    this.route = route;
    this.component = component2;
    this.scene = scene2;
  }
};
var StoryBuilder = class extends CustomType {
  constructor(run2) {
    super();
    this.run = run2;
  }
};
var StoryConfig = class extends CustomType {
  constructor(title3, inputs, sequences2, options, view8) {
    super();
    this.title = title3;
    this.inputs = inputs;
    this.sequences = sequences2;
    this.options = options;
    this.view = view8;
  }
};
var Controls = class extends CustomType {
  constructor(lookup) {
    super();
    this.lookup = lookup;
  }
};
var Model = class extends CustomType {
  constructor(lookup, sequences2, sequence, controls_visible, tab) {
    super();
    this.lookup = lookup;
    this.sequences = sequences2;
    this.sequence = sequence;
    this.controls_visible = controls_visible;
    this.tab = tab;
  }
};
var TabControls = class extends CustomType {
};
var TabSequences = class extends CustomType {
};
var ComponentUpdatedValue = class extends CustomType {
  constructor(key, value3) {
    super();
    this.key = key;
    this.value = value3;
  }
};
var ExternalStylesheetLoaded = class extends CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
};
var ParentSetControlsVisibility = class extends CustomType {
  constructor(controls_visible) {
    super();
    this.controls_visible = controls_visible;
  }
};
var UserChangedTab = class extends CustomType {
  constructor(tab) {
    super();
    this.tab = tab;
  }
};
var UserEditedValue = class extends CustomType {
  constructor(key, value3) {
    super();
    this.key = key;
    this.value = value3;
  }
};
var SceneModel = class extends CustomType {
  constructor(lookup, stylesheets, pending_stylesheets) {
    super();
    this.lookup = lookup;
    this.stylesheets = stylesheets;
    this.pending_stylesheets = pending_stylesheets;
  }
};
function story_init(_, sequences2, controls_visible) {
  let model = new Model(
    new_map(),
    sequences2,
    toList([]),
    controls_visible,
    new TabControls()
  );
  return [model, none()];
}
function story_update(model, msg) {
  if (msg instanceof ComponentUpdatedValue) {
    let key = msg.key;
    let value3 = msg.value;
    return [
      (() => {
        let _record = model;
        return new Model(
          insert(model.lookup, key, value3),
          _record.sequences,
          _record.sequence,
          _record.controls_visible,
          _record.tab
        );
      })(),
      none()
    ];
  } else if (msg instanceof ExternalStylesheetLoaded) {
    return [model, none()];
  } else if (msg instanceof ParentSetControlsVisibility) {
    let controls_visible = msg.controls_visible;
    return [
      (() => {
        let _record = model;
        return new Model(
          _record.lookup,
          _record.sequences,
          _record.sequence,
          controls_visible,
          _record.tab
        );
      })(),
      none()
    ];
  } else if (msg instanceof UserChangedTab) {
    let tab = msg.tab;
    return [
      (() => {
        let _record = model;
        return new Model(
          _record.lookup,
          _record.sequences,
          _record.sequence,
          _record.controls_visible,
          tab
        );
      })(),
      none()
    ];
  } else {
    let key = msg.key;
    let value3 = msg.value;
    return [
      (() => {
        let _record = model;
        return new Model(
          insert(
            model.lookup,
            key,
            (() => {
              let _pipe = value3;
              let _pipe$1 = to_string3(_pipe);
              let _pipe$2 = parse(_pipe$1, dynamic);
              return unwrap2(_pipe$2, nil());
            })()
          ),
          _record.sequences,
          _record.sequence,
          _record.controls_visible,
          _record.tab
        );
      })(),
      none()
    ];
  }
}
function story_view_toggle(active) {
  let classes2 = (tab) => {
    return classes(
      toList([
        ["flex-1 text-center px-3 py-1 rounded-sm cursor-pointer", true],
        ["hover:bg-stone-50", true],
        ["bg-white", isEqual(tab, active)]
      ])
    );
  };
  return div(
    toList([class$("flex gap-2 rounded bg-stone-100 p-2")]),
    toList([
      button(
        toList([
          on_click(new UserChangedTab(new TabControls())),
          classes2(new TabControls())
        ]),
        toList([text3("Controls")])
      ),
      button(
        toList([
          on_click(new UserChangedTab(new TabSequences())),
          classes2(new TabSequences())
        ]),
        toList([text3("Sequences")])
      )
    ])
  );
}
function scene_init(_, stylesheets, external_stylesheets) {
  let model = new SceneModel(
    new_map(),
    stylesheets,
    length(external_stylesheets)
  );
  let _block;
  let _pipe = external_stylesheets;
  let _pipe$1 = map(
    _pipe,
    (_capture) => {
      return get2(
        _capture,
        expect_text(
          (var0) => {
            return new ExternalStylesheetLoaded(var0);
          }
        )
      );
    }
  );
  _block = batch(_pipe$1);
  let effect = _block;
  return [model, effect];
}
function scene_update(model, msg) {
  if (msg instanceof ComponentUpdatedValue) {
    let key = msg.key;
    let value3 = msg.value;
    return [
      (() => {
        let _record = model;
        return new SceneModel(
          insert(model.lookup, key, value3),
          _record.stylesheets,
          _record.pending_stylesheets
        );
      })(),
      none()
    ];
  } else if (msg instanceof ExternalStylesheetLoaded) {
    let $ = msg[0];
    if ($ instanceof Ok) {
      let css2 = $[0];
      let _block;
      let _record = model;
      _block = new SceneModel(
        _record.lookup,
        prepend(css2, model.stylesheets),
        model.pending_stylesheets - 1
      );
      let model$1 = _block;
      return [model$1, none()];
    } else {
      let _block;
      let _record = model;
      _block = new SceneModel(
        _record.lookup,
        _record.stylesheets,
        model.pending_stylesheets - 1
      );
      let model$1 = _block;
      return [model$1, none()];
    }
  } else if (msg instanceof ParentSetControlsVisibility) {
    return [model, none()];
  } else if (msg instanceof UserChangedTab) {
    return [model, none()];
  } else {
    let key = msg.key;
    let value3 = msg.value;
    return [
      model,
      emit(
        "change",
        object2(toList([["key", int3(key)], ["value", value3]]))
      )
    ];
  }
}
function scene_view(model, view8) {
  return fragment2(
    flatten(
      toList([
        map(
          model.stylesheets,
          (css2) => {
            return style2(
              toList([]),
              replace(css2, ":root", ":host")
            );
          }
        ),
        toList([
          (() => {
            let $ = model.pending_stylesheets;
            if ($ === 0) {
              return view8(new Controls(model.lookup));
            } else {
              return none2();
            }
          })(),
          style2(
            toList([]),
            "\n          :host {\n            border-collapse: revert;\n            border-spacing: revert;\n            caption-side: revert;\n            color: revert;\n            cursor: revert;\n            direction: revert;\n            empty-cells: revert;\n            font-family: revert;\n            font-size: revert;\n            font-style: revert;\n            font-variant: revert;\n            font-weight: revert;\n            font-size-adjust: revert;\n            font-stretch: revert;\n            font: revert;\n            letter-spacing: revert;\n            line-height: revert;\n            list-style-image: revert;\n            list-style-position: revert;\n            list-style-type: revert;\n            list-style: revert;\n            orphans: revert;\n            quotes: revert;\n            tab-size: revert;\n            text-align: revert;\n            text-align-last: revert;\n            text-decoration-color: revert;\n            text-indent: revert;\n            text-justify: revert;\n            text-shadow: revert;\n            text-transform: revert;\n            visibility: revert;\n            white-space: revert;\n            widows: revert;\n            word-break: revert;\n            word-spacing: revert;\n            word-wrap: revert;\n          }\n          "
          )
        ])
      ])
    )
  );
}
function do_base_tag(loop$base, loop$count) {
  while (true) {
    let base = loop$base;
    let count = loop$count;
    let $ = is_registered(base + "-" + to_string(count));
    if ($) {
      loop$base = base;
      loop$count = count + 1;
    } else {
      return base + "-" + to_string(count);
    }
  }
}
function base_tag(title3) {
  let $ = from_string("[^a-zA-Z0-9]+");
  if (!($ instanceof Ok)) {
    throw makeError(
      "let_assert",
      FILEPATH,
      "lustre/fable/story",
      425,
      "base_tag",
      "Pattern match failed, no pattern matched the value.",
      {
        value: $,
        start: 10565,
        end: 10620,
        pattern_start: 10576,
        pattern_end: 10582
      }
    );
  }
  let re = $[0];
  let _block;
  let _pipe = title3;
  let _pipe$1 = lowercase(_pipe);
  _block = ((_capture) => {
    return replace3(re, _capture, "-");
  })(
    _pipe$1
  );
  let safe_component_name = _block;
  let $1 = is_registered(safe_component_name);
  if ($1) {
    return do_base_tag(safe_component_name, 1);
  } else {
    return safe_component_name;
  }
}
function story_view(model, scene2, inputs) {
  let handle_change = subfield(
    toList(["detail", "key"]),
    int2,
    (key) => {
      return subfield(
        toList(["detail", "value"]),
        dynamic,
        (value3) => {
          return success(new ComponentUpdatedValue(key, value3));
        }
      );
    }
  );
  let attributes = fold2(
    model.lookup,
    toList([]),
    (attributes2, key, value3) => {
      return prepend(
        property2(to_string(key), identity2(value3)),
        attributes2
      );
    }
  );
  return story(
    element2(
      scene2,
      prepend(
        on("change", handle_change),
        prepend(
          class$(
            "rounded p-4 border-dashed border border-blue-500/0"
          ),
          prepend(
            class$("transition hover:border-blue-500/100"),
            attributes
          )
        )
      ),
      toList([])
    ),
    (() => {
      let $ = is_empty(inputs) && is_empty2(model.sequences);
      if ($) {
        return none2();
      } else {
        return fragment2(
          toList([
            story_view_toggle(model.tab),
            div(
              toList([class$("flex flex-col overflow-y-auto")]),
              (() => {
                let $1 = model.tab;
                if ($1 instanceof TabControls) {
                  return map(
                    inputs,
                    (input3) => {
                      return input3(new Controls(model.lookup));
                    }
                  );
                } else {
                  return toList([
                    p(
                      toList([
                        class$(
                          "flex-1 flex justify-center items-center"
                        )
                      ]),
                      toList([
                        text3(
                          "Sequences are currently unsupported in this pre-release."
                        )
                      ])
                    )
                  ]);
                }
              })()
            )
          ])
        );
      }
    })()
  );
}
function register(config, stylesheets, external_stylesheets) {
  let base = base_tag(config.title);
  let component2 = base + "-story";
  let scene2 = base + "-scene";
  return try$(
    make_component(
      component(
        (_capture) => {
          return story_init(
            _capture,
            fold(
              config.sequences,
              new_map(),
              (sequences2, sequence) => {
                return insert(sequences2, sequence.key, sequence.messages);
              }
            ),
            !is_empty(config.inputs)
          );
        },
        story_update,
        (_capture) => {
          return story_view(_capture, scene2, config.inputs);
        },
        toList([
          on_property_change(
            "controls",
            (() => {
              let _pipe = bool;
              return map2(
                _pipe,
                (var0) => {
                  return new ParentSetControlsVisibility(var0);
                }
              );
            })()
          )
        ])
      ),
      component2
    ),
    (_) => {
      return try$(
        make_component(
          component(
            (_capture) => {
              return scene_init(_capture, stylesheets, external_stylesheets);
            },
            scene_update,
            (_capture) => {
              return scene_view(_capture, config.view);
            },
            config.options
          ),
          scene2
        ),
        (_2) => {
          return new Ok(new Story2(config.title, base, component2, scene2));
        }
      );
    }
  );
}

// build/dev/javascript/lustre_fable/lustre/fable/chapter.mjs
var FILEPATH2 = "src/lustre/fable/chapter.gleam";
var Chapter2 = class extends CustomType {
  constructor(title3, route, stories) {
    super();
    this.title = title3;
    this.route = route;
    this.stories = stories;
  }
};
function init2(title3, stories, stylesheets, external_stylesheets) {
  let $ = from_string("[^a-zA-Z0-9]+");
  if (!($ instanceof Ok)) {
    throw makeError(
      "let_assert",
      FILEPATH2,
      "lustre/fable/chapter",
      29,
      "init",
      "Pattern match failed, no pattern matched the value.",
      { value: $, start: 714, end: 769, pattern_start: 725, pattern_end: 731 }
    );
  }
  let re = $[0];
  let _block;
  let _pipe = title3;
  let _pipe$1 = ((_capture) => {
    return replace3(re, _capture, "-");
  })(
    _pipe
  );
  _block = lowercase(_pipe$1);
  let route = _block;
  let _pipe$2 = stories;
  let _pipe$3 = try_map(
    _pipe$2,
    (_capture) => {
      return register(_capture, stylesheets, external_stylesheets);
    }
  );
  return map3(
    _pipe$3,
    (_capture) => {
      return new Chapter2(title3, route, _capture);
    }
  );
}
function view2(chapter2) {
  return div(
    toList([
      class$("inline-grid w-full justify-center gap-4 px-2 py-4")
    ]),
    map(
      chapter2.stories,
      (story3) => {
        let route = new Story(chapter2.route, story3.route);
        return fragment2(
          toList([
            section(
              toList([class$("w-full min-w-max")]),
              toList([
                h2(
                  toList([class$("text-lg font-semibold underline")]),
                  toList([
                    a(
                      toList([href2(route)]),
                      toList([text3(story3.title)])
                    )
                  ])
                ),
                div(
                  toList([class$("relative")]),
                  toList([
                    lock(
                      toList([
                        class$(
                          "absolute -top-2 right-2 size-3 bg-white"
                        )
                      ])
                    ),
                    element2(
                      story3.scene,
                      toList([
                        class$("block"),
                        class$(
                          "rounded p-4 border-dashed border border-blue-500/0"
                        ),
                        class$(
                          "transition hover:border-blue-500/100"
                        )
                      ]),
                      toList([])
                    )
                  ])
                )
              ])
            ),
            hr(toList([class$("w-full h-px bg-stone-200")]))
          ])
        );
      }
    )
  );
}

// build/dev/javascript/lustre_fable/lustre/fable/document.ffi.mjs
function focus(selector) {
  document.querySelector(selector)?.focus();
}

// build/dev/javascript/lustre_fable/lustre/fable/document.mjs
function focus2(selector) {
  return after_paint((_, _1) => {
    return focus(selector);
  });
}

// build/dev/javascript/lustre_fable/lustre/fable/window.ffi.mjs
function match_media(query) {
  return window.matchMedia(query).matches;
}
function watch_media(query, callback) {
  const mediaQueryList = window.matchMedia(query);
  const listener = (event4) => callback(event4.matches);
  mediaQueryList.addEventListener("change", listener);
}
function add_event_listener(name6, callback) {
  window.addEventListener(name6, callback);
}

// build/dev/javascript/lustre_fable/lustre/fable/book.mjs
var Book = class extends CustomType {
  constructor(title3, stylesheets, external_stylesheets, chapters) {
    super();
    this.title = title3;
    this.stylesheets = stylesheets;
    this.external_stylesheets = external_stylesheets;
    this.chapters = chapters;
  }
};
var Model2 = class extends CustomType {
  constructor(layout, route, title3, filter4, chapters, filtered) {
    super();
    this.layout = layout;
    this.route = route;
    this.title = title3;
    this.filter = filter4;
    this.chapters = chapters;
    this.filtered = filtered;
  }
};
var Args = class extends CustomType {
  constructor(is_mobile, title3, chapters) {
    super();
    this.is_mobile = is_mobile;
    this.title = title3;
    this.chapters = chapters;
  }
};
var BrowserChangedDimensions = class extends CustomType {
  constructor(is_mobile) {
    super();
    this.is_mobile = is_mobile;
  }
};
var UserFocusedSearch = class extends CustomType {
};
var UserNavigatedTo = class extends CustomType {
  constructor(route) {
    super();
    this.route = route;
  }
};
var UserToggledSidebar = class extends CustomType {
};
var UserTypedSearch = class extends CustomType {
  constructor(filter4) {
    super();
    this.filter = filter4;
  }
};
function init3(args) {
  let _block;
  let _pipe = do_initial_uri();
  let _pipe$1 = map3(_pipe, parse3);
  _block = unwrap2(_pipe$1, new Index2());
  let route = _block;
  let model = new Model2(
    new Layout(args.is_mobile, !args.is_mobile),
    route,
    args.title,
    "",
    args.chapters,
    args.chapters
  );
  let effect = init(
    (uri) => {
      let _pipe$2 = uri;
      let _pipe$3 = parse3(_pipe$2);
      return new UserNavigatedTo(_pipe$3);
    }
  );
  return [model, effect];
}
function update2(model, msg) {
  let $ = echo(msg, "src/lustre/fable/book.gleam", 139);
  if ($ instanceof BrowserChangedDimensions) {
    let is_mobile = $.is_mobile;
    let is_sidebar_open = !is_mobile;
    let layout = new Layout(is_mobile, is_sidebar_open);
    let _block;
    let _record = model;
    _block = new Model2(
      layout,
      _record.route,
      _record.title,
      _record.filter,
      _record.chapters,
      model.chapters
    );
    let model$1 = _block;
    return [model$1, none()];
  } else if ($ instanceof UserFocusedSearch) {
    let effect = focus2("input[type='search']");
    return [model, effect];
  } else if ($ instanceof UserNavigatedTo) {
    let route = $.route;
    let _block;
    let _record = model;
    _block = new Model2(
      _record.layout,
      route,
      _record.title,
      "",
      _record.chapters,
      model.chapters
    );
    let model$1 = _block;
    return [model$1, none()];
  } else if ($ instanceof UserToggledSidebar) {
    let is_sidebar_open = !model.layout.is_sidebar_open;
    let _block;
    let _record = model.layout;
    _block = new Layout(_record.is_mobile, is_sidebar_open);
    let layout = _block;
    let _block$1;
    let _record$1 = model;
    _block$1 = new Model2(
      layout,
      _record$1.route,
      _record$1.title,
      _record$1.filter,
      _record$1.chapters,
      _record$1.filtered
    );
    let model$1 = _block$1;
    return [model$1, none()];
  } else {
    let $1 = $.filter;
    if ($1 === "") {
      let _block;
      let _record = model;
      _block = new Model2(
        _record.layout,
        _record.route,
        _record.title,
        "",
        _record.chapters,
        model.chapters
      );
      let model$1 = _block;
      return [model$1, none()];
    } else {
      let filter4 = $1;
      let filtered = filter_map(
        model.chapters,
        (chapter2) => {
          let stories = filter(
            chapter2.stories,
            (story3) => {
              return contains_string(
                lowercase(story3.title),
                lowercase(filter4)
              );
            }
          );
          if (stories instanceof Empty) {
            return new Error(void 0);
          } else {
            return new Ok(new Chapter2(chapter2.title, chapter2.route, stories));
          }
        }
      );
      let _block;
      let _record = model;
      _block = new Model2(
        _record.layout,
        _record.route,
        _record.title,
        filter4,
        _record.chapters,
        filtered
      );
      let model$1 = _block;
      return [model$1, none()];
    }
  }
}
function split_on_filter(title3, filter4) {
  let $ = split_once(
    lowercase(title3),
    lowercase(filter4)
  );
  if ($ instanceof Ok) {
    let after = $[0][1];
    let before = drop_end(
      title3,
      string_length(filter4) + string_length(after)
    );
    let filter$1 = slice(
      title3,
      string_length(before),
      string_length(filter4)
    );
    let after$1 = slice(
      title3,
      string_length(before) + string_length(filter$1),
      string_length(title3)
    );
    return [before, filter$1, after$1];
  } else {
    return [title3, "", ""];
  }
}
function view_nav_story(chapter2, story3, filter4, current2) {
  let route = new Story(chapter2.route, story3.route);
  let classes2 = classes(
    toList([
      ["hover:underline", true],
      ["text-blue-500", isEqual(route, current2)]
    ])
  );
  return a(
    toList([href2(route), classes2]),
    (() => {
      let $ = split_on_filter(story3.title, filter4);
      let $1 = $[2];
      if ($1 === "") {
        let $2 = $[1];
        if ($2 === "") {
          return toList([text3(story3.title)]);
        } else {
          let before = $[0];
          let filter$1 = $2;
          let after = $1;
          return toList([
            text3(before),
            span(
              toList([class$("underline text-blue-500")]),
              toList([text3(filter$1)])
            ),
            text3(after)
          ]);
        }
      } else {
        let before = $[0];
        let filter$1 = $[1];
        let after = $1;
        return toList([
          text3(before),
          span(
            toList([class$("underline text-blue-500")]),
            toList([text3(filter$1)])
          ),
          text3(after)
        ]);
      }
    })()
  );
}
function view_nav_chapter(chapter2, filter4, current2) {
  let route = new Chapter(chapter2.route);
  let classes2 = classes(
    toList([
      ["font-semibold hover:underline", true],
      ["text-blue-500", isEqual(route, current2)]
    ])
  );
  return div(
    toList([class$("space-y-2")]),
    toList([
      a(
        toList([href2(route), classes2]),
        toList([text3(chapter2.title)])
      ),
      ul(
        toList([]),
        map(
          chapter2.stories,
          (story3) => {
            return li(
              toList([class$("pl-2")]),
              toList([view_nav_story(chapter2, story3, filter4, current2)])
            );
          }
        )
      )
    ])
  );
}
function view_chapters(chapters, filter4, current2) {
  return nav(
    toList([class$("space-y-4")]),
    map(
      chapters,
      (chapter2) => {
        return view_nav_chapter(chapter2, filter4, current2);
      }
    )
  );
}
function view3(model) {
  return shell(
    model.layout,
    new UserToggledSidebar(),
    toList([]),
    toList([
      h1(
        toList([class$("flex items-center min-h-12 bg-blue-50")]),
        toList([
          span(
            toList([class$("text-lg text-blue-500 font-semibold")]),
            toList([text3(model.title)])
          )
        ])
      ),
      div(
        toList([]),
        toList([
          div(
            toList([
              class$(
                "flex items-center gap-2 border rounded px-3 py-2"
              ),
              class$("focus-within:border-blue-500")
            ]),
            toList([
              span(
                toList([]),
                toList([search(toList([class$("size-4")]))])
              ),
              input(
                toList([
                  class$("flex-1 w-full focus:outline-none"),
                  value(model.filter),
                  type_("search"),
                  placeholder("Press / to search..."),
                  on_input(
                    (var0) => {
                      return new UserTypedSearch(var0);
                    }
                  )
                ])
              )
            ])
          )
        ])
      ),
      view_chapters(model.filtered, model.filter, model.route)
    ]),
    (() => {
      let $ = model.route;
      if ($ instanceof Index2) {
        return toList([]);
      } else if ($ instanceof Chapter) {
        let chapter2 = $.chapter;
        let $1 = find2(
          model.chapters,
          (c) => {
            return c.route === chapter2;
          }
        );
        if ($1 instanceof Ok) {
          let chapter$1 = $1[0];
          return toList([view2(chapter$1)]);
        } else {
          return toList([]);
        }
      } else if ($ instanceof Story) {
        let story3 = $.story;
        return toList([
          element2(story3 + "-story", toList([]), toList([]))
        ]);
      } else {
        return toList([]);
      }
    })()
  );
}
function start4(book2) {
  let app = application(init3, update2, view3);
  let chapters = filter_map(
    book2.chapters,
    (chapter2) => {
      return init2(
        chapter2[0],
        chapter2[1],
        book2.stylesheets,
        book2.external_stylesheets
      );
    }
  );
  let args = new Args(
    match_media("(width < 64rem)"),
    book2.title,
    chapters
  );
  return try$(
    start3(app, "#app", args),
    (runtime) => {
      watch_media(
        "(width < 64rem)",
        (is_mobile) => {
          let _pipe = dispatch(new BrowserChangedDimensions(is_mobile));
          return send(runtime, _pipe);
        }
      );
      add_event_listener(
        "keydown",
        (event4) => {
          let decoder2 = field(
            "key",
            string2,
            (key) => {
              if (key === "/") {
                return success(new UserFocusedSearch());
              } else {
                return failure(new UserFocusedSearch(), "/");
              }
            }
          );
          let _pipe = run(event4, decoder2);
          let _pipe$1 = map3(_pipe, dispatch);
          let _pipe$2 = map3(
            _pipe$1,
            (_capture) => {
              return send(runtime, _capture);
            }
          );
          return unwrap2(_pipe$2, void 0);
        }
      );
      return new Ok(void 0);
    }
  );
}
function echo(value3, file, line) {
  const grey = "\x1B[90m";
  const reset_color = "\x1B[39m";
  const file_line = `${file}:${line}`;
  const string_value = echo$inspect(value3);
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
  return value3;
}
function echo$inspectString(str) {
  let new_str = '"';
  for (let i = 0; i < str.length; i++) {
    let char = str[i];
    if (char == "\n") new_str += "\\n";
    else if (char == "\r") new_str += "\\r";
    else if (char == "	") new_str += "\\t";
    else if (char == "\f") new_str += "\\f";
    else if (char == "\\") new_str += "\\\\";
    else if (char == '"') new_str += '\\"';
    else if (char < " " || char > "~" && char < "\xA0") {
      new_str += "\\u{" + char.charCodeAt(0).toString(16).toUpperCase().padStart(4, "0") + "}";
    } else {
      new_str += char;
    }
  }
  new_str += '"';
  return new_str;
}
function echo$inspectDict(map6) {
  let body = "dict.from_list([";
  let first3 = true;
  let key_value_pairs = [];
  map6.forEach((value3, key) => {
    key_value_pairs.push([key, value3]);
  });
  key_value_pairs.sort();
  key_value_pairs.forEach(([key, value3]) => {
    if (!first3) body = body + ", ";
    body = body + "#(" + echo$inspect(key) + ", " + echo$inspect(value3) + ")";
    first3 = false;
  });
  return body + "])";
}
function echo$inspectCustomType(record) {
  const props = globalThis.Object.keys(record).map((label2) => {
    const value3 = echo$inspect(record[label2]);
    return isNaN(parseInt(label2)) ? `${label2}: ${value3}` : value3;
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
  if (v === true) return "True";
  if (v === false) return "False";
  if (v === null) return "//js(null)";
  if (v === void 0) return "Nil";
  if (t === "string") return echo$inspectString(v);
  if (t === "bigint" || t === "number") return v.toString();
  if (globalThis.Array.isArray(v))
    return `#(${v.map(echo$inspect).join(", ")})`;
  if (v instanceof List)
    return `[${v.toArray().map(echo$inspect).join(", ")}]`;
  if (v instanceof UtfCodepoint)
    return `//utfcodepoint(${String.fromCodePoint(v.value)})`;
  if (v instanceof BitArray) return echo$inspectBitArray(v);
  if (v instanceof CustomType) return echo$inspectCustomType(v);
  if (echo$isDict(v)) return echo$inspectDict(v);
  if (v instanceof Set)
    return `//js(Set(${[...v].map(echo$inspect).join(", ")}))`;
  if (v instanceof RegExp) return `//js(${v})`;
  if (v instanceof Date) return `//js(Date("${v.toISOString()}"))`;
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
function echo$isDict(value3) {
  try {
    return value3 instanceof Dict;
  } catch {
    return false;
  }
}

// build/dev/javascript/lustre_fable/lustre/dev/fable.mjs
var BookOption = class extends CustomType {
  constructor(configure) {
    super();
    this.configure = configure;
  }
};
var Control = class extends CustomType {
  constructor(get5, set3) {
    super();
    this.get = get5;
    this.set = set3;
  }
};
function book(title3, options) {
  let init8 = new Book(title3, toList([]), toList([]), toList([]));
  return fold(
    options,
    init8,
    (book2, option3) => {
      return option3.configure(book2);
    }
  );
}
function chapter(title3, stories) {
  return new BookOption(
    (book2) => {
      let _record = book2;
      return new Book(
        _record.title,
        _record.stylesheets,
        _record.external_stylesheets,
        prepend([title3, stories], book2.chapters)
      );
    }
  );
}
function external_stylesheet(href3) {
  return new BookOption(
    (book2) => {
      let _record = book2;
      return new Book(
        _record.title,
        _record.stylesheets,
        prepend(href3, book2.external_stylesheets),
        _record.chapters
      );
    }
  );
}
function start5(book2) {
  return start4(book2);
}
function story2(title3, builder) {
  let _record = builder().run(0);
  return new StoryConfig(
    title3,
    _record.inputs,
    _record.sequences,
    _record.options,
    _record.view
  );
}
function scene(view8) {
  return new StoryBuilder(
    (_) => {
      return new StoryConfig(
        "",
        toList([]),
        toList([]),
        toList([adopt_styles(false)]),
        view8
      );
    }
  );
}
function get3(controls, control2) {
  return control2.get(controls);
}
function set(control2, value3) {
  return control2.set(value3);
}
function control(default$2, encode2, decoder2, view8, next2) {
  return new StoryBuilder(
    (key) => {
      let state = (controls) => {
        let _pipe = controls.lookup;
        let _pipe$1 = map_get(_pipe, key);
        let _pipe$2 = unwrap2(_pipe$1, nil());
        let _pipe$3 = run(_pipe$2, decoder2);
        return unwrap2(_pipe$3, default$2);
      };
      let set_state = (value3) => {
        let _pipe = value3;
        let _pipe$1 = encode2(_pipe);
        return ((_capture) => {
          return new UserEditedValue(key, _capture);
        })(_pipe$1);
      };
      let input$1 = (controls) => {
        return view8(state(controls), set_state);
      };
      let option3 = on_property_change(
        to_string(key),
        (() => {
          let _pipe = dynamic;
          return map2(
            _pipe,
            (_capture) => {
              return new ComponentUpdatedValue(key, _capture);
            }
          );
        })()
      );
      let $ = next2(new Control(state, set_state)).run(key + 1);
      let title3 = $.title;
      let inputs = $.inputs;
      let sequences2 = $.sequences;
      let options = $.options;
      let view$1 = $.view;
      return new StoryConfig(
        title3,
        prepend(input$1, inputs),
        sequences2,
        prepend(option3, options),
        view$1
      );
    }
  );
}
function input2(label2, value3, next2) {
  return ((_capture) => {
    return control(value3, string3, string2, _capture, next2);
  })(
    (value4, set_value) => {
      return label(
        toList([]),
        toList([
          p(
            toList([class$("text-sm")]),
            toList([text3(label2)])
          ),
          input(
            toList([
              class$("border rounded px-2 py-1"),
              class$("focus:outline-none focus:border-blue-500"),
              value(value4),
              on_input(set_value)
            ])
          )
        ])
      );
    }
  );
}

// build/dev/javascript/lustre_ui/lustre/ffi/dom.ffi.mjs
var assigned_elements = (slot2) => {
  if (!(slot2 instanceof HTMLSlotElement)) return new Error(void 0);
  const elements = slot2.assignedElements();
  return new Ok(List.fromArray(elements));
};
var bounding_client_rect = (element15) => {
  if (!(element15 instanceof HTMLElement)) return new Error(void 0);
  const rect2 = element15.getBoundingClientRect();
  return new Ok(
    new BoundingClientRect(
      rect2.top,
      rect2.right,
      rect2.bottom,
      rect2.left,
      rect2.width,
      rect2.height
    )
  );
};
var attribute3 = (element15, name6) => {
  if (!(element15 instanceof HTMLElement)) return new Error(void 0);
  if (typeof name6 !== "string") return new Error(void 0);
  const value3 = element15.getAttribute(name6);
  if (value3 === null) {
    return new Error(void 0);
  } else {
    return new Ok(value3);
  }
};
var prevent_default = (event4) => {
  if (!(event4 instanceof Event)) return;
  event4.preventDefault();
};
var find_element = (selector, root3 = document) => {
  if (typeof selector !== "string") return new Error(void 0);
  if (!(root3 instanceof Document || root3 instanceof Element))
    return new Error(void 0);
  const element15 = root3.querySelector(selector);
  if (element15 === null) {
    return new Error(void 0);
  } else {
    return new Ok(element15);
  }
};
var focus3 = (element15) => {
  if (!(element15 instanceof HTMLElement)) return;
  element15.focus();
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
function assigned_elements2(decoder2, lenient) {
  let lenient_decoder = one_of(
    map2(decoder2, (var0) => {
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
              return filter_map(_capture, identity2);
            }
          );
          return replace_error(_pipe$2, toList([]));
        } else {
          let elements = $[0];
          let _pipe = elements;
          let _pipe$1 = try_map(
            _pipe,
            (_capture) => {
              return run(_capture, decoder2);
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
    (element15) => {
      let $ = bounding_client_rect(element15);
      if ($ instanceof Ok) {
        let rect2 = $[0];
        return new Ok(rect2);
      } else {
        return new Error(new BoundingClientRect(0, 0, 0, 0, 0, 0));
      }
    }
  );
}
function attribute4(name6) {
  return new_primitive_decoder(
    "Element.getAttribute()",
    (element15) => {
      let $ = attribute3(element15, name6);
      if ($ instanceof Ok) {
        let value3 = $[0];
        return new Ok(value3);
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
function child(selector, zero, decoder2) {
  return new_primitive_decoder(
    "Element.querySelector()",
    (element15) => {
      let $ = find_element(selector, element15);
      if ($ instanceof Ok) {
        let child$1 = $[0];
        let _pipe = run(child$1, decoder2);
        return replace_error(_pipe, zero);
      } else {
        return new Error(zero);
      }
    }
  );
}
function focus4(selector) {
  return before_paint(
    (_, root3) => {
      let $ = find_element(selector, root3);
      if ($ instanceof Ok) {
        let element15 = $[0];
        return focus3(element15);
      } else {
        return void 0;
      }
    }
  );
}

// build/dev/javascript/lustre_ui/lustre/ui/data/bidict.mjs
function new$8() {
  return [new_map(), new_map()];
}
function has(bidict, key) {
  return has_key(bidict[0], key);
}
function get4(bidict, key) {
  return map_get(bidict[0], key);
}
function get_inverse(bidict, key) {
  return map_get(bidict[1], key);
}
function min_inverse(bidict, compare5) {
  let _pipe = map_to_list(bidict[1]);
  let _pipe$1 = sort(_pipe, (a2, b) => {
    return compare5(a2[0], b[0]);
  });
  let _pipe$2 = first(_pipe$1);
  return map3(_pipe$2, second);
}
function max_inverse(bidict, compare5) {
  let _pipe = map_to_list(bidict[1]);
  let _pipe$1 = sort(_pipe, (a2, b) => {
    return compare5(b[0], a2[0]);
  });
  let _pipe$2 = first(_pipe$1);
  return map3(_pipe$2, second);
}
function next(bidict, key, increment) {
  let _pipe = get4(bidict, key);
  let _pipe$1 = map3(_pipe, increment);
  return then$2(
    _pipe$1,
    (_capture) => {
      return get_inverse(bidict, _capture);
    }
  );
}
function set2(bidict, key, value3) {
  return [
    insert(bidict[0], key, value3),
    insert(bidict[1], value3, key)
  ];
}
function from_list3(entries) {
  return fold(
    entries,
    new$8(),
    (bidict, entry) => {
      return set2(bidict, entry[0], entry[1]);
    }
  );
}
function indexed(values3) {
  return index_fold(
    values3,
    new$8(),
    (bidict, value3, index5) => {
      return set2(bidict, value3, index5);
    }
  );
}

// build/dev/javascript/lustre_ui/lustre/ui/primitives/collapse.mjs
var Model3 = class extends CustomType {
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
function on_change2(handler) {
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
function init4(_) {
  let model = new Model3(0, false);
  let effect = none();
  return [model, effect];
}
function update3(model, msg) {
  if (msg instanceof ParentChangedContent) {
    let height = msg[0];
    return [
      (() => {
        let _record = model;
        return new Model3(height, _record.expanded);
      })(),
      none()
    ];
  } else if (msg instanceof ParentSetExpanded) {
    let expanded$1 = msg[0];
    return [
      (() => {
        let _record = model;
        return new Model3(_record.height, expanded$1);
      })(),
      none()
    ];
  } else {
    let height = msg[0];
    let event4 = msg.event;
    let _block;
    let _record = model;
    _block = new Model3(height, _record.expanded);
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
        return map2(_pipe, (rect2) => {
          return rect2.height;
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
                  return map2(_pipe, (rect2) => {
                    return rect2.height;
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
                  return map2(_pipe, (rect2) => {
                    return rect2.height;
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
        return map2(_pipe, (rect2) => {
          return rect2.height;
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
function view_content2(height) {
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
function element4(attributes, trigger, content3) {
  return element2(
    name2,
    attributes,
    toList([
      div(toList([attribute2("slot", "trigger")]), toList([trigger])),
      content3
    ])
  );
}
function view4(model) {
  let _block;
  let $ = model.expanded;
  if ($) {
    _block = float_to_string(model.height) + "px";
  } else {
    _block = "0px";
  }
  let height = _block;
  return fragment2(toList([view_trigger(), view_content2(height)]));
}
function register2() {
  let app = component(
    init4,
    update3,
    view4,
    toList([
      adopt_styles(true),
      on_attribute_change(
        "aria-expanded",
        (value3) => {
          if (value3 === "true") {
            return new Ok(new ParentSetExpanded(true));
          } else if (value3 === "false") {
            return new Ok(new ParentSetExpanded(false));
          } else if (value3 === "") {
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
function chevron_right(attrs) {
  return icon(
    attrs,
    "M6.1584 3.13508C6.35985 2.94621 6.67627 2.95642 6.86514 3.15788L10.6151 7.15788C10.7954 7.3502 10.7954 7.64949 10.6151 7.84182L6.86514 11.8418C6.67627 12.0433 6.35985 12.0535 6.1584 11.8646C5.95694 11.6757 5.94673 11.3593 6.1356 11.1579L9.565 7.49985L6.1356 3.84182C5.94673 3.64036 5.95694 3.32394 6.1584 3.13508Z"
  );
}
function dots_horizontal(attrs) {
  return icon(
    attrs,
    "M3.625 7.5C3.625 8.12132 3.12132 8.625 2.5 8.625C1.87868 8.625 1.375 8.12132 1.375 7.5C1.375 6.87868 1.87868 6.375 2.5 6.375C3.12132 6.375 3.625 6.87868 3.625 7.5ZM8.625 7.5C8.625 8.12132 8.12132 8.625 7.5 8.625C6.87868 8.625 6.375 8.12132 6.375 7.5C6.375 6.87868 6.87868 6.375 7.5 6.375C8.12132 6.375 8.625 6.87868 8.625 7.5ZM12.5 8.625C13.1213 8.625 13.625 8.12132 13.625 7.5C13.625 6.87868 13.1213 6.375 12.5 6.375C11.8787 6.375 11.375 6.87868 11.375 7.5C11.375 8.12132 11.8787 8.625 12.5 8.625Z"
  );
}
function check2(attrs) {
  return icon(
    attrs,
    "M11.4669 3.72684C11.7558 3.91574 11.8369 4.30308 11.648 4.59198L7.39799 11.092C7.29783 11.2452 7.13556 11.3467 6.95402 11.3699C6.77247 11.3931 6.58989 11.3355 6.45446 11.2124L3.70446 8.71241C3.44905 8.48022 3.43023 8.08494 3.66242 7.82953C3.89461 7.57412 4.28989 7.55529 4.5453 7.78749L6.75292 9.79441L10.6018 3.90792C10.7907 3.61902 11.178 3.53795 11.4669 3.72684Z"
  );
}
function exclamation_triangle(attrs) {
  return icon(
    attrs,
    "M8.4449 0.608765C8.0183 -0.107015 6.9817 -0.107015 6.55509 0.608766L0.161178 11.3368C-0.275824 12.07 0.252503 13 1.10608 13H13.8939C14.7475 13 15.2758 12.07 14.8388 11.3368L8.4449 0.608765ZM7.4141 1.12073C7.45288 1.05566 7.54712 1.05566 7.5859 1.12073L13.9798 11.8488C14.0196 11.9154 13.9715 12 13.8939 12H1.10608C1.02849 12 0.980454 11.9154 1.02018 11.8488L7.4141 1.12073ZM6.8269 4.48611C6.81221 4.10423 7.11783 3.78663 7.5 3.78663C7.88217 3.78663 8.18778 4.10423 8.1731 4.48612L8.01921 8.48701C8.00848 8.766 7.7792 8.98664 7.5 8.98664C7.2208 8.98664 6.99151 8.766 6.98078 8.48701L6.8269 4.48611ZM8.24989 10.476C8.24989 10.8902 7.9141 11.226 7.49989 11.226C7.08567 11.226 6.74989 10.8902 6.74989 10.476C6.74989 10.0618 7.08567 9.72599 7.49989 9.72599C7.9141 9.72599 8.24989 10.0618 8.24989 10.476Z"
  );
}
function slash(attrs) {
  return icon(attrs, "M4.10876 14L9.46582 1H10.8178L5.46074 14H4.10876Z");
}
function magnifying_glass(attrs) {
  return icon(
    attrs,
    "M10 6.5C10 8.433 8.433 10 6.5 10C4.567 10 3 8.433 3 6.5C3 4.567 4.567 3 6.5 3C8.433 3 10 4.567 10 6.5ZM9.30884 10.0159C8.53901 10.6318 7.56251 11 6.5 11C4.01472 11 2 8.98528 2 6.5C2 4.01472 4.01472 2 6.5 2C8.98528 2 11 4.01472 11 6.5C11 7.56251 10.6318 8.53901 10.0159 9.30884L12.8536 12.1464C13.0488 12.3417 13.0488 12.6583 12.8536 12.8536C12.6583 13.0488 12.3417 13.0488 12.1464 12.8536L9.30884 10.0159Z"
  );
}
function bookmark(attrs) {
  return icon(
    attrs,
    "M3 2.5C3 2.22386 3.22386 2 3.5 2H11.5C11.7761 2 12 2.22386 12 2.5V13.5C12 13.6818 11.9014 13.8492 11.7424 13.9373C11.5834 14.0254 11.3891 14.0203 11.235 13.924L7.5 11.5896L3.765 13.924C3.61087 14.0203 3.41659 14.0254 3.25762 13.9373C3.09864 13.8492 3 13.6818 3 13.5V2.5ZM4 3V12.5979L6.97 10.7416C7.29427 10.539 7.70573 10.539 8.03 10.7416L11 12.5979V3H4Z"
  );
}

// build/dev/javascript/lustre_ui/lustre/ui/accordion.mjs
var Item = class extends CustomType {
  constructor(value3, label2, content3) {
    super();
    this.value = value3;
    this.label = label2;
    this.content = content3;
  }
};
var Model4 = class extends CustomType {
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
var Options3 = class extends CustomType {
  constructor(all10, lookup_label, lookup_index) {
    super();
    this.all = all10;
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
function item(value3, label2, content3) {
  return new Item(value3, label2, content3);
}
function init5(_) {
  let options = new Options3(toList([]), new$8(), new$8());
  let model = new Model4(options, new$(), new AtMostOne());
  let effect = none();
  return [model, effect];
}
function focus_trigger(key) {
  let selector = "[data-lustre-key=" + key + "] [part=accordion-trigger]";
  return focus4(selector);
}
function update4(model, msg) {
  if (msg instanceof ParentChangedChildren) {
    let all10 = msg[0];
    let lookup_label = from_list3(all10);
    let lookup_index = indexed(map(all10, first2));
    let options = new Options3(all10, lookup_label, lookup_index);
    let expanded2 = filter3(
      model.expanded,
      (_capture) => {
        return has(lookup_label, _capture);
      }
    );
    let keys2 = map(all10, first2);
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
        _block = unwrap2(_pipe$1, new$());
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
        _block = unwrap2(_pipe$1, new$());
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
        _block = unwrap2(_pipe$1, new$());
      }
    } else {
      _block = expanded2;
    }
    let expanded$1 = _block;
    let _block$1;
    let _record = model;
    _block$1 = new Model4(options, expanded$1, _record.mode);
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
        _block = unwrap2(_pipe$1, new$());
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
        _block = unwrap2(_pipe$1, new$());
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
        _block = unwrap2(_pipe$1, new$());
      }
    } else {
      _block = model.expanded;
    }
    let expanded2 = _block;
    let _block$1;
    let _record = model;
    _block$1 = new Model4(_record.options, expanded2, mode);
    let model$1 = _block$1;
    let effect = none();
    return [model$1, effect];
  } else if (msg instanceof UserPressedDown) {
    let key = msg[0];
    let event4 = msg.event;
    let effect = try$(
      get4(model.options.lookup_index, key),
      (index5) => {
        return map3(
          get_inverse(model.options.lookup_index, index5 + 1),
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
            return unwrap2(_pipe, none());
          })(),
          prevent_default2(event4)
        ])
      )
    ];
  } else if (msg instanceof UserPressedEnd) {
    let effect = map3(
      max_inverse(model.options.lookup_index, compare),
      (last) => {
        return focus_trigger(last);
      }
    );
    return [
      model,
      (() => {
        let _pipe = effect;
        return unwrap2(_pipe, none());
      })()
    ];
  } else if (msg instanceof UserPressedHome) {
    let effect = map3(
      min_inverse(model.options.lookup_index, compare),
      (first3) => {
        return focus_trigger(first3);
      }
    );
    return [
      model,
      (() => {
        let _pipe = effect;
        return unwrap2(_pipe, none());
      })()
    ];
  } else if (msg instanceof UserPressedUp) {
    let key = msg[0];
    let event4 = msg.event;
    let effect = try$(
      get4(model.options.lookup_index, key),
      (index5) => {
        return map3(
          get_inverse(model.options.lookup_index, index5 - 1),
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
            return unwrap2(_pipe, none());
          })(),
          prevent_default2(event4)
        ])
      )
    ];
  } else {
    let value3 = msg[0];
    let _block;
    let $ = contains(model.expanded, value3);
    let $1 = model.mode;
    if ($1 instanceof AtMostOne) {
      if ($) {
        _block = new$();
      } else {
        _block = from_list2(toList([value3]));
      }
    } else if ($1 instanceof ExactlyOne) {
      if ($) {
        _block = model.expanded;
      } else {
        _block = from_list2(toList([value3]));
      }
    } else if ($) {
      _block = delete$2(model.expanded, value3);
    } else {
      _block = insert2(model.expanded, value3);
    }
    let expanded2 = _block;
    let _block$1;
    let _record = model;
    _block$1 = new Model4(_record.options, expanded2, _record.mode);
    let model$1 = _block$1;
    let _block$2;
    let $2 = contains(expanded2, value3);
    if ($2) {
      _block$2 = emit("expand", string3(value3));
    } else {
      _block$2 = emit("collapse", string3(value3));
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
            (value3) => {
              return field(
                "textContent",
                string2,
                (label2) => {
                  return success([tag, value3, label2]);
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
        (acc, option3) => {
          let tag = option3[0];
          let value3 = option3[1];
          let label2 = option3[2];
          return guard(
            tag !== "LUSTRE-UI-ACCORDION-ITEM",
            acc,
            () => {
              return guard(
                contains(acc[1], value3),
                acc,
                () => {
                  let seen = insert2(acc[1], value3);
                  let options$1 = prepend([value3, label2], acc[0]);
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
function handle_keydown2(id) {
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
var name3 = "lustre-ui-accordion";
function element5(attributes, children) {
  return element3(
    name3,
    attributes,
    flat_map(
      children,
      (_use0) => {
        let value3 = _use0.value;
        let label2 = _use0.label;
        let content3 = _use0.content;
        return guard(
          value3 === "",
          toList([]),
          () => {
            let item$1 = element2(
              "lustre-ui-accordion-item",
              toList([value(value3)]),
              toList([text3(label2)])
            );
            let content$1 = div(
              toList([attribute2("slot", value3)]),
              content3
            );
            return toList([[value3, item$1], [value3 + "-content", content$1]]);
          }
        );
      }
    )
  );
}
function view5(model) {
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
            let label2 = _use0[1];
            let is_expanded = contains(model.expanded, key);
            let item$1 = element4(
              toList([
                expanded(is_expanded),
                on_change2((_) => {
                  return new UserToggledItem(key);
                })
              ]),
              button(
                toList([
                  attribute2("part", "accordion-trigger"),
                  attribute2("tabindex", "0"),
                  on("keydown", handle_keydown2(key))
                ]),
                toList([
                  p(
                    toList([attribute2("part", "accordion-trigger-label")]),
                    toList([text3(label2)])
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
  let $ = register2();
  if ($ instanceof Ok) {
    let app = component(
      init5,
      update4,
      view5,
      toList([
        on_attribute_change(
          "mode",
          (value3) => {
            if (value3 === "at-most-one") {
              return new Ok(new ParentSetMode(new AtMostOne()));
            } else if (value3 === "exactly-one") {
              return new Ok(new ParentSetMode(new ExactlyOne()));
            } else if (value3 === "multi") {
              return new Ok(new ParentSetMode(new Multi()));
            } else {
              return new Error(void 0);
            }
          }
        )
      ])
    );
    return make_component(app, name3);
  } else {
    let $1 = $[0];
    if ($1 instanceof ComponentAlreadyRegistered) {
      let app = component(
        init5,
        update4,
        view5,
        toList([
          on_attribute_change(
            "mode",
            (value3) => {
              if (value3 === "at-most-one") {
                return new Ok(new ParentSetMode(new AtMostOne()));
              } else if (value3 === "exactly-one") {
                return new Ok(new ParentSetMode(new ExactlyOne()));
              } else if (value3 === "multi") {
                return new Ok(new ParentSetMode(new Multi()));
              } else {
                return new Error(void 0);
              }
            }
          )
        ])
      );
      return make_component(app, name3);
    } else {
      let error = $;
      return error;
    }
  }
}

// build/dev/javascript/gleam_community_colour/gleam_community/colour.mjs
var Rgba = class extends CustomType {
  constructor(r, g, b, a2) {
    super();
    this.r = r;
    this.g = g;
    this.b = b;
    this.a = a2;
  }
};
function valid_colour_value(c) {
  let $ = c > 1 || c < 0;
  if ($) {
    return new Error(void 0);
  } else {
    return new Ok(c);
  }
}
function hue_to_rgb(hue, m1, m2) {
  let _block;
  if (hue < 0) {
    _block = hue + 1;
  } else {
    if (hue > 1) {
      _block = hue - 1;
    } else {
      _block = hue;
    }
  }
  let h = _block;
  let h_t_6 = h * 6;
  let h_t_2 = h * 2;
  let h_t_3 = h * 3;
  if (h_t_6 < 1) {
    return m1 + (m2 - m1) * h * 6;
  } else {
    if (h_t_2 < 1) {
      return m2;
    } else {
      if (h_t_3 < 2) {
        return m1 + (m2 - m1) * (divideFloat(2, 3) - h) * 6;
      } else {
        return m1;
      }
    }
  }
}
function hsla_to_rgba(h, s, l, a2) {
  let _block;
  let $ = l <= 0.5;
  if ($) {
    _block = l * (s + 1);
  } else {
    _block = l + s - l * s;
  }
  let m2 = _block;
  let m1 = l * 2 - m2;
  let r = hue_to_rgb(h + divideFloat(1, 3), m1, m2);
  let g = hue_to_rgb(h, m1, m2);
  let b = hue_to_rgb(h - divideFloat(1, 3), m1, m2);
  return [r, g, b, a2];
}
function from_rgb255(red2, green2, blue2) {
  return then$2(
    (() => {
      let _pipe = red2;
      let _pipe$1 = identity(_pipe);
      let _pipe$2 = divide(_pipe$1, 255);
      return then$2(_pipe$2, valid_colour_value);
    })(),
    (r) => {
      return then$2(
        (() => {
          let _pipe = green2;
          let _pipe$1 = identity(_pipe);
          let _pipe$2 = divide(_pipe$1, 255);
          return then$2(_pipe$2, valid_colour_value);
        })(),
        (g) => {
          return then$2(
            (() => {
              let _pipe = blue2;
              let _pipe$1 = identity(_pipe);
              let _pipe$2 = divide(_pipe$1, 255);
              return then$2(_pipe$2, valid_colour_value);
            })(),
            (b) => {
              return new Ok(new Rgba(r, g, b, 1));
            }
          );
        }
      );
    }
  );
}
function to_rgba(colour) {
  if (colour instanceof Rgba) {
    let r = colour.r;
    let g = colour.g;
    let b = colour.b;
    let a2 = colour.a;
    return [r, g, b, a2];
  } else {
    let h = colour.h;
    let s = colour.s;
    let l = colour.l;
    let a2 = colour.a;
    return hsla_to_rgba(h, s, l, a2);
  }
}

// build/dev/javascript/lustre_ui/lustre/ui/colour.mjs
var FILEPATH3 = "src/lustre/ui/colour.gleam";
var ColourPalette = class extends CustomType {
  constructor(base, primary, secondary, success3, warning, danger3) {
    super();
    this.base = base;
    this.primary = primary;
    this.secondary = secondary;
    this.success = success3;
    this.warning = warning;
    this.danger = danger3;
  }
};
var ColourScale = class extends CustomType {
  constructor(bg, bg_subtle, tint, tint_subtle, tint_strong, accent, accent_subtle, accent_strong, solid3, solid_subtle, solid_strong, solid_text, text4, text_subtle) {
    super();
    this.bg = bg;
    this.bg_subtle = bg_subtle;
    this.tint = tint;
    this.tint_subtle = tint_subtle;
    this.tint_strong = tint_strong;
    this.accent = accent;
    this.accent_subtle = accent_subtle;
    this.accent_strong = accent_strong;
    this.solid = solid3;
    this.solid_subtle = solid_subtle;
    this.solid_strong = solid_strong;
    this.solid_text = solid_text;
    this.text = text4;
    this.text_subtle = text_subtle;
  }
};
function rgb(r, g, b) {
  let r$1 = min(255, max(0, r));
  let g$1 = min(255, max(0, g));
  let b$1 = min(255, max(0, b));
  let $ = from_rgb255(r$1, g$1, b$1);
  if (!($ instanceof Ok)) {
    throw makeError(
      "let_assert",
      FILEPATH3,
      "lustre/ui/colour",
      63,
      "rgb",
      "Pattern match failed, no pattern matched the value.",
      {
        value: $,
        start: 1255,
        end: 1306,
        pattern_start: 1266,
        pattern_end: 1276
      }
    );
  }
  let colour = $[0];
  return colour;
}
function slate() {
  return new ColourScale(
    rgb(252, 252, 253),
    rgb(249, 249, 251),
    rgb(232, 232, 236),
    rgb(240, 240, 243),
    rgb(224, 225, 230),
    rgb(205, 206, 214),
    rgb(217, 217, 224),
    rgb(185, 187, 198),
    rgb(139, 141, 152),
    rgb(150, 152, 162),
    rgb(128, 131, 141),
    rgb(255, 255, 255),
    rgb(28, 32, 36),
    rgb(96, 100, 108)
  );
}
function red() {
  return new ColourScale(
    rgb(255, 252, 252),
    rgb(255, 247, 247),
    rgb(255, 219, 220),
    rgb(254, 235, 236),
    rgb(255, 205, 206),
    rgb(244, 169, 170),
    rgb(253, 189, 190),
    rgb(235, 142, 144),
    rgb(229, 72, 77),
    rgb(236, 83, 88),
    rgb(220, 62, 66),
    rgb(255, 255, 255),
    rgb(100, 23, 35),
    rgb(206, 44, 49)
  );
}
function plum() {
  return new ColourScale(
    rgb(254, 252, 255),
    rgb(253, 247, 253),
    rgb(247, 222, 248),
    rgb(251, 235, 251),
    rgb(242, 209, 243),
    rgb(222, 173, 227),
    rgb(233, 194, 236),
    rgb(207, 145, 216),
    rgb(171, 74, 186),
    rgb(177, 85, 191),
    rgb(161, 68, 175),
    rgb(255, 255, 255),
    rgb(83, 25, 93),
    rgb(149, 62, 163)
  );
}
function blue() {
  return new ColourScale(
    rgb(251, 253, 255),
    rgb(244, 250, 255),
    rgb(213, 239, 255),
    rgb(230, 244, 254),
    rgb(194, 229, 255),
    rgb(142, 200, 246),
    rgb(172, 216, 252),
    rgb(94, 177, 239),
    rgb(0, 144, 255),
    rgb(5, 148, 260),
    rgb(5, 136, 240),
    rgb(255, 255, 255),
    rgb(17, 50, 100),
    rgb(13, 116, 206)
  );
}
function green() {
  return new ColourScale(
    rgb(251, 254, 252),
    rgb(244, 251, 246),
    rgb(214, 241, 223),
    rgb(230, 246, 235),
    rgb(196, 232, 209),
    rgb(142, 206, 170),
    rgb(173, 221, 192),
    rgb(91, 185, 139),
    rgb(48, 164, 108),
    rgb(53, 173, 115),
    rgb(43, 154, 102),
    rgb(255, 255, 255),
    rgb(25, 59, 45),
    rgb(33, 131, 88)
  );
}
function yellow() {
  return new ColourScale(
    rgb(253, 253, 249),
    rgb(254, 252, 233),
    rgb(255, 243, 148),
    rgb(255, 250, 184),
    rgb(255, 231, 112),
    rgb(228, 199, 103),
    rgb(243, 215, 104),
    rgb(213, 174, 57),
    rgb(255, 230, 41),
    rgb(255, 234, 82),
    rgb(255, 220, 0),
    rgb(71, 59, 31),
    rgb(71, 59, 31),
    rgb(158, 108, 0)
  );
}
function default_light_palette() {
  return new ColourPalette(slate(), blue(), plum(), green(), yellow(), red());
}
function slate_dark() {
  return new ColourScale(
    rgb(24, 25, 27),
    rgb(17, 17, 19),
    rgb(39, 42, 45),
    rgb(33, 34, 37),
    rgb(46, 49, 53),
    rgb(67, 72, 78),
    rgb(54, 58, 63),
    rgb(90, 97, 105),
    rgb(105, 110, 119),
    rgb(91, 96, 105),
    rgb(119, 123, 132),
    rgb(255, 255, 255),
    rgb(237, 238, 240),
    rgb(176, 180, 186)
  );
}
function red_dark() {
  return new ColourScale(
    rgb(32, 19, 20),
    rgb(25, 17, 17),
    rgb(80, 15, 28),
    rgb(59, 18, 25),
    rgb(97, 22, 35),
    rgb(140, 51, 58),
    rgb(114, 35, 45),
    rgb(181, 69, 72),
    rgb(229, 72, 77),
    rgb(220, 52, 57),
    rgb(236, 93, 94),
    rgb(255, 255, 255),
    rgb(255, 209, 217),
    rgb(255, 149, 146)
  );
}
function plum_dark() {
  return new ColourScale(
    rgb(32, 19, 32),
    rgb(24, 17, 24),
    rgb(69, 29, 71),
    rgb(53, 26, 53),
    rgb(81, 36, 84),
    rgb(115, 64, 121),
    rgb(94, 48, 97),
    rgb(146, 84, 156),
    rgb(171, 74, 186),
    rgb(154, 68, 167),
    rgb(182, 88, 196),
    rgb(255, 255, 255),
    rgb(244, 212, 244),
    rgb(231, 150, 243)
  );
}
function blue_dark() {
  return new ColourScale(
    rgb(17, 25, 39),
    rgb(13, 21, 32),
    rgb(0, 51, 98),
    rgb(13, 40, 71),
    rgb(0, 64, 116),
    rgb(32, 93, 158),
    rgb(16, 77, 135),
    rgb(40, 112, 189),
    rgb(0, 144, 255),
    rgb(0, 110, 195),
    rgb(59, 158, 255),
    rgb(255, 255, 255),
    rgb(194, 230, 255),
    rgb(112, 184, 255)
  );
}
function green_dark() {
  return new ColourScale(
    rgb(18, 27, 23),
    rgb(14, 21, 18),
    rgb(17, 59, 41),
    rgb(19, 45, 33),
    rgb(23, 73, 51),
    rgb(40, 104, 74),
    rgb(32, 87, 62),
    rgb(47, 124, 87),
    rgb(48, 164, 108),
    rgb(44, 152, 100),
    rgb(51, 176, 116),
    rgb(255, 255, 255),
    rgb(177, 241, 203),
    rgb(61, 214, 140)
  );
}
function yellow_dark() {
  return new ColourScale(
    rgb(27, 24, 15),
    rgb(20, 18, 11),
    rgb(54, 43, 0),
    rgb(45, 35, 5),
    rgb(67, 53, 0),
    rgb(102, 84, 23),
    rgb(82, 66, 2),
    rgb(131, 106, 33),
    rgb(255, 230, 41),
    rgb(250, 220, 0),
    rgb(255, 255, 87),
    rgb(27, 24, 15),
    rgb(246, 238, 180),
    rgb(245, 225, 71)
  );
}
function default_dark_palette() {
  return new ColourPalette(
    slate_dark(),
    blue_dark(),
    plum_dark(),
    green_dark(),
    yellow_dark(),
    red_dark()
  );
}

// build/dev/javascript/lustre_ui/lustre/ui/theme.mjs
var Theme = class extends CustomType {
  constructor(id, selector, font, radius2, space, light, dark) {
    super();
    this.id = id;
    this.selector = selector;
    this.font = font;
    this.radius = radius2;
    this.space = space;
    this.light = light;
    this.dark = dark;
  }
};
var Fonts = class extends CustomType {
  constructor(heading, body, code2) {
    super();
    this.heading = heading;
    this.body = body;
    this.code = code2;
  }
};
var SizeScale = class extends CustomType {
  constructor(xs, sm, md, lg, xl, xl_2, xl_3) {
    super();
    this.xs = xs;
    this.sm = sm;
    this.md = md;
    this.lg = lg;
    this.xl = xl;
    this.xl_2 = xl_2;
    this.xl_3 = xl_3;
  }
};
var Global = class extends CustomType {
};
var Host = class extends CustomType {
};
var Class = class extends CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
};
function perfect_fifth(base) {
  return new SizeScale(
    divideFloat(divideFloat(divideFloat(base, 1.5), 1.5), 1.5),
    divideFloat(divideFloat(base, 1.5), 1.5),
    base,
    base * 1.5,
    base * 1.5 * 1.5,
    base * 1.5 * 1.5 * 1.5,
    base * 1.5 * 1.5 * 1.5 * 1.5
  );
}
function golden_ratio(base) {
  return new SizeScale(
    divideFloat(divideFloat(divideFloat(base, 1.618), 1.618), 1.618),
    divideFloat(divideFloat(base, 1.618), 1.618),
    base,
    base * 1.618,
    base * 1.618 * 1.618,
    base * 1.618 * 1.618 * 1.618,
    base * 1.618 * 1.618 * 1.618 * 1.618
  );
}
function with_scope(theme, selector) {
  let _record = theme;
  return new Theme(
    _record.id,
    selector,
    _record.font,
    _record.radius,
    _record.space,
    _record.light,
    _record.dark
  );
}
function to_css_selector(selector) {
  if (selector instanceof Global) {
    return "";
  } else if (selector instanceof Host) {
    return ":root, :host";
  } else if (selector instanceof Class) {
    let class$2 = selector[0];
    return "." + class$2;
  } else {
    let $ = selector[1];
    if ($ === "") {
      let name6 = selector[0];
      return "[data-" + name6 + "]";
    } else {
      let name6 = selector[0];
      let value3 = $;
      return "[data-" + name6 + "=" + value3 + "]";
    }
  }
}
function to_css_rgb(colour) {
  let $ = to_rgba(colour);
  let r = $[0];
  let g = $[1];
  let b = $[2];
  let _block;
  let _pipe = round2(r * 255);
  _block = to_string(_pipe);
  let r$1 = _block;
  let _block$1;
  let _pipe$1 = round2(g * 255);
  _block$1 = to_string(_pipe$1);
  let g$1 = _block$1;
  let _block$2;
  let _pipe$2 = round2(b * 255);
  _block$2 = to_string(_pipe$2);
  let b$1 = _block$2;
  return r$1 + " " + g$1 + " " + b$1;
}
function var$(name6) {
  return "--lustre-ui-" + name6;
}
function to_css_variable(name6, value3) {
  return var$(name6) + ":" + value3 + ";";
}
function to_colour_scale_variables(scale, name6) {
  return concat2(
    toList([
      to_css_variable(name6 + "-bg", to_css_rgb(scale.bg)),
      to_css_variable(name6 + "-bg-subtle", to_css_rgb(scale.bg_subtle)),
      to_css_variable(name6 + "-tint", to_css_rgb(scale.tint)),
      to_css_variable(name6 + "-tint-subtle", to_css_rgb(scale.tint_subtle)),
      to_css_variable(name6 + "-tint-strong", to_css_rgb(scale.tint_strong)),
      to_css_variable(name6 + "-accent", to_css_rgb(scale.accent)),
      to_css_variable(name6 + "-accent-subtle", to_css_rgb(scale.accent_subtle)),
      to_css_variable(name6 + "-accent-strong", to_css_rgb(scale.accent_strong)),
      to_css_variable(name6 + "-solid", to_css_rgb(scale.solid)),
      to_css_variable(name6 + "-solid-subtle", to_css_rgb(scale.solid_subtle)),
      to_css_variable(name6 + "-solid-strong", to_css_rgb(scale.solid_strong)),
      to_css_variable(name6 + "-solid-text", to_css_rgb(scale.solid_text)),
      to_css_variable(name6 + "-text", to_css_rgb(scale.text)),
      to_css_variable(name6 + "-text-subtle", to_css_rgb(scale.text_subtle)),
      "& ." + name6 + ', [data-scale="' + name6 + '"] {',
      "--lustre-ui-bg: var(--lustre-ui-" + name6 + "-bg);",
      "--lustre-ui-bg-subtle: var(--lustre-ui-" + name6 + "-bg-subtle);",
      "--lustre-ui-tint: var(--lustre-ui-" + name6 + "-tint);",
      "--lustre-ui-tint-subtle: var(--lustre-ui-" + name6 + "-tint-subtle);",
      "--lustre-ui-tint-strong: var(--lustre-ui-" + name6 + "-tint-strong);",
      "--lustre-ui-accent: var(--lustre-ui-" + name6 + "-accent);",
      "--lustre-ui-accent-subtle: var(--lustre-ui-" + name6 + "-accent-subtle);",
      "--lustre-ui-accent-strong: var(--lustre-ui-" + name6 + "-accent-strong);",
      "--lustre-ui-solid: var(--lustre-ui-" + name6 + "-solid);",
      "--lustre-ui-solid-subtle: var(--lustre-ui-" + name6 + "-solid-subtle);",
      "--lustre-ui-solid-strong: var(--lustre-ui-" + name6 + "-solid-strong);",
      "--lustre-ui-solid-text: var(--lustre-ui-" + name6 + "-solid-text);",
      "--lustre-ui-text: var(--lustre-ui-" + name6 + "-text);",
      "--lustre-ui-text-subtle: var(--lustre-ui-" + name6 + "-text-subtle);",
      "}"
    ])
  );
}
function to_color_palette_variables(palette, scheme) {
  return concat2(
    toList([
      to_css_variable("color-scheme", scheme),
      to_colour_scale_variables(palette.base, "base"),
      to_colour_scale_variables(palette.primary, "primary"),
      to_colour_scale_variables(palette.secondary, "secondary"),
      to_colour_scale_variables(palette.success, "success"),
      to_colour_scale_variables(palette.warning, "warning"),
      to_colour_scale_variables(palette.danger, "danger"),
      "--lustre-ui-bg: var(--lustre-ui-base-bg);",
      "--lustre-ui-bg-subtle: var(--lustre-ui-base-bg-subtle);",
      "--lustre-ui-tint: var(--lustre-ui-base-tint);",
      "--lustre-ui-tint-subtle: var(--lustre-ui-base-tint-subtle);",
      "--lustre-ui-tint-strong: var(--lustre-ui-base-tint-strong);",
      "--lustre-ui-accent: var(--lustre-ui-base-accent);",
      "--lustre-ui-accent-subtle: var(--lustre-ui-base-accent-subtle);",
      "--lustre-ui-accent-strong: var(--lustre-ui-base-accent-strong);",
      "--lustre-ui-solid: var(--lustre-ui-base-solid);",
      "--lustre-ui-solid-subtle: var(--lustre-ui-base-solid-subtle);",
      "--lustre-ui-solid-strong: var(--lustre-ui-base-solid-strong);",
      "--lustre-ui-solid-text: var(--lustre-ui-base-solid-text);",
      "--lustre-ui-text: var(--lustre-ui-base-text);",
      "--lustre-ui-text-subtle: var(--lustre-ui-base-text-subtle);"
    ])
  );
}
function to_css_variables(theme) {
  return concat2(
    toList([
      to_css_variable("id", theme.id),
      to_css_variable("font-heading", theme.font.heading),
      to_css_variable("font-body", theme.font.body),
      to_css_variable("font-code", theme.font.code),
      to_css_variable("radius-xs", float_to_string(theme.radius.xs) + "rem"),
      to_css_variable("radius-sm", float_to_string(theme.radius.sm) + "rem"),
      to_css_variable("radius-md", float_to_string(theme.radius.md) + "rem"),
      to_css_variable("radius-lg", float_to_string(theme.radius.lg) + "rem"),
      to_css_variable("radius-xl", float_to_string(theme.radius.xl) + "rem"),
      to_css_variable(
        "radius-xl-2",
        float_to_string(theme.radius.xl_2) + "rem"
      ),
      to_css_variable(
        "radius-xl-3",
        float_to_string(theme.radius.xl_3) + "rem"
      ),
      to_css_variable("spacing-xs", float_to_string(theme.space.xs) + "rem"),
      to_css_variable("spacing-sm", float_to_string(theme.space.sm) + "rem"),
      to_css_variable("spacing-md", float_to_string(theme.space.md) + "rem"),
      to_css_variable("spacing-lg", float_to_string(theme.space.lg) + "rem"),
      to_css_variable("spacing-xl", float_to_string(theme.space.xl) + "rem"),
      to_css_variable(
        "spacing-xl-2",
        float_to_string(theme.space.xl_2) + "rem"
      ),
      to_css_variable(
        "spacing-xl-3",
        float_to_string(theme.space.xl_3) + "rem"
      ),
      to_color_palette_variables(theme.light, "light")
    ])
  );
}
var sans = 'ui-sans-serif, system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, "Noto Sans", sans-serif, "Apple Color Emoji", "Segoe UI Emoji", "Segoe UI Symbol", "Noto Color Emoji"';
var code = 'ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, "Liberation Mono", "Courier New", monospace';
var stylesheet_global_light_no_dark = "\nbody {\n  ${rules}\n\n  background-color: rgb(var(--lustre-ui-bg));\n  color: rgb(var(--lustre-ui-text));\n  font-family: ${fonts.body}\n}\n\nh1, h2, h3, h4, h5, h6 {\n  font-family: ${fonts.heading}\n}\n\npre, code, kbd, samp {\n  font-family: ${fonts.code}\n}\n";
var stylesheet_global_light_global_dark = "\nbody {\n  ${rules}\n\n  background-color: rgb(var(--lustre-ui-bg));\n  color: rgb(var(--lustre-ui-text));\n  font-family: ${fonts.body}\n}\n\nh1, h2, h3, h4, h5, h6 {\n  font-family: ${fonts.heading}\n}\n\npre, code, kbd, samp {\n  font-family: ${fonts.code}\n}\n\n@media (prefers-color-scheme: dark) {\n  body {\n    ${dark_rules}\n  }\n}\n";
var stylesheet_global_light_scoped_dark = "\nbody {\n  ${rules}\n\n  background-color: rgb(var(--lustre-ui-bg));\n  color: rgb(var(--lustre-ui-text));\n  font-family: ${fonts.body}\n}\n\nh1, h2, h3, h4, h5, h6 {\n  font-family: ${fonts.heading}\n}\n\npre, code, kbd, samp {\n  font-family: ${fonts.code}\n}\n\nbody${dark_selector}, body ${dark_selector} {\n  ${dark_rules}\n}\n\n@media (prefers-color-scheme: dark) {\n  body {\n    ${dark_rules}\n  }\n}\n";
var stylesheet_scoped_light_no_dark = "\n${selector} {\n  ${rules}\n\n  background-color: rgb(var(--lustre-ui-bg));\n  color: rgb(var(--lustre-ui-text));\n  font-family: ${fonts.body}\n}\n\n${selector} :is(h1, h2, h3, h4, h5, h6) {\n  font-family: ${fonts.heading}\n}\n\n${selector} :is(pre, code, kbd, samp) {\n  font-family: ${fonts.code}\n}\n";
var stylesheet_scoped_light_global_dark = "\n${selector} {\n  ${rules}\n\n  background-color: rgb(var(--lustre-ui-bg));\n  color: rgb(var(--lustre-ui-text));\n  font-family: ${fonts.body}\n}\n\n${selector} :is(h1, h2, h3, h4, h5, h6) {\n  font-family: ${fonts.heading}\n}\n\n${selector} :is(pre, code, kbd, samp) {\n  font-family: ${fonts.code}\n}\n\n@media (prefers-color-scheme: dark) {\n  ${selector} {\n    ${dark_rules}\n  }\n}\n";
var stylesheet_scoped_light_scoped_dark = "\n${selector} {\n  ${rules}\n\n  background-color: rgb(var(--lustre-ui-bg));\n  color: rgb(var(--lustre-ui-text));\n  font-family: ${fonts.body}\n}\n\n${selector} :is(h1, h2, h3, h4, h5, h6) {\n  font-family: ${fonts.heading}\n}\n\n${selector} :is(pre, code, kbd, samp) {\n  font-family: ${fonts.code}\n}\n\n${selector}${dark_selector}, ${selector} ${dark_selector} {\n  ${dark_rules}\n}\n\n@media (prefers-color-scheme: dark) {\n  ${selector} {\n    ${dark_rules}\n  }\n}\n";
function to_style(theme) {
  let data_attr = attribute2("data-lustre-ui-theme", theme.id);
  let $ = theme.selector;
  let $1 = theme.dark;
  if ($1 instanceof Some) {
    let $2 = $1[0][0];
    if ($2 instanceof Global) {
      if ($ instanceof Global) {
        let dark_palette = $1[0][1];
        let _pipe = stylesheet_global_light_global_dark;
        let _pipe$1 = replace(
          _pipe,
          "${rules}",
          to_css_variables(theme)
        );
        let _pipe$2 = replace(
          _pipe$1,
          "${dark_rules}",
          to_color_palette_variables(dark_palette, "dark")
        );
        let _pipe$3 = replace(
          _pipe$2,
          "${fonts.heading}",
          theme.font.heading
        );
        let _pipe$4 = replace(_pipe$3, "${fonts.body}", theme.font.body);
        let _pipe$5 = replace(_pipe$4, "${fonts.code}", theme.font.code);
        return ((_capture) => {
          return style2(toList([data_attr]), _capture);
        })(_pipe$5);
      } else {
        let selector = $;
        let dark_palette = $1[0][1];
        let _pipe = stylesheet_scoped_light_global_dark;
        let _pipe$1 = replace(
          _pipe,
          "${selector}",
          to_css_selector(selector)
        );
        let _pipe$2 = replace(
          _pipe$1,
          "${rules}",
          to_css_variables(theme)
        );
        let _pipe$3 = replace(
          _pipe$2,
          "${dark_rules}",
          to_color_palette_variables(dark_palette, "dark")
        );
        let _pipe$4 = replace(
          _pipe$3,
          "${fonts.heading}",
          theme.font.heading
        );
        let _pipe$5 = replace(_pipe$4, "${fonts.body}", theme.font.body);
        let _pipe$6 = replace(_pipe$5, "${fonts.code}", theme.font.code);
        return ((_capture) => {
          return style2(toList([data_attr]), _capture);
        })(_pipe$6);
      }
    } else if ($ instanceof Global) {
      let dark_selector = $2;
      let dark_palette = $1[0][1];
      let _pipe = stylesheet_global_light_scoped_dark;
      let _pipe$1 = replace(_pipe, "${rules}", to_css_variables(theme));
      let _pipe$2 = replace(
        _pipe$1,
        "${dark_selector}",
        to_css_selector(dark_selector)
      );
      let _pipe$3 = replace(
        _pipe$2,
        "${dark_rules}",
        to_color_palette_variables(dark_palette, "dark")
      );
      let _pipe$4 = replace(
        _pipe$3,
        "${fonts.heading}",
        theme.font.heading
      );
      let _pipe$5 = replace(_pipe$4, "${fonts.body}", theme.font.body);
      let _pipe$6 = replace(_pipe$5, "${fonts.code}", theme.font.code);
      return ((_capture) => {
        return style2(toList([data_attr]), _capture);
      })(_pipe$6);
    } else {
      let selector = $;
      let dark_selector = $2;
      let dark_palette = $1[0][1];
      let _pipe = stylesheet_scoped_light_scoped_dark;
      let _pipe$1 = replace(
        _pipe,
        "${selector}",
        to_css_selector(selector)
      );
      let _pipe$2 = replace(
        _pipe$1,
        "${rules}",
        to_css_variables(theme)
      );
      let _pipe$3 = replace(
        _pipe$2,
        "${dark_selector}",
        to_css_selector(dark_selector)
      );
      let _pipe$4 = replace(
        _pipe$3,
        "${dark_rules}",
        to_color_palette_variables(dark_palette, "dark")
      );
      let _pipe$5 = replace(
        _pipe$4,
        "${fonts.heading}",
        theme.font.heading
      );
      let _pipe$6 = replace(_pipe$5, "${fonts.body}", theme.font.body);
      let _pipe$7 = replace(_pipe$6, "${fonts.code}", theme.font.code);
      return ((_capture) => {
        return style2(toList([data_attr]), _capture);
      })(_pipe$7);
    }
  } else if ($ instanceof Global) {
    let _pipe = stylesheet_global_light_no_dark;
    let _pipe$1 = replace(_pipe, "${rules}", to_css_variables(theme));
    let _pipe$2 = replace(
      _pipe$1,
      "${fonts.heading}",
      theme.font.heading
    );
    let _pipe$3 = replace(_pipe$2, "${fonts.body}", theme.font.body);
    let _pipe$4 = replace(_pipe$3, "${fonts.code}", theme.font.code);
    return ((_capture) => {
      return style2(toList([data_attr]), _capture);
    })(
      _pipe$4
    );
  } else {
    let selector = $;
    let _pipe = stylesheet_scoped_light_no_dark;
    let _pipe$1 = replace(
      _pipe,
      "${selector}",
      to_css_selector(selector)
    );
    let _pipe$2 = replace(_pipe$1, "${rules}", to_css_variables(theme));
    let _pipe$3 = replace(
      _pipe$2,
      "${fonts.heading}",
      theme.font.heading
    );
    let _pipe$4 = replace(_pipe$3, "${fonts.body}", theme.font.body);
    let _pipe$5 = replace(_pipe$4, "${fonts.code}", theme.font.code);
    return ((_capture) => {
      return style2(toList([data_attr]), _capture);
    })(
      _pipe$5
    );
  }
}
function inject(theme, view8) {
  return fragment2(toList([to_style(theme), view8()]));
}
function default$() {
  let id = "lustre-ui-default";
  let font$1 = new Fonts(sans, sans, code);
  let radius$1 = perfect_fifth(0.75);
  let space = golden_ratio(1);
  let light = default_light_palette();
  let dark = default_dark_palette();
  return new Theme(
    id,
    new Global(),
    font$1,
    radius$1,
    space,
    light,
    new Some([new Class("dark"), dark])
  );
}

// build/dev/javascript/lustre_ui/lustre/ui/accordion_stories.mjs
function faq_story() {
  return story2(
    "FAQ",
    () => {
      return scene(
        (_) => {
          return inject(
            (() => {
              let _pipe = default$();
              return with_scope(_pipe, new Host());
            })(),
            () => {
              return element5(
                toList([]),
                toList([
                  item(
                    "q1",
                    "What is an accordion?",
                    toList([
                      text3(
                        "An interactive element for showing/hiding content"
                      )
                    ])
                  ),
                  item(
                    "q2",
                    "When should I use one?",
                    toList([
                      text3(
                        "When you want to organize content into sections"
                      )
                    ])
                  )
                ])
              );
            }
          );
        }
      );
    }
  );
}
function all2() {
  return chapter("Accordion", toList([faq_story()]));
}

// build/dev/javascript/lustre_ui/lustre/ui/alert.mjs
function of(element15, attributes, children) {
  return element15(
    prepend(
      role("alert"),
      prepend(class$("lustre-ui-alert"), attributes)
    ),
    children
  );
}
function element6(attributes, children) {
  return of(div, attributes, children);
}
function indicator(icon2) {
  return span(
    toList([
      class$("alert-indicator"),
      role("presentation")
    ]),
    toList([icon2])
  );
}
function title2(attributes, children) {
  return header(
    prepend(class$("alert-title"), attributes),
    children
  );
}
function content(attributes, children) {
  return section(
    prepend(class$("alert-content"), attributes),
    children
  );
}
function danger() {
  return class$("danger");
}
function success2() {
  return class$("success");
}

// build/dev/javascript/lustre_ui/lustre/ui/alert_stories.mjs
var FILEPATH4 = "dev/lustre/ui/alert_stories.gleam";
function title_only_success_alert_story() {
  return story2(
    "Title only, success",
    () => {
      return scene(
        (_) => {
          return inject(
            (() => {
              let _pipe = default$();
              return with_scope(_pipe, new Host());
            })(),
            () => {
              return element6(
                toList([success2()]),
                toList([
                  title2(
                    toList([]),
                    toList([text3("New todo added to your list.")])
                  )
                ])
              );
            }
          );
        }
      );
    }
  );
}
function title_indicator_content_error_alert_story() {
  return story2(
    "Title + indicator + content, error",
    () => {
      return scene(
        (_) => {
          return inject(
            (() => {
              let _pipe = default$();
              return with_scope(_pipe, new Host());
            })(),
            () => {
              return element6(
                toList([danger()]),
                toList([
                  indicator(exclamation_triangle(toList([]))),
                  title2(
                    toList([]),
                    toList([text3("Could not delete todo")])
                  ),
                  content(
                    toList([]),
                    toList([
                      p(
                        toList([]),
                        toList([
                          text3(
                            "Check your internet connection and try again."
                          )
                        ])
                      )
                    ])
                  )
                ])
              );
            }
          );
        }
      );
    }
  );
}
function all3() {
  let $ = register3();
  if (!($ instanceof Ok)) {
    throw makeError(
      "let_assert",
      FILEPATH4,
      "lustre/ui/alert_stories",
      13,
      "all",
      "Pattern match failed, no pattern matched the value.",
      { value: $, start: 339, end: 378, pattern_start: 350, pattern_end: 355 }
    );
  }
  return chapter(
    "Alert",
    toList([
      title_only_success_alert_story(),
      title_indicator_content_error_alert_story()
    ])
  );
}

// build/dev/javascript/lustre_ui/lustre/ui/badge.mjs
function of2(element15, attributes, children) {
  return element15(
    prepend(class$("lustre-ui-badge"), attributes),
    children
  );
}
function element7(attributes, children) {
  return of2(small, attributes, children);
}
function solid() {
  return class$("badge-solid");
}
function background(value3) {
  return style("--background", value3);
}

// build/dev/javascript/lustre_ui/lustre/ui/badge_stories.mjs
function online_avatar_story() {
  return story2(
    "Online Avatar Indicator",
    () => {
      return scene(
        (_) => {
          return inject(
            (() => {
              let _pipe = default$();
              return with_scope(_pipe, new Host());
            })(),
            () => {
              return div(
                toList([class$("inline-block relative")]),
                toList([
                  img(
                    toList([
                      class$("h-10 w-10 rounded-full"),
                      src("https://placehold.co/100"),
                      alt("Avatar")
                    ])
                  ),
                  element7(
                    toList([
                      background("green"),
                      solid(),
                      class$("absolute top-0 right-0"),
                      title("online")
                    ]),
                    toList([])
                  )
                ])
              );
            }
          );
        }
      );
    }
  );
}
function all4() {
  return chapter("Badge", toList([online_avatar_story()]));
}

// build/dev/javascript/lustre_ui/lustre/ui/breadcrumb.mjs
function element8(attributes, children) {
  return nav(
    toList([attribute2("aria-label", "breadcrumb")]),
    toList([
      ol(
        prepend(class$("lustre-ui-breadcrumb"), attributes),
        children
      )
    ])
  );
}
function item2(attributes, children) {
  return li(
    prepend(class$("breadcrumb-item"), attributes),
    children
  );
}
function current(attributes, children) {
  return span(
    prepend(
      class$("breadcrumb-item breadcrumb-current"),
      prepend(
        role("link"),
        prepend(
          attribute2("aria-disabled", "true"),
          prepend(attribute2("aria-current", "page"), attributes)
        )
      )
    ),
    children
  );
}
function separator(attributes, content3) {
  return li(
    prepend(
      class$("breadcrumb-separator"),
      prepend(
        role("presentation"),
        prepend(attribute2("aria-hidden", "true"), attributes)
      )
    ),
    toList([content3])
  );
}
function chevron(attributes) {
  return separator(attributes, chevron_right(toList([])));
}
function slash2(attributes) {
  return separator(attributes, slash(toList([])));
}
function ellipsis(attributes, label2) {
  return span(
    prepend(
      class$("breadcrumb-ellipsis"),
      prepend(role("presentation"), attributes)
    ),
    toList([
      dots_horizontal(toList([])),
      span(toList([]), toList([text3(label2)]))
    ])
  );
}

// build/dev/javascript/lustre_ui/lustre/ui/breadcrumb_stories.mjs
function basic_breadcrumb_story() {
  return story2(
    "Basic Breadcrumb Navigation",
    () => {
      return scene(
        (_) => {
          return inject(
            (() => {
              let _pipe = default$();
              return with_scope(_pipe, new Host());
            })(),
            () => {
              return element8(
                toList([]),
                toList([
                  item2(
                    toList([]),
                    toList([
                      a(
                        toList([href("/")]),
                        toList([text3("Home")])
                      )
                    ])
                  ),
                  chevron(toList([])),
                  item2(
                    toList([]),
                    toList([
                      a(
                        toList([href("/documents")]),
                        toList([text3("Documents")])
                      )
                    ])
                  ),
                  chevron(toList([])),
                  current(
                    toList([]),
                    toList([text3("My Document")])
                  )
                ])
              );
            }
          );
        }
      );
    }
  );
}
function breadcrumb_with_collapsed_items_story() {
  return story2(
    "Breadcrumb with Collapsed Items",
    () => {
      return scene(
        (_) => {
          return inject(
            (() => {
              let _pipe = default$();
              return with_scope(_pipe, new Host());
            })(),
            () => {
              return element8(
                toList([]),
                toList([
                  item2(
                    toList([]),
                    toList([
                      a(
                        toList([href("/")]),
                        toList([text3("Home")])
                      )
                    ])
                  ),
                  slash2(toList([])),
                  ellipsis(toList([]), "Collapsed navigation items"),
                  slash2(toList([])),
                  current(
                    toList([]),
                    toList([text3("My Document")])
                  )
                ])
              );
            }
          );
        }
      );
    }
  );
}
function all5() {
  return chapter(
    "Breadcrumb",
    toList([basic_breadcrumb_story(), breadcrumb_with_collapsed_items_story()])
  );
}

// build/dev/javascript/lustre_ui/lustre/ui/button.mjs
function of3(element15, attributes, children) {
  return element15(
    prepend(
      class$("lustre-ui-button"),
      prepend(role("button"), attributes)
    ),
    children
  );
}
function element9(attributes, children) {
  return of3(
    button,
    prepend(attribute2("tabindex", "0"), attributes),
    children
  );
}
function shortcut_badge(attributes, chord) {
  return span(
    prepend(
      class$("button-badge"),
      prepend(title(join(chord, "+")), attributes)
    ),
    map(
      chord,
      (key) => {
        return span(
          toList([class$("key")]),
          toList([text3(key)])
        );
      }
    )
  );
}
function danger2() {
  return class$("danger");
}
function clear() {
  return class$("button-clear");
}
function solid2() {
  return class$("button-solid");
}

// build/dev/javascript/lustre_ui/lustre/ui/button_stories.mjs
function basic_button_story() {
  return story2(
    "Basic Button with Icon and Text",
    () => {
      return scene(
        (_) => {
          return inject(
            (() => {
              let _pipe = default$();
              return with_scope(_pipe, new Host());
            })(),
            () => {
              return element9(
                toList([]),
                toList([bookmark(toList([])), text3(" Save")])
              );
            }
          );
        }
      );
    }
  );
}
function command_palette_button_story() {
  return story2(
    "Command Palette Button with Keyboard Shortcut",
    () => {
      return scene(
        (_) => {
          return inject(
            (() => {
              let _pipe = default$();
              return with_scope(_pipe, new Host());
            })(),
            () => {
              return element9(
                toList([solid2()]),
                toList([
                  text3("Open"),
                  shortcut_badge(toList([]), toList(["\u2318", "k"]))
                ])
              );
            }
          );
        }
      );
    }
  );
}
function all6() {
  return chapter(
    "Button",
    toList([basic_button_story(), command_palette_button_story()])
  );
}

// build/dev/javascript/lustre_ui/lustre/ui/card.mjs
function of4(element15, attributes, children) {
  return element15(
    prepend(class$("lustre-ui-card"), attributes),
    children
  );
}
function element10(attributes, children) {
  return of4(article, attributes, children);
}
function header2(attributes, children) {
  return header(
    prepend(class$("card-header"), attributes),
    children
  );
}
function content2(attributes, children) {
  return main(
    prepend(class$("card-content"), attributes),
    children
  );
}
function footer2(attributes, children) {
  return footer(
    prepend(class$("card-footer"), attributes),
    children
  );
}

// build/dev/javascript/lustre_ui/lustre/ui/card_stories.mjs
function basic_card_story() {
  return story2(
    "Basic Content Card with Header and Content",
    () => {
      return scene(
        (_) => {
          return inject(
            (() => {
              let _pipe = default$();
              return with_scope(_pipe, new Host());
            })(),
            () => {
              return element10(
                toList([]),
                toList([
                  header2(
                    toList([]),
                    toList([
                      h2(
                        toList([]),
                        toList([text3("Easy Chocolate Chip Cookies")])
                      )
                    ])
                  ),
                  content2(
                    toList([]),
                    toList([
                      p(
                        toList([]),
                        toList([
                          text3(
                            "A simple recipe for delicious chocolate chip cookies that are crisp at the edges and chewy in the middle."
                          )
                        ])
                      )
                    ])
                  )
                ])
              );
            }
          );
        }
      );
    }
  );
}
function dialog_card_story() {
  return story2(
    "Dialog-Style Card with Footer Actions",
    () => {
      return scene(
        (_) => {
          return inject(
            (() => {
              let _pipe = default$();
              return with_scope(_pipe, new Host());
            })(),
            () => {
              return element10(
                toList([]),
                toList([
                  header2(
                    toList([]),
                    toList([text3("Delete recipe?")])
                  ),
                  content2(
                    toList([]),
                    toList([
                      p(
                        toList([]),
                        toList([
                          text3(
                            "Are you sure that you want to delete this recipe?"
                          )
                        ])
                      )
                    ])
                  ),
                  footer2(
                    toList([]),
                    toList([
                      element9(
                        toList([clear()]),
                        toList([text3("Cancel")])
                      ),
                      element9(
                        toList([solid2(), danger2()]),
                        toList([text3("Delete")])
                      )
                    ])
                  )
                ])
              );
            }
          );
        }
      );
    }
  );
}
function all7() {
  return chapter(
    "Card",
    toList([basic_card_story(), dialog_card_story()])
  );
}

// build/dev/javascript/lustre_ui/lustre/ui/input.mjs
function element11(attributes) {
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
function gap(value3) {
  return style("--gap", value3);
}
function on_open(handler) {
  return on("open", success(handler));
}
function on_close(handler) {
  return on("close", success(handler));
}
function init6(_) {
  let model = new Collapsed();
  let effect = batch(toList([set_pseudo_state2("collapsed")]));
  return [model, effect];
}
function tick2() {
  return after_paint(
    (dispatch2, _) => {
      return dispatch2(new SchedulerDidTick());
    }
  );
}
function update5(model, msg) {
  let $ = echo2(msg, "src/lustre/ui/primitives/popover.gleam", 162);
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
function handle_keydown3() {
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
      on("keydown", handle_keydown3())
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
function view6(model) {
  return div(
    toList([style("position", "relative")]),
    toList([view_trigger2(), view_popover(model)])
  );
}
var name4 = "lustre-ui-popover";
function register4() {
  let app = component(
    init6,
    update5,
    view6,
    toList([
      adopt_styles(true),
      on_attribute_change(
        "aria-expanded",
        (value3) => {
          if (value3 === "true") {
            return new Ok(new ParentSetOpen(true));
          } else if (value3 === "") {
            return new Ok(new ParentSetOpen(true));
          } else if (value3 === "false") {
            return new Ok(new ParentSetOpen(false));
          } else {
            return new Error(void 0);
          }
        }
      )
    ])
  );
  return make_component(app, name4);
}
function element12(attributes, trigger, content3) {
  return element2(
    name4,
    attributes,
    toList([
      div(toList([attribute2("slot", "trigger")]), toList([trigger])),
      div(toList([attribute2("slot", "popover")]), toList([content3]))
    ])
  );
}
function echo2(value3, file, line) {
  const grey = "\x1B[90m";
  const reset_color = "\x1B[39m";
  const file_line = `${file}:${line}`;
  const string_value = echo$inspect2(value3);
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
  return value3;
}
function echo$inspectString2(str) {
  let new_str = '"';
  for (let i = 0; i < str.length; i++) {
    let char = str[i];
    if (char == "\n") new_str += "\\n";
    else if (char == "\r") new_str += "\\r";
    else if (char == "	") new_str += "\\t";
    else if (char == "\f") new_str += "\\f";
    else if (char == "\\") new_str += "\\\\";
    else if (char == '"') new_str += '\\"';
    else if (char < " " || char > "~" && char < "\xA0") {
      new_str += "\\u{" + char.charCodeAt(0).toString(16).toUpperCase().padStart(4, "0") + "}";
    } else {
      new_str += char;
    }
  }
  new_str += '"';
  return new_str;
}
function echo$inspectDict2(map6) {
  let body = "dict.from_list([";
  let first3 = true;
  let key_value_pairs = [];
  map6.forEach((value3, key) => {
    key_value_pairs.push([key, value3]);
  });
  key_value_pairs.sort();
  key_value_pairs.forEach(([key, value3]) => {
    if (!first3) body = body + ", ";
    body = body + "#(" + echo$inspect2(key) + ", " + echo$inspect2(value3) + ")";
    first3 = false;
  });
  return body + "])";
}
function echo$inspectCustomType2(record) {
  const props = globalThis.Object.keys(record).map((label2) => {
    const value3 = echo$inspect2(record[label2]);
    return isNaN(parseInt(label2)) ? `${label2}: ${value3}` : value3;
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
  if (v === true) return "True";
  if (v === false) return "False";
  if (v === null) return "//js(null)";
  if (v === void 0) return "Nil";
  if (t === "string") return echo$inspectString2(v);
  if (t === "bigint" || t === "number") return v.toString();
  if (globalThis.Array.isArray(v))
    return `#(${v.map(echo$inspect2).join(", ")})`;
  if (v instanceof List)
    return `[${v.toArray().map(echo$inspect2).join(", ")}]`;
  if (v instanceof UtfCodepoint)
    return `//utfcodepoint(${String.fromCodePoint(v.value)})`;
  if (v instanceof BitArray) return echo$inspectBitArray2(v);
  if (v instanceof CustomType) return echo$inspectCustomType2(v);
  if (echo$isDict2(v)) return echo$inspectDict2(v);
  if (v instanceof Set)
    return `//js(Set(${[...v].map(echo$inspect2).join(", ")}))`;
  if (v instanceof RegExp) return `//js(${v})`;
  if (v instanceof Date) return `//js(Date("${v.toISOString()}"))`;
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
function echo$isDict2(value3) {
  try {
    return value3 instanceof Dict;
  } catch {
    return false;
  }
}

// build/dev/javascript/lustre_ui/lustre/ui/combobox.mjs
var FILEPATH5 = "src/lustre/ui/combobox.gleam";
var Item2 = class extends CustomType {
  constructor(value3, label2, content3) {
    super();
    this.value = value3;
    this.label = label2;
    this.content = content3;
  }
};
var Model5 = class extends CustomType {
  constructor(expanded2, value3, placeholder2, query, intent, intent_strategy, options) {
    super();
    this.expanded = expanded2;
    this.value = value3;
    this.placeholder = placeholder2;
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
var Options4 = class extends CustomType {
  constructor(all10, filtered, lookup_label, lookup_index) {
    super();
    this.all = all10;
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
  constructor(input3) {
    super();
    this.input = input3;
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
function option2(value3, label2) {
  return new Item2(value3, label2, toList([]));
}
function value2(value3) {
  return value(value3);
}
function on_change3(handler) {
  return on(
    "change",
    subfield(
      toList(["detail", "value"]),
      string2,
      (value3) => {
        return success(handler(value3));
      }
    )
  );
}
function init7(_) {
  let model = new Model5(
    false,
    "",
    "Select an option...",
    "",
    new None(),
    new ByIndex(),
    new Options4(toList([]), toList([]), new$8(), new$8())
  );
  let effect = batch(toList([set_pseudo_state2("empty")]));
  return [model, effect];
}
function contains_query(option3, query) {
  let _pipe = option3.label;
  let _pipe$1 = lowercase(_pipe);
  return contains_string(_pipe$1, query);
}
function intent_from_query(query, strategy, options) {
  return guard(
    query === "",
    new None(),
    () => {
      let query$1 = lowercase(query);
      let compare_options = (a2, b) => {
        let a_label = lowercase(a2.label);
        let b_label = lowercase(b.label);
        let a_starts = starts_with(a_label, query$1);
        let b_starts = starts_with(b_label, query$1);
        let $ = get4(options.lookup_index, a2.value);
        if (!($ instanceof Ok)) {
          throw makeError(
            "let_assert",
            FILEPATH5,
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
        let $1 = get4(options.lookup_index, b.value);
        if (!($1 instanceof Ok)) {
          throw makeError(
            "let_assert",
            FILEPATH5,
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
            return compare(a_index, b_index);
          } else {
            return compare(
              string_length(a_label),
              string_length(b_label)
            );
          }
        } else if (a_starts) {
          return new Lt();
        } else if (strategy instanceof ByIndex) {
          return compare(a_index, b_index);
        } else {
          return compare(string_length(a_label), string_length(b_label));
        }
      };
      let _pipe = options.all;
      let _pipe$1 = filter(
        _pipe,
        (_capture) => {
          return contains_query(_capture, query$1);
        }
      );
      let _pipe$2 = sort(_pipe$1, compare_options);
      let _pipe$3 = first(_pipe$2);
      let _pipe$4 = map3(_pipe$3, (option3) => {
        return option3.value;
      });
      return from_result(_pipe$4);
    }
  );
}
function update6(model, msg) {
  let $ = echo3(msg, "src/lustre/ui/combobox.gleam", 316);
  if ($ instanceof DomBlurredTrigger) {
    return [model, remove_pseudo_state2("trigger-focus")];
  } else if ($ instanceof DomFocusedTrigger) {
    return [model, set_pseudo_state2("trigger-focus")];
  } else if ($ instanceof ParentChangedChildren2) {
    let all10 = $[0];
    let lookup_label = from_list3(
      map(all10, (item3) => {
        return [item3.value, item3.label];
      })
    );
    let lookup_index = indexed(
      map(all10, (item3) => {
        return item3.value;
      })
    );
    let filtered = filter(
      all10,
      (option3) => {
        let _pipe = lowercase(option3.label);
        return contains_string(_pipe, lowercase(model.query));
      }
    );
    let options = new Options4(all10, filtered, lookup_label, lookup_index);
    let intent = new None();
    let _block;
    let _record = model;
    _block = new Model5(
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
        return new Model5(
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
        return new Model5(
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
    _block = new Model5(
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
    let input3 = $.input;
    let effect = after_paint(
      (_, _1) => {
        return focus3(input3);
      }
    );
    return [model, effect];
  } else if ($ instanceof UserChangedQuery) {
    let query = $[0];
    let filtered = filter(
      model.options.all,
      (option3) => {
        let _pipe = lowercase(option3.label);
        return contains_string(_pipe, lowercase(query));
      }
    );
    let _block;
    let _record = model.options;
    _block = new Options4(
      _record.all,
      filtered,
      _record.lookup_label,
      _record.lookup_index
    );
    let options = _block;
    let intent = intent_from_query(query, model.intent_strategy, model.options);
    let _block$1;
    let _record$1 = model;
    _block$1 = new Model5(
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
    _block = new Model5(
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
        return new Model5(
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
    _block = new Model5(
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
      let _pipe = min_inverse(model.options.lookup_index, compare);
      _block = from_result(_pipe);
    }
    let intent = _block;
    let _block$1;
    let _record = model;
    _block$1 = new Model5(
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
    let _pipe$1 = max_inverse(_pipe, compare);
    _block = from_result(_pipe$1);
    let intent = _block;
    let _block$1;
    let _record = model;
    _block$1 = new Model5(
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
    _block = new Model5(
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
          return focus3(trigger);
        })
      ])
    );
    return [model$1, effect];
  } else if ($ instanceof UserPressedHome2) {
    let event4 = $.event;
    let _block;
    let _pipe = model.options.lookup_index;
    let _pipe$1 = min_inverse(_pipe, compare);
    _block = from_result(_pipe$1);
    let intent = _block;
    let _block$1;
    let _record = model;
    _block$1 = new Model5(
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
      let _pipe = max_inverse(model.options.lookup_index, compare);
      _block = from_result(_pipe);
    }
    let intent = _block;
    let _block$1;
    let _record = model;
    _block$1 = new Model5(
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
      return get4(model.options.lookup_label, _capture);
    })(_pipe);
    _block = from_result(_pipe$1);
    let intent = _block;
    let _block$1;
    let _record = model;
    _block$1 = new Model5(
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
            (value3) => {
              return field(
                "textContent",
                string2,
                (label2) => {
                  return success([tag, value3, label2]);
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
        (acc, option3) => {
          let tag = option3[0];
          let value$1 = option3[1];
          let label2 = option3[2];
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
                    new Item2(value$1, label2, toList([])),
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
    (input3) => {
      if (will_open) {
        return success(new UserActivatedPopoverTrigger(input3));
      } else {
        return failure(new UserActivatedPopoverTrigger(input3), "");
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
        (input3) => {
          if (key === "Enter") {
            if (will_open) {
              return success(new UserActivatedPopoverTrigger(input3));
            } else {
              return failure(new UserActivatedPopoverTrigger(input3), "");
            }
          } else if (key === " ") {
            if (will_open) {
              return success(new UserActivatedPopoverTrigger(input3));
            } else {
              return failure(new UserActivatedPopoverTrigger(input3), "");
            }
          } else {
            return failure(new UserActivatedPopoverTrigger(input3), "");
          }
        }
      );
    }
  );
}
function view_trigger3(value3, placeholder2, options) {
  let _block;
  let _pipe = value3;
  let _pipe$1 = ((_capture) => {
    return get4(options.lookup_label, _capture);
  })(_pipe);
  _block = unwrap2(_pipe$1, placeholder2);
  let label2 = _block;
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
              if (label2 === "") {
                return "empty";
              } else {
                return "";
              }
            })()
          )
        ]),
        toList([text3(label2)])
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
      element11(
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
function element13(attributes, children) {
  return element3(
    name5,
    attributes,
    flat_map(
      children,
      (item3) => {
        let option$1 = element2(
          "lustre-ui-combobox-option",
          toList([value(item3.value)]),
          toList([text3(item3.label)])
        );
        return guard(
          is_empty(item3.content),
          toList([[item3.value, option$1]]),
          () => {
            return toList([
              [item3.value, option$1],
              [
                "option-" + item3.value,
                div(
                  toList([attribute2("slot", "option-" + item3.value)]),
                  item3.content
                )
              ]
            ]);
          }
        );
      }
    )
  );
}
function view_option(option3, value3, intent, last) {
  let is_selected = option3.value === value3;
  let is_intent = isEqual(new Some(option3.value), intent);
  let _block;
  if (is_selected) {
    _block = check2;
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
      attribute2("value", option3.value),
      on_mouse_over(new UserHoveredOption(option3.value)),
      on_mouse_down(new UserSelectedOption(option3.value))
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
            toList([name("option-" + option3.value)]),
            toList([text3(option3.label)])
          )
        ])
      )
    ])
  );
}
function do_view_options(options, value3, intent) {
  if (options instanceof Empty) {
    return toList([]);
  } else {
    let $ = options.tail;
    if ($ instanceof Empty) {
      let option$1 = options.head;
      return toList([
        [option$1.value, view_option(option$1, value3, intent, true)]
      ]);
    } else {
      let option$1 = options.head;
      let rest = $;
      return prepend(
        [option$1.label, view_option(option$1, value3, intent, false)],
        do_view_options(rest, value3, intent)
      );
    }
  }
}
function view_options(options, value3, intent) {
  return ul2(toList([]), do_view_options(options.filtered, value3, intent));
}
function view7(model) {
  return fragment2(
    toList([
      slot(
        toList([
          style("display", "none"),
          on("slotchange", handle_slot_change3())
        ]),
        toList([])
      ),
      element12(
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
function register5() {
  let $ = register4();
  if ($ instanceof Ok) {
    let app = component(
      init7,
      update6,
      view7,
      toList([
        adopt_styles(false),
        on_attribute_change(
          "value",
          (value3) => {
            return new Ok(new ParentSetValue(value3));
          }
        ),
        on_attribute_change(
          "placeholder",
          (value3) => {
            return new Ok(new ParentSetPlaceholder(value3));
          }
        ),
        on_attribute_change(
          "strategy",
          (value3) => {
            if (value3 === "by-length") {
              return new Ok(new ParentSetStrategy(new ByLength()));
            } else if (value3 === "by-index") {
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
        init7,
        update6,
        view7,
        toList([
          adopt_styles(false),
          on_attribute_change(
            "value",
            (value3) => {
              return new Ok(new ParentSetValue(value3));
            }
          ),
          on_attribute_change(
            "placeholder",
            (value3) => {
              return new Ok(new ParentSetPlaceholder(value3));
            }
          ),
          on_attribute_change(
            "strategy",
            (value3) => {
              if (value3 === "by-length") {
                return new Ok(new ParentSetStrategy(new ByLength()));
              } else if (value3 === "by-index") {
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
function echo3(value3, file, line) {
  const grey = "\x1B[90m";
  const reset_color = "\x1B[39m";
  const file_line = `${file}:${line}`;
  const string_value = echo$inspect3(value3);
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
  return value3;
}
function echo$inspectString3(str) {
  let new_str = '"';
  for (let i = 0; i < str.length; i++) {
    let char = str[i];
    if (char == "\n") new_str += "\\n";
    else if (char == "\r") new_str += "\\r";
    else if (char == "	") new_str += "\\t";
    else if (char == "\f") new_str += "\\f";
    else if (char == "\\") new_str += "\\\\";
    else if (char == '"') new_str += '\\"';
    else if (char < " " || char > "~" && char < "\xA0") {
      new_str += "\\u{" + char.charCodeAt(0).toString(16).toUpperCase().padStart(4, "0") + "}";
    } else {
      new_str += char;
    }
  }
  new_str += '"';
  return new_str;
}
function echo$inspectDict3(map6) {
  let body = "dict.from_list([";
  let first3 = true;
  let key_value_pairs = [];
  map6.forEach((value3, key) => {
    key_value_pairs.push([key, value3]);
  });
  key_value_pairs.sort();
  key_value_pairs.forEach(([key, value3]) => {
    if (!first3) body = body + ", ";
    body = body + "#(" + echo$inspect3(key) + ", " + echo$inspect3(value3) + ")";
    first3 = false;
  });
  return body + "])";
}
function echo$inspectCustomType3(record) {
  const props = globalThis.Object.keys(record).map((label2) => {
    const value3 = echo$inspect3(record[label2]);
    return isNaN(parseInt(label2)) ? `${label2}: ${value3}` : value3;
  }).join(", ");
  return props ? `${record.constructor.name}(${props})` : record.constructor.name;
}
function echo$inspectObject3(v) {
  const name6 = Object.getPrototypeOf(v)?.constructor?.name || "Object";
  const props = [];
  for (const k of Object.keys(v)) {
    props.push(`${echo$inspect3(k)}: ${echo$inspect3(v[k])}`);
  }
  const body = props.length ? " " + props.join(", ") + " " : "";
  const head = name6 === "Object" ? "" : name6 + " ";
  return `//js(${head}{${body}})`;
}
function echo$inspect3(v) {
  const t = typeof v;
  if (v === true) return "True";
  if (v === false) return "False";
  if (v === null) return "//js(null)";
  if (v === void 0) return "Nil";
  if (t === "string") return echo$inspectString3(v);
  if (t === "bigint" || t === "number") return v.toString();
  if (globalThis.Array.isArray(v))
    return `#(${v.map(echo$inspect3).join(", ")})`;
  if (v instanceof List)
    return `[${v.toArray().map(echo$inspect3).join(", ")}]`;
  if (v instanceof UtfCodepoint)
    return `//utfcodepoint(${String.fromCodePoint(v.value)})`;
  if (v instanceof BitArray) return echo$inspectBitArray3(v);
  if (v instanceof CustomType) return echo$inspectCustomType3(v);
  if (echo$isDict3(v)) return echo$inspectDict3(v);
  if (v instanceof Set)
    return `//js(Set(${[...v].map(echo$inspect3).join(", ")}))`;
  if (v instanceof RegExp) return `//js(${v})`;
  if (v instanceof Date) return `//js(Date("${v.toISOString()}"))`;
  if (v instanceof Function) {
    const args = [];
    for (const i of Array(v.length).keys())
      args.push(String.fromCharCode(i + 97));
    return `//fn(${args.join(", ")}) { ... }`;
  }
  return echo$inspectObject3(v);
}
function echo$inspectBitArray3(bitArray) {
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
function echo$isDict3(value3) {
  try {
    return value3 instanceof Dict;
  } catch {
    return false;
  }
}

// build/dev/javascript/lustre_ui/lustre/ui/combobox_stories.mjs
var FILEPATH6 = "dev/lustre/ui/combobox_stories.gleam";
function basic_story() {
  return story2(
    "Typeahead filter",
    () => {
      return input2(
        "Value",
        "gleam",
        (value3) => {
          return scene(
            (controls) => {
              return inject(
                (() => {
                  let _pipe = default$();
                  return with_scope(_pipe, new Host());
                })(),
                () => {
                  return element13(
                    toList([
                      value2(get3(controls, value3)),
                      on_change3(
                        (_capture) => {
                          return set(value3, _capture);
                        }
                      )
                    ]),
                    toList([
                      option2("gleam", "Gleam"),
                      option2("go", "Go"),
                      option2("javascript", "JavaScript"),
                      option2("kotlin", "Kotlin"),
                      option2("rust", "Rust"),
                      option2("typescript", "TypeScript")
                    ])
                  );
                }
              );
            }
          );
        }
      );
    }
  );
}
function fruit_picker_story() {
  return story2(
    "Fruit Picker",
    () => {
      return input2(
        "Value",
        "apple",
        (value3) => {
          return scene(
            (controls) => {
              return inject(
                (() => {
                  let _pipe = default$();
                  return with_scope(_pipe, new Host());
                })(),
                () => {
                  return element13(
                    toList([
                      value2(get3(controls, value3)),
                      on_change3(
                        (_capture) => {
                          return set(value3, _capture);
                        }
                      )
                    ]),
                    toList([
                      option2("apple", "Apple"),
                      option2("banana", "Banana"),
                      option2("orange", "Orange")
                    ])
                  );
                }
              );
            }
          );
        }
      );
    }
  );
}
function all8() {
  let $ = register5();
  if (!($ instanceof Ok)) {
    throw makeError(
      "let_assert",
      FILEPATH6,
      "lustre/ui/combobox_stories",
      10,
      "all",
      "Pattern match failed, no pattern matched the value.",
      { value: $, start: 255, end: 293, pattern_start: 266, pattern_end: 271 }
    );
  }
  return chapter(
    "Combobox",
    toList([basic_story(), fruit_picker_story()])
  );
}

// build/dev/javascript/lustre_ui/lustre/ui/divider.mjs
function element14(attributes, children) {
  if (children instanceof Empty) {
    return hr(
      prepend(class$("lustre-ui-divider"), attributes)
    );
  } else {
    return div(
      prepend(class$("lustre-ui-divider"), attributes),
      children
    );
  }
}

// build/dev/javascript/lustre_ui/lustre/ui/divider_stories.mjs
function basic_divider_story() {
  return story2(
    "Basic Divider with No Content",
    () => {
      return scene(
        (_) => {
          return inject(
            (() => {
              let _pipe = default$();
              return with_scope(_pipe, new Host());
            })(),
            () => {
              return div(
                toList([]),
                toList([
                  p(
                    toList([]),
                    toList([
                      text3(
                        "This is some content before the divider. The divider below has no content and serves as a simple horizontal rule."
                      )
                    ])
                  ),
                  element14(toList([]), toList([])),
                  p(
                    toList([]),
                    toList([
                      text3(
                        "This is some content after the divider. Notice how the divider creates a clear separation between content sections."
                      )
                    ])
                  )
                ])
              );
            }
          );
        }
      );
    }
  );
}
function text_label_divider_story() {
  return story2(
    "Divider with Text Label",
    () => {
      return scene(
        (_) => {
          return inject(
            (() => {
              let _pipe = default$();
              return with_scope(_pipe, new Host());
            })(),
            () => {
              return div(
                toList([]),
                toList([
                  p(
                    toList([]),
                    toList([text3("Sign in with your email and password")])
                  ),
                  div(
                    toList([]),
                    toList([
                      p(
                        toList([]),
                        toList([text3("(Form fields placeholder)")])
                      )
                    ])
                  ),
                  element14(toList([]), toList([text3("OR")])),
                  p(
                    toList([]),
                    toList([text3("Continue with social login")])
                  ),
                  div(
                    toList([]),
                    toList([
                      p(
                        toList([]),
                        toList([
                          text3("(Social login buttons placeholder)")
                        ])
                      )
                    ])
                  )
                ])
              );
            }
          );
        }
      );
    }
  );
}
function all9() {
  return chapter(
    "Divider",
    toList([basic_divider_story(), text_label_divider_story()])
  );
}

// build/dev/javascript/lustre_ui/lustre_ui_storybook.mjs
function main2() {
  let book2 = book(
    "Lustre UI",
    toList([
      all2(),
      all3(),
      all4(),
      all5(),
      all6(),
      all7(),
      all8(),
      all9(),
      external_stylesheet("/priv/static/lustre_ui.css")
    ])
  );
  return start5(book2);
}

// build/.lustre/entry.mjs
main2();
