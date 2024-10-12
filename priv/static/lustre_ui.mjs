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
    for (let _ of this) {
      if (desired <= 0)
        return true;
      desired--;
    }
    return desired <= 0;
  }
  // @internal
  hasLength(desired) {
    for (let _ of this) {
      if (desired <= 0)
        return false;
      desired--;
    }
    return desired === 0;
  }
  // @internal
  countLength() {
    let length4 = 0;
    for (let _ of this)
      length4++;
    return length4;
  }
};
function prepend(element3, tail) {
  return new NonEmpty(element3, tail);
}
function toList(elements2, tail) {
  return List.fromArray(elements2, tail);
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
var BitArray = class _BitArray {
  constructor(buffer) {
    if (!(buffer instanceof Uint8Array)) {
      throw "BitArray can only be constructed from a Uint8Array";
    }
    this.buffer = buffer;
  }
  // @internal
  get length() {
    return this.buffer.length;
  }
  // @internal
  byteAt(index3) {
    return this.buffer[index3];
  }
  // @internal
  floatFromSlice(start3, end, isBigEndian) {
    return byteArrayToFloat(this.buffer, start3, end, isBigEndian);
  }
  // @internal
  intFromSlice(start3, end, isBigEndian, isSigned) {
    return byteArrayToInt(this.buffer, start3, end, isBigEndian, isSigned);
  }
  // @internal
  binaryFromSlice(start3, end) {
    return new _BitArray(this.buffer.slice(start3, end));
  }
  // @internal
  sliceAfter(index3) {
    return new _BitArray(this.buffer.slice(index3));
  }
};
var UtfCodepoint = class {
  constructor(value) {
    this.value = value;
  }
};
function byteArrayToInt(byteArray, start3, end, isBigEndian, isSigned) {
  let value = 0;
  if (isBigEndian) {
    for (let i = start3; i < end; i++) {
      value = value * 256 + byteArray[i];
    }
  } else {
    for (let i = end - 1; i >= start3; i--) {
      value = value * 256 + byteArray[i];
    }
  }
  if (isSigned) {
    const byteSize = end - start3;
    const highBit = 2 ** (byteSize * 8 - 1);
    if (value >= highBit) {
      value -= highBit * 2;
    }
  }
  return value;
}
function byteArrayToFloat(byteArray, start3, end, isBigEndian) {
  const view2 = new DataView(byteArray.buffer);
  const byteSize = end - start3;
  if (byteSize === 8) {
    return view2.getFloat64(start3, !isBigEndian);
  } else if (byteSize === 4) {
    return view2.getFloat32(start3, !isBigEndian);
  } else {
    const msg = `Sized floats must be 32-bit or 64-bit on JavaScript, got size of ${byteSize * 8} bits`;
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
  constructor(value) {
    super();
    this[0] = value;
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
  let values = [x, y];
  while (values.length) {
    let a = values.pop();
    let b = values.pop();
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
    let [keys2, get2] = getters(a);
    for (let k of keys2(a)) {
      values.push(get2(a, k), get2(b, k));
    }
  }
  return true;
}
function getters(object3) {
  if (object3 instanceof Map) {
    return [(x) => x.keys(), (x, y) => x.get(y)];
  } else {
    let extra = object3 instanceof globalThis.Error ? ["message"] : [];
    return [(x) => [...extra, ...Object.keys(x)], (x, y) => x[y]];
  }
}
function unequalDates(a, b) {
  return a instanceof Date && (a > b || a < b);
}
function unequalBuffers(a, b) {
  return a.buffer instanceof ArrayBuffer && a.BYTES_PER_ELEMENT && !(a.byteLength === b.byteLength && a.every((n, i) => n === b[i]));
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
function divideFloat(a, b) {
  if (b === 0) {
    return 0;
  } else {
    return a / b;
  }
}
function makeError(variant, module, line, fn, message, extra) {
  let error = new globalThis.Error(message);
  error.gleam_error = variant;
  error.module = module;
  error.line = line;
  error.function = fn;
  error.fn = fn;
  for (let k in extra)
    error[k] = extra[k];
  return error;
}

// build/dev/javascript/gleam_stdlib/gleam/option.mjs
var Some = class extends CustomType {
  constructor(x0) {
    super();
    this[0] = x0;
  }
};
var None = class extends CustomType {
};
function to_result(option, e) {
  if (option instanceof Some) {
    let a = option[0];
    return new Ok(a);
  } else {
    return new Error(e);
  }
}

// build/dev/javascript/gleam_stdlib/dict.mjs
var referenceMap = /* @__PURE__ */ new WeakMap();
var tempDataView = new DataView(new ArrayBuffer(8));
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
function cloneAndSet(arr, at2, val) {
  const len = arr.length;
  const out = new Array(len);
  for (let i = 0; i < len; ++i) {
    out[i] = arr[i];
  }
  out[at2] = val;
  return out;
}
function spliceIn(arr, at2, val) {
  const len = arr.length;
  const out = new Array(len + 1);
  let i = 0;
  let g = 0;
  while (i < at2) {
    out[g++] = arr[i++];
  }
  out[g++] = val;
  while (i < len) {
    out[g++] = arr[i++];
  }
  return out;
}
function spliceOut(arr, at2) {
  const len = arr.length;
  const out = new Array(len - 1);
  let i = 0;
  let g = 0;
  while (i < at2) {
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
function assoc(root, shift, hash, key, val, addedLeaf) {
  switch (root.type) {
    case ARRAY_NODE:
      return assocArray(root, shift, hash, key, val, addedLeaf);
    case INDEX_NODE:
      return assocIndex(root, shift, hash, key, val, addedLeaf);
    case COLLISION_NODE:
      return assocCollision(root, shift, hash, key, val, addedLeaf);
  }
}
function assocArray(root, shift, hash, key, val, addedLeaf) {
  const idx = mask(hash, shift);
  const node = root.array[idx];
  if (node === void 0) {
    addedLeaf.val = true;
    return {
      type: ARRAY_NODE,
      size: root.size + 1,
      array: cloneAndSet(root.array, idx, { type: ENTRY, k: key, v: val })
    };
  }
  if (node.type === ENTRY) {
    if (isEqual(key, node.k)) {
      if (val === node.v) {
        return root;
      }
      return {
        type: ARRAY_NODE,
        size: root.size,
        array: cloneAndSet(root.array, idx, {
          type: ENTRY,
          k: key,
          v: val
        })
      };
    }
    addedLeaf.val = true;
    return {
      type: ARRAY_NODE,
      size: root.size,
      array: cloneAndSet(
        root.array,
        idx,
        createNode(shift + SHIFT, node.k, node.v, hash, key, val)
      )
    };
  }
  const n = assoc(node, shift + SHIFT, hash, key, val, addedLeaf);
  if (n === node) {
    return root;
  }
  return {
    type: ARRAY_NODE,
    size: root.size,
    array: cloneAndSet(root.array, idx, n)
  };
}
function assocIndex(root, shift, hash, key, val, addedLeaf) {
  const bit = bitpos(hash, shift);
  const idx = index(root.bitmap, bit);
  if ((root.bitmap & bit) !== 0) {
    const node = root.array[idx];
    if (node.type !== ENTRY) {
      const n = assoc(node, shift + SHIFT, hash, key, val, addedLeaf);
      if (n === node) {
        return root;
      }
      return {
        type: INDEX_NODE,
        bitmap: root.bitmap,
        array: cloneAndSet(root.array, idx, n)
      };
    }
    const nodeKey = node.k;
    if (isEqual(key, nodeKey)) {
      if (val === node.v) {
        return root;
      }
      return {
        type: INDEX_NODE,
        bitmap: root.bitmap,
        array: cloneAndSet(root.array, idx, {
          type: ENTRY,
          k: key,
          v: val
        })
      };
    }
    addedLeaf.val = true;
    return {
      type: INDEX_NODE,
      bitmap: root.bitmap,
      array: cloneAndSet(
        root.array,
        idx,
        createNode(shift + SHIFT, nodeKey, node.v, hash, key, val)
      )
    };
  } else {
    const n = root.array.length;
    if (n >= MAX_INDEX_NODE) {
      const nodes = new Array(32);
      const jdx = mask(hash, shift);
      nodes[jdx] = assocIndex(EMPTY, shift + SHIFT, hash, key, val, addedLeaf);
      let j = 0;
      let bitmap = root.bitmap;
      for (let i = 0; i < 32; i++) {
        if ((bitmap & 1) !== 0) {
          const node = root.array[j++];
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
      const newArray = spliceIn(root.array, idx, {
        type: ENTRY,
        k: key,
        v: val
      });
      addedLeaf.val = true;
      return {
        type: INDEX_NODE,
        bitmap: root.bitmap | bit,
        array: newArray
      };
    }
  }
}
function assocCollision(root, shift, hash, key, val, addedLeaf) {
  if (hash === root.hash) {
    const idx = collisionIndexOf(root, key);
    if (idx !== -1) {
      const entry = root.array[idx];
      if (entry.v === val) {
        return root;
      }
      return {
        type: COLLISION_NODE,
        hash,
        array: cloneAndSet(root.array, idx, { type: ENTRY, k: key, v: val })
      };
    }
    const size2 = root.array.length;
    addedLeaf.val = true;
    return {
      type: COLLISION_NODE,
      hash,
      array: cloneAndSet(root.array, size2, { type: ENTRY, k: key, v: val })
    };
  }
  return assoc(
    {
      type: INDEX_NODE,
      bitmap: bitpos(root.hash, shift),
      array: [root]
    },
    shift,
    hash,
    key,
    val,
    addedLeaf
  );
}
function collisionIndexOf(root, key) {
  const size2 = root.array.length;
  for (let i = 0; i < size2; i++) {
    if (isEqual(key, root.array[i].k)) {
      return i;
    }
  }
  return -1;
}
function find(root, shift, hash, key) {
  switch (root.type) {
    case ARRAY_NODE:
      return findArray(root, shift, hash, key);
    case INDEX_NODE:
      return findIndex(root, shift, hash, key);
    case COLLISION_NODE:
      return findCollision(root, key);
  }
}
function findArray(root, shift, hash, key) {
  const idx = mask(hash, shift);
  const node = root.array[idx];
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
function findIndex(root, shift, hash, key) {
  const bit = bitpos(hash, shift);
  if ((root.bitmap & bit) === 0) {
    return void 0;
  }
  const idx = index(root.bitmap, bit);
  const node = root.array[idx];
  if (node.type !== ENTRY) {
    return find(node, shift + SHIFT, hash, key);
  }
  if (isEqual(key, node.k)) {
    return node;
  }
  return void 0;
}
function findCollision(root, key) {
  const idx = collisionIndexOf(root, key);
  if (idx < 0) {
    return void 0;
  }
  return root.array[idx];
}
function without(root, shift, hash, key) {
  switch (root.type) {
    case ARRAY_NODE:
      return withoutArray(root, shift, hash, key);
    case INDEX_NODE:
      return withoutIndex(root, shift, hash, key);
    case COLLISION_NODE:
      return withoutCollision(root, key);
  }
}
function withoutArray(root, shift, hash, key) {
  const idx = mask(hash, shift);
  const node = root.array[idx];
  if (node === void 0) {
    return root;
  }
  let n = void 0;
  if (node.type === ENTRY) {
    if (!isEqual(node.k, key)) {
      return root;
    }
  } else {
    n = without(node, shift + SHIFT, hash, key);
    if (n === node) {
      return root;
    }
  }
  if (n === void 0) {
    if (root.size <= MIN_ARRAY_NODE) {
      const arr = root.array;
      const out = new Array(root.size - 1);
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
      size: root.size - 1,
      array: cloneAndSet(root.array, idx, n)
    };
  }
  return {
    type: ARRAY_NODE,
    size: root.size,
    array: cloneAndSet(root.array, idx, n)
  };
}
function withoutIndex(root, shift, hash, key) {
  const bit = bitpos(hash, shift);
  if ((root.bitmap & bit) === 0) {
    return root;
  }
  const idx = index(root.bitmap, bit);
  const node = root.array[idx];
  if (node.type !== ENTRY) {
    const n = without(node, shift + SHIFT, hash, key);
    if (n === node) {
      return root;
    }
    if (n !== void 0) {
      return {
        type: INDEX_NODE,
        bitmap: root.bitmap,
        array: cloneAndSet(root.array, idx, n)
      };
    }
    if (root.bitmap === bit) {
      return void 0;
    }
    return {
      type: INDEX_NODE,
      bitmap: root.bitmap ^ bit,
      array: spliceOut(root.array, idx)
    };
  }
  if (isEqual(key, node.k)) {
    if (root.bitmap === bit) {
      return void 0;
    }
    return {
      type: INDEX_NODE,
      bitmap: root.bitmap ^ bit,
      array: spliceOut(root.array, idx)
    };
  }
  return root;
}
function withoutCollision(root, key) {
  const idx = collisionIndexOf(root, key);
  if (idx < 0) {
    return root;
  }
  if (root.array.length === 1) {
    return void 0;
  }
  return {
    type: COLLISION_NODE,
    hash: root.hash,
    array: spliceOut(root.array, idx)
  };
}
function forEach(root, fn) {
  if (root === void 0) {
    return;
  }
  const items = root.array;
  const size2 = items.length;
  for (let i = 0; i < size2; i++) {
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
  constructor(root, size2) {
    this.root = root;
    this.size = size2;
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
    const root = this.root === void 0 ? EMPTY : this.root;
    const newRoot = assoc(root, 0, getHash(key), key, val, addedLeaf);
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
    let equal = true;
    this.forEach((v, k) => {
      equal = equal && isEqual(o.get(k, !v), v);
    });
    return equal;
  }
};

// build/dev/javascript/gleam_stdlib/gleam_stdlib.mjs
var Nil = void 0;
var NOT_FOUND = {};
function identity(x) {
  return x;
}
function parse_int(value) {
  if (/^[-+]?(\d+)$/.test(value)) {
    return new Ok(parseInt(value));
  } else {
    return new Error(Nil);
  }
}
function to_string(term) {
  return term.toString();
}
function float_to_string(float3) {
  const string3 = float3.toString();
  if (string3.indexOf(".") >= 0) {
    return string3;
  } else {
    return string3 + ".0";
  }
}
function string_replace(string3, target, substitute) {
  if (typeof string3.replaceAll !== "undefined") {
    return string3.replaceAll(target, substitute);
  }
  return string3.replace(
    // $& means the whole matched string
    new RegExp(target.replace(/[.*+?^${}()|[\]\\]/g, "\\$&"), "g"),
    substitute
  );
}
function string_length(string3) {
  if (string3 === "") {
    return 0;
  }
  const iterator = graphemes_iterator(string3);
  if (iterator) {
    let i = 0;
    for (const _ of iterator) {
      i++;
    }
    return i;
  } else {
    return string3.match(/./gsu).length;
  }
}
function graphemes(string3) {
  const iterator = graphemes_iterator(string3);
  if (iterator) {
    return List.fromArray(Array.from(iterator).map((item) => item.segment));
  } else {
    return List.fromArray(string3.match(/./gsu));
  }
}
function graphemes_iterator(string3) {
  if (globalThis.Intl && Intl.Segmenter) {
    return new Intl.Segmenter().segment(string3)[Symbol.iterator]();
  }
}
function lowercase(string3) {
  return string3.toLowerCase();
}
function join(xs, separator) {
  const iterator = xs[Symbol.iterator]();
  let result = iterator.next().value || "";
  let current = iterator.next();
  while (!current.done) {
    result = result + separator + current.value;
    current = iterator.next();
  }
  return result;
}
function concat(xs) {
  let result = "";
  for (const x of xs) {
    result = result + x;
  }
  return result;
}
function length(data) {
  return data.length;
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
var left_trim_regex = new RegExp(`^([${unicode_whitespaces}]*)`, "g");
var right_trim_regex = new RegExp(`([${unicode_whitespaces}]*)$`, "g");
function round(float3) {
  return Math.round(float3);
}
function new_map() {
  return Dict.new();
}
function map_to_list(map5) {
  return List.fromArray(map5.entries());
}
function map_get(map5, key) {
  const value = map5.get(key, NOT_FOUND);
  if (value === NOT_FOUND) {
    return new Error(Nil);
  }
  return new Ok(value);
}
function map_insert(key, value, map5) {
  return map5.set(key, value);
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
    return `Tuple of ${data.length} elements`;
  } else if (typeof data === "number") {
    return "Float";
  } else if (data === null) {
    return "Null";
  } else if (data === void 0) {
    return "Nil";
  } else {
    const type = typeof data;
    return type.charAt(0).toUpperCase() + type.slice(1);
  }
}
function decoder_error(expected, got) {
  return decoder_error_no_classify(expected, classify_dynamic(got));
}
function decoder_error_no_classify(expected, got) {
  return new Error(
    List.fromArray([new DecodeError(expected, got, List.fromArray([]))])
  );
}
function decode_string(data) {
  return typeof data === "string" ? new Ok(data) : decoder_error("String", data);
}
function decode_int(data) {
  return Number.isInteger(data) ? new Ok(data) : decoder_error("Int", data);
}
function decode_float(data) {
  return typeof data === "number" ? new Ok(data) : decoder_error("Float", data);
}
function decode_bool(data) {
  return typeof data === "boolean" ? new Ok(data) : decoder_error("Bool", data);
}
function decode_tuple(data) {
  return Array.isArray(data) ? new Ok(data) : decoder_error("Tuple", data);
}
function tuple_get(data, index3) {
  return index3 >= 0 && data.length > index3 ? new Ok(data[index3]) : new Error(Nil);
}
function decode_list(data) {
  if (Array.isArray(data)) {
    return new Ok(List.fromArray(data));
  }
  return data instanceof List ? new Ok(data) : decoder_error("List", data);
}
function decode_field(value, name3) {
  const not_a_map_error = () => decoder_error("Dict", value);
  if (value instanceof Dict || value instanceof WeakMap || value instanceof Map) {
    const entry = map_get(value, name3);
    return new Ok(entry.isOk() ? new Some(entry[0]) : new None());
  } else if (value === null) {
    return not_a_map_error();
  } else if (Object.getPrototypeOf(value) == Object.prototype) {
    return try_get_field(value, name3, () => new Ok(new None()));
  } else {
    return try_get_field(value, name3, not_a_map_error);
  }
}
function try_get_field(value, field2, or_else) {
  try {
    return field2 in value ? new Ok(new Some(value[field2])) : or_else();
  } catch {
    return or_else();
  }
}
function inspect(v) {
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
    return inspectString(v);
  if (t === "bigint" || t === "number")
    return v.toString();
  if (Array.isArray(v))
    return `#(${v.map(inspect).join(", ")})`;
  if (v instanceof List)
    return inspectList(v);
  if (v instanceof UtfCodepoint)
    return inspectUtfCodepoint(v);
  if (v instanceof BitArray)
    return inspectBitArray(v);
  if (v instanceof CustomType)
    return inspectCustomType(v);
  if (v instanceof Dict)
    return inspectDict(v);
  if (v instanceof Set)
    return `//js(Set(${[...v].map(inspect).join(", ")}))`;
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
  return inspectObject(v);
}
function inspectString(str) {
  let new_str = '"';
  for (let i = 0; i < str.length; i++) {
    let char = str[i];
    switch (char) {
      case "\n":
        new_str += "\\n";
        break;
      case "\r":
        new_str += "\\r";
        break;
      case "	":
        new_str += "\\t";
        break;
      case "\f":
        new_str += "\\f";
        break;
      case "\\":
        new_str += "\\\\";
        break;
      case '"':
        new_str += '\\"';
        break;
      default:
        if (char < " " || char > "~" && char < "\xA0") {
          new_str += "\\u{" + char.charCodeAt(0).toString(16).toUpperCase().padStart(4, "0") + "}";
        } else {
          new_str += char;
        }
    }
  }
  new_str += '"';
  return new_str;
}
function inspectDict(map5) {
  let body = "dict.from_list([";
  let first4 = true;
  map5.forEach((value, key) => {
    if (!first4)
      body = body + ", ";
    body = body + "#(" + inspect(key) + ", " + inspect(value) + ")";
    first4 = false;
  });
  return body + "])";
}
function inspectObject(v) {
  const name3 = Object.getPrototypeOf(v)?.constructor?.name || "Object";
  const props = [];
  for (const k of Object.keys(v)) {
    props.push(`${inspect(k)}: ${inspect(v[k])}`);
  }
  const body = props.length ? " " + props.join(", ") + " " : "";
  const head = name3 === "Object" ? "" : name3 + " ";
  return `//js(${head}{${body}})`;
}
function inspectCustomType(record) {
  const props = Object.keys(record).map((label) => {
    const value = inspect(record[label]);
    return isNaN(parseInt(label)) ? `${label}: ${value}` : value;
  }).join(", ");
  return props ? `${record.constructor.name}(${props})` : record.constructor.name;
}
function inspectList(list3) {
  return `[${list3.toArray().map(inspect).join(", ")}]`;
}
function inspectBitArray(bits) {
  return `<<${Array.from(bits.buffer).join(", ")}>>`;
}
function inspectUtfCodepoint(codepoint2) {
  return `//utfcodepoint(${String.fromCodePoint(codepoint2.value)})`;
}

// build/dev/javascript/gleam_stdlib/gleam/dict.mjs
function new$() {
  return new_map();
}
function get(from, get2) {
  return map_get(from, get2);
}
function insert(dict2, key, value) {
  return map_insert(key, value, dict2);
}
function fold_list_of_pair(loop$list, loop$initial) {
  while (true) {
    let list3 = loop$list;
    let initial = loop$initial;
    if (list3.hasLength(0)) {
      return initial;
    } else {
      let x = list3.head;
      let rest2 = list3.tail;
      loop$list = rest2;
      loop$initial = insert(initial, x[0], x[1]);
    }
  }
}
function from_list(list3) {
  return fold_list_of_pair(list3, new$());
}
function reverse_and_concat(loop$remaining, loop$accumulator) {
  while (true) {
    let remaining = loop$remaining;
    let accumulator = loop$accumulator;
    if (remaining.hasLength(0)) {
      return accumulator;
    } else {
      let item = remaining.head;
      let rest2 = remaining.tail;
      loop$remaining = rest2;
      loop$accumulator = prepend(item, accumulator);
    }
  }
}
function do_keys_acc(loop$list, loop$acc) {
  while (true) {
    let list3 = loop$list;
    let acc = loop$acc;
    if (list3.hasLength(0)) {
      return reverse_and_concat(acc, toList([]));
    } else {
      let x = list3.head;
      let xs = list3.tail;
      loop$list = xs;
      loop$acc = prepend(x[0], acc);
    }
  }
}
function do_keys(dict2) {
  let list_of_pairs = map_to_list(dict2);
  return do_keys_acc(list_of_pairs, toList([]));
}
function keys(dict2) {
  return do_keys(dict2);
}

// build/dev/javascript/gleam_stdlib/gleam/float.mjs
function to_string2(x) {
  return float_to_string(x);
}
function negate(x) {
  return -1 * x;
}
function do_round(x) {
  let $ = x >= 0;
  if ($) {
    return round(x);
  } else {
    return 0 - round(negate(x));
  }
}
function round2(x) {
  return do_round(x);
}
function do_sum(loop$numbers, loop$initial) {
  while (true) {
    let numbers = loop$numbers;
    let initial = loop$initial;
    if (numbers.hasLength(0)) {
      return initial;
    } else {
      let x = numbers.head;
      let rest2 = numbers.tail;
      loop$numbers = rest2;
      loop$initial = x + initial;
    }
  }
}
function sum(numbers) {
  let _pipe = numbers;
  return do_sum(_pipe, 0);
}
function divide(a, b) {
  if (b === 0) {
    return new Error(void 0);
  } else {
    let b$1 = b;
    return new Ok(divideFloat(a, b$1));
  }
}

// build/dev/javascript/gleam_stdlib/gleam/int.mjs
function absolute_value(x) {
  let $ = x >= 0;
  if ($) {
    return x;
  } else {
    return x * -1;
  }
}
function parse(string3) {
  return parse_int(string3);
}
function to_string3(x) {
  return to_string(x);
}
function to_float(x) {
  return identity(x);
}
function min(a, b) {
  let $ = a < b;
  if ($) {
    return a;
  } else {
    return b;
  }
}
function max(a, b) {
  let $ = a > b;
  if ($) {
    return a;
  } else {
    return b;
  }
}

// build/dev/javascript/gleam_stdlib/gleam/pair.mjs
function map_second(pair, fun) {
  let a = pair[0];
  let b = pair[1];
  return [a, fun(b)];
}

// build/dev/javascript/gleam_stdlib/gleam/list.mjs
function count_length(loop$list, loop$count) {
  while (true) {
    let list3 = loop$list;
    let count = loop$count;
    if (list3.atLeastLength(1)) {
      let list$1 = list3.tail;
      loop$list = list$1;
      loop$count = count + 1;
    } else {
      return count;
    }
  }
}
function length2(list3) {
  return count_length(list3, 0);
}
function do_reverse(loop$remaining, loop$accumulator) {
  while (true) {
    let remaining = loop$remaining;
    let accumulator = loop$accumulator;
    if (remaining.hasLength(0)) {
      return accumulator;
    } else {
      let item = remaining.head;
      let rest$1 = remaining.tail;
      loop$remaining = rest$1;
      loop$accumulator = prepend(item, accumulator);
    }
  }
}
function reverse(xs) {
  return do_reverse(xs, toList([]));
}
function first(list3) {
  if (list3.hasLength(0)) {
    return new Error(void 0);
  } else {
    let x = list3.head;
    return new Ok(x);
  }
}
function do_map(loop$list, loop$fun, loop$acc) {
  while (true) {
    let list3 = loop$list;
    let fun = loop$fun;
    let acc = loop$acc;
    if (list3.hasLength(0)) {
      return reverse(acc);
    } else {
      let x = list3.head;
      let xs = list3.tail;
      loop$list = xs;
      loop$fun = fun;
      loop$acc = prepend(fun(x), acc);
    }
  }
}
function map(list3, fun) {
  return do_map(list3, fun, toList([]));
}
function do_try_map(loop$list, loop$fun, loop$acc) {
  while (true) {
    let list3 = loop$list;
    let fun = loop$fun;
    let acc = loop$acc;
    if (list3.hasLength(0)) {
      return new Ok(reverse(acc));
    } else {
      let x = list3.head;
      let xs = list3.tail;
      let $ = fun(x);
      if ($.isOk()) {
        let y = $[0];
        loop$list = xs;
        loop$fun = fun;
        loop$acc = prepend(y, acc);
      } else {
        let error = $[0];
        return new Error(error);
      }
    }
  }
}
function try_map(list3, fun) {
  return do_try_map(list3, fun, toList([]));
}
function drop(loop$list, loop$n) {
  while (true) {
    let list3 = loop$list;
    let n = loop$n;
    let $ = n <= 0;
    if ($) {
      return list3;
    } else {
      if (list3.hasLength(0)) {
        return toList([]);
      } else {
        let xs = list3.tail;
        loop$list = xs;
        loop$n = n - 1;
      }
    }
  }
}
function do_take(loop$list, loop$n, loop$acc) {
  while (true) {
    let list3 = loop$list;
    let n = loop$n;
    let acc = loop$acc;
    let $ = n <= 0;
    if ($) {
      return reverse(acc);
    } else {
      if (list3.hasLength(0)) {
        return reverse(acc);
      } else {
        let x = list3.head;
        let xs = list3.tail;
        loop$list = xs;
        loop$n = n - 1;
        loop$acc = prepend(x, acc);
      }
    }
  }
}
function take(list3, n) {
  return do_take(list3, n, toList([]));
}
function do_append(loop$first, loop$second) {
  while (true) {
    let first4 = loop$first;
    let second2 = loop$second;
    if (first4.hasLength(0)) {
      return second2;
    } else {
      let item = first4.head;
      let rest$1 = first4.tail;
      loop$first = rest$1;
      loop$second = prepend(item, second2);
    }
  }
}
function append(first4, second2) {
  return do_append(reverse(first4), second2);
}
function fold(loop$list, loop$initial, loop$fun) {
  while (true) {
    let list3 = loop$list;
    let initial = loop$initial;
    let fun = loop$fun;
    if (list3.hasLength(0)) {
      return initial;
    } else {
      let x = list3.head;
      let rest$1 = list3.tail;
      loop$list = rest$1;
      loop$initial = fun(initial, x);
      loop$fun = fun;
    }
  }
}
function fold_right(list3, initial, fun) {
  if (list3.hasLength(0)) {
    return initial;
  } else {
    let x = list3.head;
    let rest$1 = list3.tail;
    return fun(fold_right(rest$1, initial, fun), x);
  }
}
function do_index_fold(loop$over, loop$acc, loop$with, loop$index) {
  while (true) {
    let over = loop$over;
    let acc = loop$acc;
    let with$ = loop$with;
    let index3 = loop$index;
    if (over.hasLength(0)) {
      return acc;
    } else {
      let first$1 = over.head;
      let rest$1 = over.tail;
      loop$over = rest$1;
      loop$acc = with$(acc, first$1, index3);
      loop$with = with$;
      loop$index = index3 + 1;
    }
  }
}
function index_fold(over, initial, fun) {
  return do_index_fold(over, initial, fun, 0);
}

// build/dev/javascript/gleam_stdlib/gleam/result.mjs
function map2(result, fun) {
  if (result.isOk()) {
    let x = result[0];
    return new Ok(fun(x));
  } else {
    let e = result[0];
    return new Error(e);
  }
}
function map_error(result, fun) {
  if (result.isOk()) {
    let x = result[0];
    return new Ok(x);
  } else {
    let error = result[0];
    return new Error(fun(error));
  }
}
function try$(result, fun) {
  if (result.isOk()) {
    let x = result[0];
    return fun(x);
  } else {
    let e = result[0];
    return new Error(e);
  }
}
function then$(result, fun) {
  return try$(result, fun);
}
function replace_error(result, error) {
  if (result.isOk()) {
    let x = result[0];
    return new Ok(x);
  } else {
    return new Error(error);
  }
}

// build/dev/javascript/gleam_stdlib/gleam/string_builder.mjs
function from_strings(strings) {
  return concat(strings);
}
function from_string(string3) {
  return identity(string3);
}
function to_string4(builder) {
  return identity(builder);
}

// build/dev/javascript/gleam_stdlib/gleam/string.mjs
function length3(string3) {
  return string_length(string3);
}
function replace(string3, pattern, substitute) {
  let _pipe = string3;
  let _pipe$1 = from_string(_pipe);
  let _pipe$2 = string_replace(_pipe$1, pattern, substitute);
  return to_string4(_pipe$2);
}
function lowercase2(string3) {
  return lowercase(string3);
}
function concat2(strings) {
  let _pipe = strings;
  let _pipe$1 = from_strings(_pipe);
  return to_string4(_pipe$1);
}
function join2(strings, separator) {
  return join(strings, separator);
}
function do_slice(string3, idx, len) {
  let _pipe = string3;
  let _pipe$1 = graphemes(_pipe);
  let _pipe$2 = drop(_pipe$1, idx);
  let _pipe$3 = take(_pipe$2, len);
  return concat2(_pipe$3);
}
function slice(string3, idx, len) {
  let $ = len < 0;
  if ($) {
    return "";
  } else {
    let $1 = idx < 0;
    if ($1) {
      let translated_idx = length3(string3) + idx;
      let $2 = translated_idx < 0;
      if ($2) {
        return "";
      } else {
        return do_slice(string3, translated_idx, len);
      }
    } else {
      return do_slice(string3, idx, len);
    }
  }
}
function drop_left(string3, num_graphemes) {
  let $ = num_graphemes < 0;
  if ($) {
    return string3;
  } else {
    return slice(string3, num_graphemes, length3(string3) - num_graphemes);
  }
}
function inspect2(term) {
  let _pipe = inspect(term);
  return to_string4(_pipe);
}

// build/dev/javascript/gleam_stdlib/gleam/dynamic.mjs
var DecodeError = class extends CustomType {
  constructor(expected, found, path) {
    super();
    this.expected = expected;
    this.found = found;
    this.path = path;
  }
};
function dynamic(value) {
  return new Ok(value);
}
function classify(data) {
  return classify_dynamic(data);
}
function int(data) {
  return decode_int(data);
}
function float(data) {
  return decode_float(data);
}
function bool(data) {
  return decode_bool(data);
}
function shallow_list(value) {
  return decode_list(value);
}
function at_least_decode_tuple_error(size2, data) {
  let s = (() => {
    if (size2 === 1) {
      return "";
    } else {
      return "s";
    }
  })();
  let error = (() => {
    let _pipe = toList([
      "Tuple of at least ",
      to_string3(size2),
      " element",
      s
    ]);
    let _pipe$1 = from_strings(_pipe);
    let _pipe$2 = to_string4(_pipe$1);
    return new DecodeError(_pipe$2, classify(data), toList([]));
  })();
  return new Error(toList([error]));
}
function any(decoders) {
  return (data) => {
    if (decoders.hasLength(0)) {
      return new Error(
        toList([new DecodeError("another type", classify(data), toList([]))])
      );
    } else {
      let decoder2 = decoders.head;
      let decoders$1 = decoders.tail;
      let $ = decoder2(data);
      if ($.isOk()) {
        let decoded = $[0];
        return new Ok(decoded);
      } else {
        return any(decoders$1)(data);
      }
    }
  };
}
function push_path(error, name3) {
  let name$1 = identity(name3);
  let decoder2 = any(
    toList([string, (x) => {
      return map2(int(x), to_string3);
    }])
  );
  let name$2 = (() => {
    let $ = decoder2(name$1);
    if ($.isOk()) {
      let name$22 = $[0];
      return name$22;
    } else {
      let _pipe = toList(["<", classify(name$1), ">"]);
      let _pipe$1 = from_strings(_pipe);
      return to_string4(_pipe$1);
    }
  })();
  return error.withFields({ path: prepend(name$2, error.path) });
}
function list(decoder_type) {
  return (dynamic2) => {
    return try$(
      shallow_list(dynamic2),
      (list3) => {
        let _pipe = list3;
        let _pipe$1 = try_map(_pipe, decoder_type);
        return map_errors(
          _pipe$1,
          (_capture) => {
            return push_path(_capture, "*");
          }
        );
      }
    );
  };
}
function map_errors(result, f) {
  return map_error(
    result,
    (_capture) => {
      return map(_capture, f);
    }
  );
}
function string(data) {
  return decode_string(data);
}
function field(name3, inner_type) {
  return (value) => {
    let missing_field_error = new DecodeError("field", "nothing", toList([]));
    return try$(
      decode_field(value, name3),
      (maybe_inner) => {
        let _pipe = maybe_inner;
        let _pipe$1 = to_result(_pipe, toList([missing_field_error]));
        let _pipe$2 = try$(_pipe$1, inner_type);
        return map_errors(
          _pipe$2,
          (_capture) => {
            return push_path(_capture, name3);
          }
        );
      }
    );
  };
}
function element(index3, inner_type) {
  return (data) => {
    return try$(
      decode_tuple(data),
      (tuple) => {
        let size2 = length(tuple);
        return try$(
          (() => {
            let $ = index3 >= 0;
            if ($) {
              let $1 = index3 < size2;
              if ($1) {
                return tuple_get(tuple, index3);
              } else {
                return at_least_decode_tuple_error(index3 + 1, data);
              }
            } else {
              let $1 = absolute_value(index3) <= size2;
              if ($1) {
                return tuple_get(tuple, size2 + index3);
              } else {
                return at_least_decode_tuple_error(
                  absolute_value(index3),
                  data
                );
              }
            }
          })(),
          (data2) => {
            let _pipe = inner_type(data2);
            return map_errors(
              _pipe,
              (_capture) => {
                return push_path(_capture, index3);
              }
            );
          }
        );
      }
    );
  };
}

// build/dev/javascript/gleam_stdlib/gleam/bool.mjs
function to_string5(bool3) {
  if (!bool3) {
    return "False";
  } else {
    return "True";
  }
}
function guard(requirement, consequence, alternative) {
  if (requirement) {
    return consequence;
  } else {
    return alternative();
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
function bool2(input) {
  return identity2(input);
}
function null$() {
  return do_null();
}
function object2(entries) {
  return object(entries);
}

// build/dev/javascript/lustre/lustre/effect.mjs
var Effect = class extends CustomType {
  constructor(all2) {
    super();
    this.all = all2;
  }
};
function custom(run) {
  return new Effect(
    toList([
      (actions) => {
        return run(actions.dispatch, actions.emit, actions.select);
      }
    ])
  );
}
function event(name3, data) {
  return custom((_, emit3, _1) => {
    return emit3(name3, data);
  });
}
function none() {
  return new Effect(toList([]));
}
function batch(effects) {
  return new Effect(
    fold(
      effects,
      toList([]),
      (b, _use1) => {
        let a = _use1.all;
        return append(b, a);
      }
    )
  );
}

// build/dev/javascript/lustre/lustre/internals/vdom.mjs
var Text = class extends CustomType {
  constructor(content2) {
    super();
    this.content = content2;
  }
};
var Element = class extends CustomType {
  constructor(key, namespace, tag, attrs, children2, self_closing, void$) {
    super();
    this.key = key;
    this.namespace = namespace;
    this.tag = tag;
    this.attrs = attrs;
    this.children = children2;
    this.self_closing = self_closing;
    this.void = void$;
  }
};
var Map2 = class extends CustomType {
  constructor(subtree) {
    super();
    this.subtree = subtree;
  }
};
var Fragment = class extends CustomType {
  constructor(elements2, key) {
    super();
    this.elements = elements2;
    this.key = key;
  }
};
var Attribute = class extends CustomType {
  constructor(x0, x1, as_property) {
    super();
    this[0] = x0;
    this[1] = x1;
    this.as_property = as_property;
  }
};
var Event = class extends CustomType {
  constructor(x0, x1) {
    super();
    this[0] = x0;
    this[1] = x1;
  }
};
function attribute_to_event_handler(attribute2) {
  if (attribute2 instanceof Attribute) {
    return new Error(void 0);
  } else {
    let name3 = attribute2[0];
    let handler = attribute2[1];
    let name$1 = drop_left(name3, 2);
    return new Ok([name$1, handler]);
  }
}
function do_element_list_handlers(elements2, handlers2, key) {
  return index_fold(
    elements2,
    handlers2,
    (handlers3, element3, index3) => {
      let key$1 = key + "-" + to_string3(index3);
      return do_handlers(element3, handlers3, key$1);
    }
  );
}
function do_handlers(loop$element, loop$handlers, loop$key) {
  while (true) {
    let element3 = loop$element;
    let handlers2 = loop$handlers;
    let key = loop$key;
    if (element3 instanceof Text) {
      return handlers2;
    } else if (element3 instanceof Map2) {
      let subtree = element3.subtree;
      loop$element = subtree();
      loop$handlers = handlers2;
      loop$key = key;
    } else if (element3 instanceof Element) {
      let attrs = element3.attrs;
      let children2 = element3.children;
      let handlers$1 = fold(
        attrs,
        handlers2,
        (handlers3, attr) => {
          let $ = attribute_to_event_handler(attr);
          if ($.isOk()) {
            let name3 = $[0][0];
            let handler = $[0][1];
            return insert(handlers3, key + "-" + name3, handler);
          } else {
            return handlers3;
          }
        }
      );
      return do_element_list_handlers(children2, handlers$1, key);
    } else {
      let elements2 = element3.elements;
      return do_element_list_handlers(elements2, handlers2, key);
    }
  }
}
function handlers(element3) {
  return do_handlers(element3, new$(), "0");
}

// build/dev/javascript/lustre/lustre/attribute.mjs
function attribute(name3, value) {
  return new Attribute(name3, identity(value), false);
}
function on(name3, handler) {
  return new Event("on" + name3, handler);
}
function style(properties) {
  return attribute(
    "style",
    fold(
      properties,
      "",
      (styles, _use1) => {
        let name$1 = _use1[0];
        let value$1 = _use1[1];
        return styles + name$1 + ":" + value$1 + ";";
      }
    )
  );
}
function class$(name3) {
  return attribute("class", name3);
}
function name(name3) {
  return attribute("name", name3);
}
function src(uri) {
  return attribute("src", uri);
}

// build/dev/javascript/lustre/lustre/element.mjs
function element2(tag, attrs, children2) {
  if (tag === "area") {
    return new Element("", "", tag, attrs, toList([]), false, true);
  } else if (tag === "base") {
    return new Element("", "", tag, attrs, toList([]), false, true);
  } else if (tag === "br") {
    return new Element("", "", tag, attrs, toList([]), false, true);
  } else if (tag === "col") {
    return new Element("", "", tag, attrs, toList([]), false, true);
  } else if (tag === "embed") {
    return new Element("", "", tag, attrs, toList([]), false, true);
  } else if (tag === "hr") {
    return new Element("", "", tag, attrs, toList([]), false, true);
  } else if (tag === "img") {
    return new Element("", "", tag, attrs, toList([]), false, true);
  } else if (tag === "input") {
    return new Element("", "", tag, attrs, toList([]), false, true);
  } else if (tag === "link") {
    return new Element("", "", tag, attrs, toList([]), false, true);
  } else if (tag === "meta") {
    return new Element("", "", tag, attrs, toList([]), false, true);
  } else if (tag === "param") {
    return new Element("", "", tag, attrs, toList([]), false, true);
  } else if (tag === "source") {
    return new Element("", "", tag, attrs, toList([]), false, true);
  } else if (tag === "track") {
    return new Element("", "", tag, attrs, toList([]), false, true);
  } else if (tag === "wbr") {
    return new Element("", "", tag, attrs, toList([]), false, true);
  } else {
    return new Element("", "", tag, attrs, children2, false, false);
  }
}
function text(content2) {
  return new Text(content2);
}
function flatten_fragment_elements(elements2) {
  return fold_right(
    elements2,
    toList([]),
    (new_elements, element3) => {
      if (element3 instanceof Fragment) {
        let fr_elements = element3.elements;
        return append(fr_elements, new_elements);
      } else {
        let el = element3;
        return prepend(el, new_elements);
      }
    }
  );
}
function fragment(elements2) {
  let _pipe = flatten_fragment_elements(elements2);
  return new Fragment(_pipe, "");
}

// build/dev/javascript/gleam_stdlib/gleam/set.mjs
var Set2 = class extends CustomType {
  constructor(dict2) {
    super();
    this.dict = dict2;
  }
};
function new$3() {
  return new Set2(new$());
}

// build/dev/javascript/lustre/lustre/internals/patch.mjs
var Diff = class extends CustomType {
  constructor(x0) {
    super();
    this[0] = x0;
  }
};
var Emit = class extends CustomType {
  constructor(x0, x1) {
    super();
    this[0] = x0;
    this[1] = x1;
  }
};
var Init = class extends CustomType {
  constructor(x0, x1) {
    super();
    this[0] = x0;
    this[1] = x1;
  }
};
function is_empty_element_diff(diff2) {
  return isEqual(diff2.created, new$()) && isEqual(
    diff2.removed,
    new$3()
  ) && isEqual(diff2.updated, new$());
}

// build/dev/javascript/lustre/lustre/internals/runtime.mjs
var Attrs = class extends CustomType {
  constructor(x0) {
    super();
    this[0] = x0;
  }
};
var Batch = class extends CustomType {
  constructor(x0, x1) {
    super();
    this[0] = x0;
    this[1] = x1;
  }
};
var Debug = class extends CustomType {
  constructor(x0) {
    super();
    this[0] = x0;
  }
};
var Dispatch = class extends CustomType {
  constructor(x0) {
    super();
    this[0] = x0;
  }
};
var Emit2 = class extends CustomType {
  constructor(x0, x1) {
    super();
    this[0] = x0;
    this[1] = x1;
  }
};
var Event2 = class extends CustomType {
  constructor(x0, x1) {
    super();
    this[0] = x0;
    this[1] = x1;
  }
};
var Shutdown = class extends CustomType {
};
var Subscribe = class extends CustomType {
  constructor(x0, x1) {
    super();
    this[0] = x0;
    this[1] = x1;
  }
};
var Unsubscribe = class extends CustomType {
  constructor(x0) {
    super();
    this[0] = x0;
  }
};
var ForceModel = class extends CustomType {
  constructor(x0) {
    super();
    this[0] = x0;
  }
};

// build/dev/javascript/lustre/vdom.ffi.mjs
function morph(prev, next, dispatch) {
  let out;
  let stack = [{ prev, next, parent: prev.parentNode }];
  while (stack.length) {
    let { prev: prev2, next: next2, parent } = stack.pop();
    while (next2.subtree !== void 0)
      next2 = next2.subtree();
    if (next2.content !== void 0) {
      if (!prev2) {
        const created = document.createTextNode(next2.content);
        parent.appendChild(created);
        out ??= created;
      } else if (prev2.nodeType === Node.TEXT_NODE) {
        if (prev2.textContent !== next2.content)
          prev2.textContent = next2.content;
        out ??= prev2;
      } else {
        const created = document.createTextNode(next2.content);
        parent.replaceChild(created, prev2);
        out ??= created;
      }
    } else if (next2.tag !== void 0) {
      const created = createElementNode({
        prev: prev2,
        next: next2,
        dispatch,
        stack
      });
      if (!prev2) {
        parent.appendChild(created);
      } else if (prev2 !== created) {
        parent.replaceChild(created, prev2);
      }
      out ??= created;
    } else if (next2.elements !== void 0) {
      for (const fragmentElement of forceChild(next2)) {
        stack.unshift({ prev: prev2, next: fragmentElement, parent });
        prev2 = prev2?.nextSibling;
      }
    }
  }
  return out;
}
function createElementNode({ prev, next, dispatch, stack }) {
  const namespace = next.namespace || "http://www.w3.org/1999/xhtml";
  const canMorph = prev && prev.nodeType === Node.ELEMENT_NODE && prev.localName === next.tag && prev.namespaceURI === (next.namespace || "http://www.w3.org/1999/xhtml");
  const el = canMorph ? prev : namespace ? document.createElementNS(namespace, next.tag) : document.createElement(next.tag);
  let handlersForEl;
  if (!registeredHandlers.has(el)) {
    const emptyHandlers = /* @__PURE__ */ new Map();
    registeredHandlers.set(el, emptyHandlers);
    handlersForEl = emptyHandlers;
  } else {
    handlersForEl = registeredHandlers.get(el);
  }
  const prevHandlers = canMorph ? new Set(handlersForEl.keys()) : null;
  const prevAttributes = canMorph ? new Set(Array.from(prev.attributes, (a) => a.name)) : null;
  let className = null;
  let style3 = null;
  let innerHTML = null;
  if (canMorph && next.tag === "textarea") {
    const innertText = next.children[Symbol.iterator]().next().value?.content;
    if (innertText !== void 0)
      el.value = innertText;
  }
  const delegated = [];
  for (const attr of next.attrs) {
    const name3 = attr[0];
    const value = attr[1];
    if (attr.as_property) {
      if (el[name3] !== value)
        el[name3] = value;
      if (canMorph)
        prevAttributes.delete(name3);
    } else if (name3.startsWith("on")) {
      const eventName = name3.slice(2);
      const callback = dispatch(value, eventName === "input");
      if (!handlersForEl.has(eventName)) {
        el.addEventListener(eventName, lustreGenericEventHandler);
      }
      handlersForEl.set(eventName, callback);
      if (canMorph)
        prevHandlers.delete(eventName);
    } else if (name3.startsWith("data-lustre-on-")) {
      const eventName = name3.slice(15);
      const callback = dispatch(lustreServerEventHandler);
      if (!handlersForEl.has(eventName)) {
        el.addEventListener(eventName, lustreGenericEventHandler);
      }
      handlersForEl.set(eventName, callback);
      el.setAttribute(name3, value);
    } else if (name3.startsWith("delegate:data-") || name3.startsWith("delegate:aria-")) {
      el.setAttribute(name3, value);
      delegated.push([name3.slice(10), value]);
    } else if (name3 === "class") {
      className = className === null ? value : className + " " + value;
    } else if (name3 === "style") {
      style3 = style3 === null ? value : style3 + value;
    } else if (name3 === "dangerous-unescaped-html") {
      innerHTML = value;
    } else {
      if (el.getAttribute(name3) !== value)
        el.setAttribute(name3, value);
      if (name3 === "value" || name3 === "selected")
        el[name3] = value;
      if (canMorph)
        prevAttributes.delete(name3);
    }
  }
  if (className !== null) {
    el.setAttribute("class", className);
    if (canMorph)
      prevAttributes.delete("class");
  }
  if (style3 !== null) {
    el.setAttribute("style", style3);
    if (canMorph)
      prevAttributes.delete("style");
  }
  if (canMorph) {
    for (const attr of prevAttributes) {
      el.removeAttribute(attr);
    }
    for (const eventName of prevHandlers) {
      handlersForEl.delete(eventName);
      el.removeEventListener(eventName, lustreGenericEventHandler);
    }
  }
  if (next.tag === "slot") {
    window.queueMicrotask(() => {
      for (const child of el.assignedElements()) {
        for (const [name3, value] of delegated) {
          if (!child.hasAttribute(name3)) {
            child.setAttribute(name3, value);
          }
        }
      }
    });
  }
  if (next.key !== void 0 && next.key !== "") {
    el.setAttribute("data-lustre-key", next.key);
  } else if (innerHTML !== null) {
    el.innerHTML = innerHTML;
    return el;
  }
  let prevChild = el.firstChild;
  let seenKeys = null;
  let keyedChildren = null;
  let incomingKeyedChildren = null;
  let firstChild = children(next).next().value;
  if (canMorph && firstChild !== void 0 && // Explicit checks are more verbose but truthy checks force a bunch of comparisons
  // we don't care about: it's never gonna be a number etc.
  firstChild.key !== void 0 && firstChild.key !== "") {
    seenKeys = /* @__PURE__ */ new Set();
    keyedChildren = getKeyedChildren(prev);
    incomingKeyedChildren = getKeyedChildren(next);
    for (const child of children(next)) {
      prevChild = diffKeyedChild(
        prevChild,
        child,
        el,
        stack,
        incomingKeyedChildren,
        keyedChildren,
        seenKeys
      );
    }
  } else {
    for (const child of children(next)) {
      stack.unshift({ prev: prevChild, next: child, parent: el });
      prevChild = prevChild?.nextSibling;
    }
  }
  while (prevChild) {
    const next2 = prevChild.nextSibling;
    el.removeChild(prevChild);
    prevChild = next2;
  }
  return el;
}
var registeredHandlers = /* @__PURE__ */ new WeakMap();
function lustreGenericEventHandler(event2) {
  const target = event2.currentTarget;
  if (!registeredHandlers.has(target)) {
    target.removeEventListener(event2.type, lustreGenericEventHandler);
    return;
  }
  const handlersForEventTarget = registeredHandlers.get(target);
  if (!handlersForEventTarget.has(event2.type)) {
    target.removeEventListener(event2.type, lustreGenericEventHandler);
    return;
  }
  handlersForEventTarget.get(event2.type)(event2);
}
function lustreServerEventHandler(event2) {
  const el = event2.currentTarget;
  const tag = el.getAttribute(`data-lustre-on-${event2.type}`);
  const data = JSON.parse(el.getAttribute("data-lustre-data") || "{}");
  const include = JSON.parse(el.getAttribute("data-lustre-include") || "[]");
  switch (event2.type) {
    case "input":
    case "change":
      include.push("target.value");
      break;
  }
  return {
    tag,
    data: include.reduce(
      (data2, property) => {
        const path = property.split(".");
        for (let i = 0, o = data2, e = event2; i < path.length; i++) {
          if (i === path.length - 1) {
            o[path[i]] = e[path[i]];
          } else {
            o[path[i]] ??= {};
            e = e[path[i]];
            o = o[path[i]];
          }
        }
        return data2;
      },
      { data }
    )
  };
}
function getKeyedChildren(el) {
  const keyedChildren = /* @__PURE__ */ new Map();
  if (el) {
    for (const child of children(el)) {
      const key = child?.key || child?.getAttribute?.("data-lustre-key");
      if (key)
        keyedChildren.set(key, child);
    }
  }
  return keyedChildren;
}
function diffKeyedChild(prevChild, child, el, stack, incomingKeyedChildren, keyedChildren, seenKeys) {
  while (prevChild && !incomingKeyedChildren.has(prevChild.getAttribute("data-lustre-key"))) {
    const nextChild = prevChild.nextSibling;
    el.removeChild(prevChild);
    prevChild = nextChild;
  }
  if (keyedChildren.size === 0) {
    stack.unshift({ prev: prevChild, next: child, parent: el });
    prevChild = prevChild?.nextSibling;
    return prevChild;
  }
  if (seenKeys.has(child.key)) {
    console.warn(`Duplicate key found in Lustre vnode: ${child.key}`);
    stack.unshift({ prev: null, next: child, parent: el });
    return prevChild;
  }
  seenKeys.add(child.key);
  const keyedChild = keyedChildren.get(child.key);
  if (!keyedChild && !prevChild) {
    stack.unshift({ prev: null, next: child, parent: el });
    return prevChild;
  }
  if (!keyedChild && prevChild !== null) {
    const placeholder = document.createTextNode("");
    el.insertBefore(placeholder, prevChild);
    stack.unshift({ prev: placeholder, next: child, parent: el });
    return prevChild;
  }
  if (!keyedChild || keyedChild === prevChild) {
    stack.unshift({ prev: prevChild, next: child, parent: el });
    prevChild = prevChild?.nextSibling;
    return prevChild;
  }
  el.insertBefore(keyedChild, prevChild);
  stack.unshift({ prev: keyedChild, next: child, parent: el });
  return prevChild;
}
function* children(element3) {
  for (const child of element3.children) {
    yield* forceChild(child);
  }
}
function* forceChild(element3) {
  if (element3.elements !== void 0) {
    for (const inner of element3.elements) {
      yield* forceChild(inner);
    }
  } else if (element3.subtree !== void 0) {
    yield* forceChild(element3.subtree());
  } else {
    yield element3;
  }
}

// build/dev/javascript/lustre/lustre.ffi.mjs
var LustreClientApplication = class _LustreClientApplication {
  /**
   * @template Flags
   *
   * @param {object} app
   * @param {(flags: Flags) => [Model, Lustre.Effect<Msg>]} app.init
   * @param {(msg: Msg, model: Model) => [Model, Lustre.Effect<Msg>]} app.update
   * @param {(model: Model) => Lustre.Element<Msg>} app.view
   * @param {string | HTMLElement} selector
   * @param {Flags} flags
   *
   * @returns {Gleam.Ok<(action: Lustre.Action<Lustre.Client, Msg>>) => void>}
   */
  static start({ init: init3, update: update2, view: view2 }, selector, flags) {
    if (!is_browser())
      return new Error(new NotABrowser());
    const root = selector instanceof HTMLElement ? selector : document.querySelector(selector);
    if (!root)
      return new Error(new ElementNotFound(selector));
    const app = new _LustreClientApplication(root, init3(flags), update2, view2);
    return new Ok((action) => app.send(action));
  }
  /**
   * @param {Element} root
   * @param {[Model, Lustre.Effect<Msg>]} init
   * @param {(model: Model, msg: Msg) => [Model, Lustre.Effect<Msg>]} update
   * @param {(model: Model) => Lustre.Element<Msg>} view
   *
   * @returns {LustreClientApplication}
   */
  constructor(root, [init3, effects], update2, view2) {
    this.root = root;
    this.#model = init3;
    this.#update = update2;
    this.#view = view2;
    this.#tickScheduled = window.requestAnimationFrame(
      () => this.#tick(effects.all.toArray(), true)
    );
  }
  /** @type {Element} */
  root;
  /**
   * @param {Lustre.Action<Lustre.Client, Msg>} action
   *
   * @returns {void}
   */
  send(action) {
    if (action instanceof Debug) {
      if (action[0] instanceof ForceModel) {
        this.#tickScheduled = window.cancelAnimationFrame(this.#tickScheduled);
        this.#queue = [];
        this.#model = action[0][0];
        const vdom = this.#view(this.#model);
        const dispatch = (handler, immediate = false) => (event2) => {
          const result = handler(event2);
          if (result instanceof Ok) {
            this.send(new Dispatch(result[0], immediate));
          }
        };
        const prev = this.root.firstChild ?? this.root.appendChild(document.createTextNode(""));
        morph(prev, vdom, dispatch);
      }
    } else if (action instanceof Dispatch) {
      const msg = action[0];
      const immediate = action[1] ?? false;
      this.#queue.push(msg);
      if (immediate) {
        this.#tickScheduled = window.cancelAnimationFrame(this.#tickScheduled);
        this.#tick();
      } else if (!this.#tickScheduled) {
        this.#tickScheduled = window.requestAnimationFrame(() => this.#tick());
      }
    } else if (action instanceof Emit2) {
      const event2 = action[0];
      const data = action[1];
      this.root.dispatchEvent(
        new CustomEvent(event2, {
          detail: data,
          bubbles: true,
          composed: true
        })
      );
    } else if (action instanceof Shutdown) {
      this.#tickScheduled = window.cancelAnimationFrame(this.#tickScheduled);
      this.#model = null;
      this.#update = null;
      this.#view = null;
      this.#queue = null;
      while (this.root.firstChild) {
        this.root.firstChild.remove();
      }
    }
  }
  /** @type {Model} */
  #model;
  /** @type {(model: Model, msg: Msg) => [Model, Lustre.Effect<Msg>]} */
  #update;
  /** @type {(model: Model) => Lustre.Element<Msg>} */
  #view;
  /** @type {Array<Msg>} */
  #queue = [];
  /** @type {number | undefined} */
  #tickScheduled;
  /**
   * @param {Lustre.Effect<Msg>[]} effects
   * @param {boolean} isFirstRender
   */
  #tick(effects = [], isFirstRender = false) {
    this.#tickScheduled = void 0;
    if (!this.#flush(effects, isFirstRender))
      return;
    const vdom = this.#view(this.#model);
    const dispatch = (handler, immediate = false) => (event2) => {
      const result = handler(event2);
      if (result instanceof Ok) {
        this.send(new Dispatch(result[0], immediate));
      }
    };
    const prev = this.root.firstChild ?? this.root.appendChild(document.createTextNode(""));
    morph(prev, vdom, dispatch);
  }
  #flush(effects = [], didUpdate = false) {
    while (this.#queue.length > 0) {
      const msg = this.#queue.shift();
      const [next, effect] = this.#update(this.#model, msg);
      didUpdate ||= this.#model !== next;
      effects = effects.concat(effect.all.toArray());
      this.#model = next;
    }
    while (effects.length > 0) {
      const effect = effects.shift();
      const dispatch = (msg) => this.send(new Dispatch(msg));
      const emit3 = (event2, data) => this.root.dispatchEvent(
        new CustomEvent(event2, {
          detail: data,
          bubbles: true,
          composed: true
        })
      );
      const select = () => {
      };
      effect({ dispatch, emit: emit3, select });
    }
    if (this.#queue.length > 0) {
      return this.#flush(effects, didUpdate);
    } else {
      return didUpdate;
    }
  }
};
var start = LustreClientApplication.start;
var make_lustre_client_component = ({ init: init3, update: update2, view: view2, on_attribute_change: on_attribute_change2 }, name3) => {
  if (!is_browser())
    return new Error(new NotABrowser());
  if (!name3.includes("-"))
    return new Error(new BadComponentName(name3));
  if (window.customElements.get(name3)) {
    return new Error(new ComponentAlreadyRegistered(name3));
  }
  const [model, effects] = init3(void 0);
  const hasAttributes = on_attribute_change2 instanceof Some;
  const component2 = class LustreClientComponent extends HTMLElement {
    /**
     * @returns {string[]}
     */
    static get observedAttributes() {
      if (hasAttributes) {
        return on_attribute_change2[0].entries().map(([name4]) => name4);
      } else {
        return [];
      }
    }
    /**
     * @returns {LustreClientComponent}
     */
    constructor() {
      super();
      this.attachShadow({ mode: "open" });
      if (hasAttributes) {
        on_attribute_change2[0].forEach((decoder2, name4) => {
          Object.defineProperty(this, name4, {
            get() {
              return this[`__mirrored__${name4}`];
            },
            set(value) {
              const prev = this[`__mirrored__${name4}`];
              if (this.#connected && isEqual(prev, value))
                return;
              this[`__mirrorred__${name4}`] = value;
              const decoded = decoder2(value);
              if (decoded instanceof Error)
                return;
              this.#queue.push(decoded[0]);
              if (this.#connected && !this.#tickScheduled) {
                this.#tickScheduled = window.requestAnimationFrame(
                  () => this.#tick()
                );
              }
            }
          });
        });
      }
    }
    /**
     *
     */
    connectedCallback() {
      this.#adoptStyleSheets().finally(() => {
        this.#tick(effects.all.toArray(), true);
        this.#connected = true;
      });
    }
    /**
     * @param {string} key
     * @param {string} prev
     * @param {string} next
     */
    attributeChangedCallback(key, prev, next) {
      if (prev !== next)
        this[key] = next;
    }
    /**
     *
     */
    disconnectedCallback() {
      this.#model = null;
      this.#queue = [];
      this.#tickScheduled = window.cancelAnimationFrame(this.#tickScheduled);
      this.#connected = false;
    }
    /**
     * @param {Lustre.Action<Msg, Lustre.ClientSpa>} action
     */
    send(action) {
      if (action instanceof Debug) {
        if (action[0] instanceof ForceModel) {
          this.#tickScheduled = window.cancelAnimationFrame(
            this.#tickScheduled
          );
          this.#queue = [];
          this.#model = action[0][0];
          const vdom = view2(this.#model);
          const dispatch = (handler, immediate = false) => (event2) => {
            const result = handler(event2);
            if (result instanceof Ok) {
              this.send(new Dispatch(result[0], immediate));
            }
          };
          const prev = this.shadowRoot.childNodes[this.#adoptedStyleElements.length] ?? this.shadowRoot.appendChild(document.createTextNode(""));
          morph(prev, vdom, dispatch);
        }
      } else if (action instanceof Dispatch) {
        const msg = action[0];
        const immediate = action[1] ?? false;
        this.#queue.push(msg);
        if (immediate) {
          this.#tickScheduled = window.cancelAnimationFrame(
            this.#tickScheduled
          );
          this.#tick();
        } else if (!this.#tickScheduled) {
          this.#tickScheduled = window.requestAnimationFrame(
            () => this.#tick()
          );
        }
      } else if (action instanceof Emit2) {
        const event2 = action[0];
        const data = action[1];
        this.dispatchEvent(
          new CustomEvent(event2, {
            detail: data,
            bubbles: true,
            composed: true
          })
        );
      }
    }
    /** @type {Element[]} */
    #adoptedStyleElements = [];
    /** @type {Model} */
    #model = model;
    /** @type {Array<Msg>} */
    #queue = [];
    /** @type {number | undefined} */
    #tickScheduled;
    /** @type {boolean} */
    #connected = true;
    #tick(effects2 = [], isFirstRender = false) {
      this.#tickScheduled = void 0;
      if (!this.#connected)
        return;
      if (!this.#flush(isFirstRender, effects2))
        return;
      const vdom = view2(this.#model);
      const dispatch = (handler, immediate = false) => (event2) => {
        const result = handler(event2);
        if (result instanceof Ok) {
          this.send(new Dispatch(result[0], immediate));
        }
      };
      const prev = this.shadowRoot.childNodes[this.#adoptedStyleElements.length] ?? this.shadowRoot.appendChild(document.createTextNode(""));
      console.log({ prev });
      morph(prev, vdom, dispatch);
    }
    #flush(didUpdate = false, effects2 = []) {
      while (this.#queue.length > 0) {
        const msg = this.#queue.shift();
        const [next, effect] = update2(this.#model, msg);
        didUpdate ||= this.#model !== next;
        effects2 = effects2.concat(effect.all.toArray());
        this.#model = next;
      }
      while (effects2.length > 0) {
        const effect = effects2.shift();
        const dispatch = (msg) => this.send(new Dispatch(msg));
        const emit3 = (event2, data) => this.dispatchEvent(
          new CustomEvent(event2, {
            detail: data,
            bubbles: true,
            composed: true
          })
        );
        const select = () => {
        };
        effect({ dispatch, emit: emit3, select });
      }
      if (this.#queue.length > 0) {
        return this.#flush(didUpdate, effects2);
      } else {
        return didUpdate;
      }
    }
    async #adoptStyleSheets() {
      const pendingParentStylesheets = [];
      for (const link of document.querySelectorAll("link[rel=stylesheet]")) {
        if (link.sheet)
          continue;
        pendingParentStylesheets.push(
          new Promise((resolve, reject) => {
            link.addEventListener("load", resolve);
            link.addEventListener("error", reject);
          })
        );
      }
      await Promise.allSettled(pendingParentStylesheets);
      while (this.#adoptedStyleElements.length) {
        this.#adoptedStyleElements.shift().remove();
        this.shadowRoot.firstChild.remove();
      }
      this.shadowRoot.adoptedStyleSheets = this.getRootNode().adoptedStyleSheets;
      const pending = [];
      for (const sheet of document.styleSheets) {
        try {
          this.shadowRoot.adoptedStyleSheets.push(sheet);
        } catch {
          try {
            const adoptedSheet = new CSSStyleSheet();
            for (const rule of sheet.cssRules) {
              adoptedSheet.insertRule(rule.cssText, adoptedSheet.cssRules.length);
            }
            this.shadowRoot.adoptedStyleSheets.push(adoptedSheet);
          } catch {
            const node = sheet.ownerNode.cloneNode();
            this.shadowRoot.prepend(node);
            this.#adoptedStyleElements.push(node);
            pending.push(
              new Promise((resolve, reject) => {
                node.onload = resolve;
                node.onerror = reject;
              })
            );
          }
        }
      }
      return Promise.allSettled(pending);
    }
  };
  window.customElements.define(name3, component2);
  return new Ok(void 0);
};
var LustreServerApplication = class _LustreServerApplication {
  static start({ init: init3, update: update2, view: view2, on_attribute_change: on_attribute_change2 }, flags) {
    const app = new _LustreServerApplication(
      init3(flags),
      update2,
      view2,
      on_attribute_change2
    );
    return new Ok((action) => app.send(action));
  }
  constructor([model, effects], update2, view2, on_attribute_change2) {
    this.#model = model;
    this.#update = update2;
    this.#view = view2;
    this.#html = view2(model);
    this.#onAttributeChange = on_attribute_change2;
    this.#renderers = /* @__PURE__ */ new Map();
    this.#handlers = handlers(this.#html);
    this.#tick(effects.all.toArray());
  }
  send(action) {
    if (action instanceof Attrs) {
      for (const attr of action[0]) {
        const decoder2 = this.#onAttributeChange.get(attr[0]);
        if (!decoder2)
          continue;
        const msg = decoder2(attr[1]);
        if (msg instanceof Error)
          continue;
        this.#queue.push(msg);
      }
      this.#tick();
    } else if (action instanceof Batch) {
      this.#queue = this.#queue.concat(action[0].toArray());
      this.#tick(action[1].all.toArray());
    } else if (action instanceof Debug) {
    } else if (action instanceof Dispatch) {
      this.#queue.push(action[0]);
      this.#tick();
    } else if (action instanceof Emit2) {
      const event2 = new Emit(action[0], action[1]);
      for (const [_, renderer] of this.#renderers) {
        renderer(event2);
      }
    } else if (action instanceof Event2) {
      const handler = this.#handlers.get(action[0]);
      if (!handler)
        return;
      const msg = handler(action[1]);
      if (msg instanceof Error)
        return;
      this.#queue.push(msg[0]);
      this.#tick();
    } else if (action instanceof Subscribe) {
      const attrs = keys(this.#onAttributeChange);
      const patch = new Init(attrs, this.#html);
      this.#renderers = this.#renderers.set(action[0], action[1]);
      action[1](patch);
    } else if (action instanceof Unsubscribe) {
      this.#renderers = this.#renderers.delete(action[0]);
    }
  }
  #model;
  #update;
  #queue;
  #view;
  #html;
  #renderers;
  #handlers;
  #onAttributeChange;
  #tick(effects = []) {
    if (!this.#flush(false, effects))
      return;
    const vdom = this.#view(this.#model);
    const diff2 = elements(this.#html, vdom);
    if (!is_empty_element_diff(diff2)) {
      const patch = new Diff(diff2);
      for (const [_, renderer] of this.#renderers) {
        renderer(patch);
      }
    }
    this.#html = vdom;
    this.#handlers = diff2.handlers;
  }
  #flush(didUpdate = false, effects = []) {
    while (this.#queue.length > 0) {
      const msg = this.#queue.shift();
      const [next, effect] = this.#update(this.#model, msg);
      didUpdate ||= this.#model !== next;
      effects = effects.concat(effect.all.toArray());
      this.#model = next;
    }
    while (effects.length > 0) {
      const effect = effects.shift();
      const dispatch = (msg) => this.send(new Dispatch(msg));
      const emit3 = (event2, data) => this.root.dispatchEvent(
        new CustomEvent(event2, {
          detail: data,
          bubbles: true,
          composed: true
        })
      );
      const select = () => {
      };
      effect({ dispatch, emit: emit3, select });
    }
    if (this.#queue.length > 0) {
      return this.#flush(didUpdate, effects);
    } else {
      return didUpdate;
    }
  }
};
var start_server_application = LustreServerApplication.start;
var is_browser = () => globalThis.window && window.document;

// build/dev/javascript/lustre/lustre.mjs
var App = class extends CustomType {
  constructor(init3, update2, view2, on_attribute_change2) {
    super();
    this.init = init3;
    this.update = update2;
    this.view = view2;
    this.on_attribute_change = on_attribute_change2;
  }
};
var BadComponentName = class extends CustomType {
  constructor(name3) {
    super();
    this.name = name3;
  }
};
var ComponentAlreadyRegistered = class extends CustomType {
  constructor(name3) {
    super();
    this.name = name3;
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
function application(init3, update2, view2) {
  return new App(init3, update2, view2, new None());
}
function simple(init3, update2, view2) {
  let init$1 = (flags) => {
    return [init3(flags), none()];
  };
  let update$1 = (model, msg) => {
    return [update2(model, msg), none()];
  };
  return application(init$1, update$1, view2);
}
function component(init3, update2, view2, on_attribute_change2) {
  return new App(init3, update2, view2, new Some(on_attribute_change2));
}
function start2(app, selector, flags) {
  return guard(
    !is_browser(),
    new Error(new NotABrowser()),
    () => {
      return start(app, selector, flags);
    }
  );
}

// build/dev/javascript/lustre/lustre/element/html.mjs
function text2(content2) {
  return text(content2);
}
function style2(attrs, css) {
  return element2("style", attrs, toList([text2(css)]));
}
function article(attrs, children2) {
  return element2("article", attrs, children2);
}
function footer(attrs, children2) {
  return element2("footer", attrs, children2);
}
function header(attrs, children2) {
  return element2("header", attrs, children2);
}
function h3(attrs, children2) {
  return element2("h3", attrs, children2);
}
function main(attrs, children2) {
  return element2("main", attrs, children2);
}
function div(attrs, children2) {
  return element2("div", attrs, children2);
}
function hr(attrs) {
  return element2("hr", attrs, toList([]));
}
function p(attrs, children2) {
  return element2("p", attrs, children2);
}
function span(attrs, children2) {
  return element2("span", attrs, children2);
}
function img(attrs) {
  return element2("img", attrs, toList([]));
}
function button(attrs, children2) {
  return element2("button", attrs, children2);
}
function slot(attrs) {
  return element2("slot", attrs, toList([]));
}

// build/dev/javascript/lustre_ui/lustre/ui/badge.mjs
var base_classes = "inline-flex items-center px-w-sm py-w-xs text-xs font-semibold";
var focus_classes = "focus:outline-none focus:ring-2 focus:ring-ring focus:ring-offset-2";
var empty_classes = "[&:empty]:p-0 [&:empty]:rounded-full";
function badge(attributes, children2) {
  return div(
    prepend(
      class$(base_classes),
      prepend(
        class$(focus_classes),
        prepend(class$(empty_classes), attributes)
      )
    ),
    children2
  );
}
function solid(attributes, children2) {
  let colour_classes = "bg-w-solid text-w-solid-text";
  let hover_classes = "hover:bg-w-solid/80";
  return badge(
    prepend(
      class$(colour_classes),
      prepend(class$(hover_classes), attributes)
    ),
    children2
  );
}

// build/dev/javascript/lustre_ui/lustre/ui/button.mjs
function round3() {
  return class$("rounded-w-sm");
}
function small() {
  return class$("h-8 px-w-sm");
}
function primary() {
  return class$("primary");
}
var base_classes2 = "min-h-8 inline-flex items-center justify-center whitespace-nowrap translate-y-0";
var focus_classes2 = "focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-ring";
var active_classes = "active:translate-y-px";
var disabled_classes = "disabled:pointer-events-none disabled:opacity-50";
function button2(attributes, children2) {
  return button(
    prepend(
      class$(base_classes2),
      prepend(
        class$(disabled_classes),
        prepend(
          class$(focus_classes2),
          prepend(class$(active_classes), attributes)
        )
      )
    ),
    children2
  );
}
function solid2(attributes, children2) {
  let colour_classes = "bg-w-solid text-w-solid-text";
  let hover_classes = "hover:bg-w-solid-subtle";
  return button2(
    prepend(
      class$(colour_classes),
      prepend(class$(hover_classes), attributes)
    ),
    children2
  );
}

// build/dev/javascript/lustre_ui/lustre/ui/card.mjs
var card_base_classes = "border border-w-accent-subtle bg-w-bg-subtle [&>*+*]:pt-0";
function custom2(attributes, children2) {
  return article(
    prepend(class$(card_base_classes), attributes),
    children2
  );
}
var card_header_classes = "flex flex-col space-y-w-xs p-w-xl";
function header2(attributes, children2) {
  return header(
    prepend(class$(card_header_classes), attributes),
    children2
  );
}
var card_title_classes = "font-semibold leading-none tracking-tight";
function title(attributes, children2) {
  return h3(
    prepend(class$(card_title_classes), attributes),
    children2
  );
}
var card_description_classes = "text-w-text-subtle";
function description(attributes, children2) {
  return p(
    prepend(class$(card_description_classes), attributes),
    children2
  );
}
var card_content_classes = "p-w-xl";
function content(attributes, children2) {
  return main(
    prepend(class$(card_content_classes), attributes),
    children2
  );
}
function with_header(attributes, header_children, content_children) {
  return custom2(
    attributes,
    toList([
      header2(toList([]), header_children),
      content(toList([]), content_children)
    ])
  );
}
var card_footer_classes = "flex items-center p-w-xl";
function footer2(attributes, children2) {
  return footer(
    prepend(class$(card_footer_classes), attributes),
    children2
  );
}
function with_footer(attributes, content_children, footer_children) {
  return custom2(
    attributes,
    toList([
      content(toList([]), content_children),
      footer2(toList([]), footer_children)
    ])
  );
}

// build/dev/javascript/gleam_community_colour/gleam_community/colour.mjs
var Rgba = class extends CustomType {
  constructor(r, g, b, a) {
    super();
    this.r = r;
    this.g = g;
    this.b = b;
    this.a = a;
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
  let h = (() => {
    if (hue < 0) {
      return hue + 1;
    } else if (hue > 1) {
      return hue - 1;
    } else {
      return hue;
    }
  })();
  let h_t_6 = h * 6;
  let h_t_2 = h * 2;
  let h_t_3 = h * 3;
  if (h_t_6 < 1) {
    return m1 + (m2 - m1) * h * 6;
  } else if (h_t_2 < 1) {
    return m2;
  } else if (h_t_3 < 2) {
    return m1 + (m2 - m1) * (divideFloat(2, 3) - h) * 6;
  } else {
    return m1;
  }
}
function hsla_to_rgba(h, s, l, a) {
  let m2 = (() => {
    let $ = l <= 0.5;
    if ($) {
      return l * (s + 1);
    } else {
      return l + s - l * s;
    }
  })();
  let m1 = l * 2 - m2;
  let r = hue_to_rgb(h + divideFloat(1, 3), m1, m2);
  let g = hue_to_rgb(h, m1, m2);
  let b = hue_to_rgb(h - divideFloat(1, 3), m1, m2);
  return [r, g, b, a];
}
function from_rgb255(red2, green2, blue2) {
  return then$(
    (() => {
      let _pipe = red2;
      let _pipe$1 = to_float(_pipe);
      let _pipe$2 = divide(_pipe$1, 255);
      return then$(_pipe$2, valid_colour_value);
    })(),
    (r) => {
      return then$(
        (() => {
          let _pipe = green2;
          let _pipe$1 = to_float(_pipe);
          let _pipe$2 = divide(_pipe$1, 255);
          return then$(_pipe$2, valid_colour_value);
        })(),
        (g) => {
          return then$(
            (() => {
              let _pipe = blue2;
              let _pipe$1 = to_float(_pipe);
              let _pipe$2 = divide(_pipe$1, 255);
              return then$(_pipe$2, valid_colour_value);
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
function to_rgba(colour2) {
  if (colour2 instanceof Rgba) {
    let r = colour2.r;
    let g = colour2.g;
    let b = colour2.b;
    let a = colour2.a;
    return [r, g, b, a];
  } else {
    let h = colour2.h;
    let s = colour2.s;
    let l = colour2.l;
    let a = colour2.a;
    return hsla_to_rgba(h, s, l, a);
  }
}

// build/dev/javascript/lustre_ui/lustre/ui/colour.mjs
var ColourPalette = class extends CustomType {
  constructor(base, primary2, secondary, success, warning, danger) {
    super();
    this.base = base;
    this.primary = primary2;
    this.secondary = secondary;
    this.success = success;
    this.warning = warning;
    this.danger = danger;
  }
};
var ColourScale = class extends CustomType {
  constructor(bg, bg_subtle, tint, tint_subtle, tint_strong, accent, accent_subtle, accent_strong, solid3, solid_subtle, solid_strong, solid_text, text3, text_subtle) {
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
    this.text = text3;
    this.text_subtle = text_subtle;
  }
};
function rgb(r, g, b) {
  let r$1 = min(255, max(0, r));
  let g$1 = min(255, max(0, g));
  let b$1 = min(255, max(0, b));
  let $ = from_rgb255(r$1, g$1, b$1);
  if (!$.isOk()) {
    throw makeError(
      "let_assert",
      "lustre/ui/colour",
      63,
      "rgb",
      "Pattern match failed, no pattern matched the value.",
      { value: $ }
    );
  }
  let colour2 = $[0];
  return colour2;
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
  constructor(id, selector, font, radius, space, light, dark) {
    super();
    this.id = id;
    this.selector = selector;
    this.font = font;
    this.radius = radius;
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
var Class = class extends CustomType {
  constructor(x0) {
    super();
    this[0] = x0;
  }
};
var DataAttribute = class extends CustomType {
  constructor(x0, x1) {
    super();
    this[0] = x0;
    this[1] = x1;
  }
};
var SizeVariables = class extends CustomType {
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
function to_css_selector(selector) {
  if (selector instanceof Global) {
    return "";
  } else if (selector instanceof Class) {
    let class$2 = selector[0];
    return "." + class$2;
  } else if (selector instanceof DataAttribute && selector[1] === "") {
    let name3 = selector[0];
    return "[data-" + name3 + "]";
  } else {
    let name3 = selector[0];
    let value = selector[1];
    return "[data-" + name3 + "=" + value + "]";
  }
}
function to_css_rgb(colour2) {
  let $ = to_rgba(colour2);
  let r = $[0];
  let g = $[1];
  let b = $[2];
  let r$1 = (() => {
    let _pipe = round2(r * 255);
    return to_string3(_pipe);
  })();
  let g$1 = (() => {
    let _pipe = round2(g * 255);
    return to_string3(_pipe);
  })();
  let b$1 = (() => {
    let _pipe = round2(b * 255);
    return to_string3(_pipe);
  })();
  return r$1 + " " + g$1 + " " + b$1;
}
function var$(name3) {
  return "--lustre-ui-" + name3;
}
function to_css_variable(name3, value) {
  return var$(name3) + ":" + value + ";";
}
function to_colour_scale_variables(scale, name3) {
  return concat2(
    toList([
      to_css_variable(name3 + "-bg", to_css_rgb(scale.bg)),
      to_css_variable(name3 + "-bg-subtle", to_css_rgb(scale.bg_subtle)),
      to_css_variable(name3 + "-tint", to_css_rgb(scale.tint)),
      to_css_variable(name3 + "-tint-subtle", to_css_rgb(scale.tint_subtle)),
      to_css_variable(name3 + "-tint-strong", to_css_rgb(scale.tint_strong)),
      to_css_variable(name3 + "-accent", to_css_rgb(scale.accent)),
      to_css_variable(name3 + "-accent-subtle", to_css_rgb(scale.accent_subtle)),
      to_css_variable(name3 + "-accent-strong", to_css_rgb(scale.accent_strong)),
      to_css_variable(name3 + "-solid", to_css_rgb(scale.solid)),
      to_css_variable(name3 + "-solid-subtle", to_css_rgb(scale.solid_subtle)),
      to_css_variable(name3 + "-solid-strong", to_css_rgb(scale.solid_strong)),
      to_css_variable(name3 + "-solid-text", to_css_rgb(scale.solid_text)),
      to_css_variable(name3 + "-text", to_css_rgb(scale.text)),
      to_css_variable(name3 + "-text-subtle", to_css_rgb(scale.text_subtle)),
      "& ." + name3 + ', [data-scale="' + name3 + '"] {',
      "--lustre-ui-bg: var(--lustre-ui-" + name3 + "-bg);",
      "--lustre-ui-bg-subtle: var(--lustre-ui-" + name3 + "-bg-subtle);",
      "--lustre-ui-tint: var(--lustre-ui-" + name3 + "-tint);",
      "--lustre-ui-tint-subtle: var(--lustre-ui-" + name3 + "-tint-subtle);",
      "--lustre-ui-tint-strong: var(--lustre-ui-" + name3 + "-tint-strong);",
      "--lustre-ui-accent: var(--lustre-ui-" + name3 + "-accent);",
      "--lustre-ui-accent-subtle: var(--lustre-ui-" + name3 + "-accent-subtle);",
      "--lustre-ui-accent-strong: var(--lustre-ui-" + name3 + "-accent-strong);",
      "--lustre-ui-solid: var(--lustre-ui-" + name3 + "-solid);",
      "--lustre-ui-solid-subtle: var(--lustre-ui-" + name3 + "-solid-subtle);",
      "--lustre-ui-solid-strong: var(--lustre-ui-" + name3 + "-solid-strong);",
      "--lustre-ui-solid-text: var(--lustre-ui-" + name3 + "-solid-text);",
      "--lustre-ui-text: var(--lustre-ui-" + name3 + "-text);",
      "--lustre-ui-text-subtle: var(--lustre-ui-" + name3 + "-text-subtle);",
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
      to_css_variable("radius-xs", to_string2(theme.radius.xs) + "rem"),
      to_css_variable("radius-sm", to_string2(theme.radius.sm) + "rem"),
      to_css_variable("radius-md", to_string2(theme.radius.md) + "rem"),
      to_css_variable("radius-lg", to_string2(theme.radius.lg) + "rem"),
      to_css_variable("radius-xl", to_string2(theme.radius.xl) + "rem"),
      to_css_variable(
        "radius-xl-2",
        to_string2(theme.radius.xl_2) + "rem"
      ),
      to_css_variable(
        "radius-xl-3",
        to_string2(theme.radius.xl_3) + "rem"
      ),
      to_css_variable("spacing-xs", to_string2(theme.space.xs) + "rem"),
      to_css_variable("spacing-sm", to_string2(theme.space.sm) + "rem"),
      to_css_variable("spacing-md", to_string2(theme.space.md) + "rem"),
      to_css_variable("spacing-lg", to_string2(theme.space.lg) + "rem"),
      to_css_variable("spacing-xl", to_string2(theme.space.xl) + "rem"),
      to_css_variable(
        "spacing-xl-2",
        to_string2(theme.space.xl_2) + "rem"
      ),
      to_css_variable(
        "spacing-xl-3",
        to_string2(theme.space.xl_3) + "rem"
      ),
      to_color_palette_variables(theme.light, "light")
    ])
  );
}
var sans = 'ui-sans-serif, system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, "Noto Sans", sans-serif, "Apple Color Emoji", "Segoe UI Emoji", "Segoe UI Symbol", "Noto Color Emoji"';
var code = 'ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, "Liberation Mono", "Courier New", monospace';
var stylesheet_global_light_no_dark = "\nbody {\n  ${rules}\n\n  background-color: rgb(var(--lustre-ui-bg));\n  color: rgb(var(--lustre-ui-text));\n}\n";
var stylesheet_global_light_global_dark = "\nbody {\n  ${rules}\n\n  background-color: rgb(var(--lustre-ui-bg));\n  color: rgb(var(--lustre-ui-text));\n}\n\n@media (prefers-color-scheme: dark) {\n  body {\n    ${dark_rules}\n  }\n}\n";
var stylesheet_global_light_scoped_dark = "\nbody {\n  ${rules}\n\n  background-color: rgb(var(--lustre-ui-bg));\n  color: rgb(var(--lustre-ui-text));\n}\n\nbody${dark_selector}, body ${dark_selector} {\n  ${dark_rules}\n}\n\n@media (prefers-color-scheme: dark) {\n  body {\n    ${dark_rules}\n  }\n}\n";
var stylesheet_scoped_light_no_dark = "\n${selector} {\n  ${rules}\n\n  background-color: rgb(var(--lustre-ui-bg));\n  color: rgb(var(--lustre-ui-text));\n}\n";
var stylesheet_scoped_light_global_dark = "\n${selector} {\n  ${rules}\n\n  background-color: rgb(var(--lustre-ui-bg));\n  color: rgb(var(--lustre-ui-text));\n}\n\n@media (prefers-color-scheme: dark) {\n  ${selector} {\n    ${dark_rules}\n  }\n}\n";
var stylesheet_scoped_light_scoped_dark = "\n${selector} {\n  ${rules}\n\n  background-color: rgb(var(--lustre-ui-bg));\n  color: rgb(var(--lustre-ui-text));\n}\n\n${selector}${dark_selector}, ${selector} ${dark_selector} {\n  ${dark_rules}\n}\n\n@media (prefers-color-scheme: dark) {\n  ${selector} {\n    ${dark_rules}\n  }\n}\n";
function to_style(theme) {
  let data_attr = attribute("data-lustre-ui-theme", theme.id);
  let $ = theme.selector;
  let $1 = theme.dark;
  if ($ instanceof Global && $1 instanceof None) {
    let _pipe = stylesheet_global_light_no_dark;
    let _pipe$1 = replace(_pipe, "${rules}", to_css_variables(theme));
    return ((_capture) => {
      return style2(toList([data_attr]), _capture);
    })(
      _pipe$1
    );
  } else if ($ instanceof Global && $1 instanceof Some && $1[0][0] instanceof Global) {
    let dark_palette = $1[0][1];
    let _pipe = stylesheet_global_light_global_dark;
    let _pipe$1 = replace(_pipe, "${rules}", to_css_variables(theme));
    let _pipe$2 = replace(
      _pipe$1,
      "${dark_rules}",
      to_color_palette_variables(dark_palette, "dark")
    );
    return ((_capture) => {
      return style2(toList([data_attr]), _capture);
    })(
      _pipe$2
    );
  } else if ($ instanceof Global && $1 instanceof Some) {
    let dark_selector = $1[0][0];
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
    return ((_capture) => {
      return style2(toList([data_attr]), _capture);
    })(
      _pipe$3
    );
  } else if ($1 instanceof None) {
    let selector = $;
    let _pipe = stylesheet_scoped_light_no_dark;
    let _pipe$1 = replace(
      _pipe,
      "${selector}",
      to_css_selector(selector)
    );
    let _pipe$2 = replace(_pipe$1, "${rules}", to_css_variables(theme));
    return ((_capture) => {
      return style2(toList([data_attr]), _capture);
    })(
      _pipe$2
    );
  } else if ($1 instanceof Some && $1[0][0] instanceof Global) {
    let selector = $;
    let dark_palette = $1[0][1];
    let _pipe = stylesheet_scoped_light_global_dark;
    let _pipe$1 = replace(
      _pipe,
      "${selector}",
      to_css_selector(selector)
    );
    let _pipe$2 = replace(_pipe$1, "${rules}", to_css_variables(theme));
    let _pipe$3 = replace(
      _pipe$2,
      "${dark_rules}",
      to_color_palette_variables(dark_palette, "dark")
    );
    return ((_capture) => {
      return style2(toList([data_attr]), _capture);
    })(
      _pipe$3
    );
  } else {
    let selector = $;
    let dark_selector = $1[0][0];
    let dark_palette = $1[0][1];
    let _pipe = stylesheet_scoped_light_scoped_dark;
    let _pipe$1 = replace(
      _pipe,
      "${selector}",
      to_css_selector(selector)
    );
    let _pipe$2 = replace(_pipe$1, "${rules}", to_css_variables(theme));
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
    return ((_capture) => {
      return style2(toList([data_attr]), _capture);
    })(
      _pipe$4
    );
  }
}
var spacing = /* @__PURE__ */ new SizeVariables(
  "var(--lustre-ui-spacing-xs)",
  "var(--lustre-ui-spacing-sm)",
  "var(--lustre-ui-spacing-md)",
  "var(--lustre-ui-spacing-lg)",
  "var(--lustre-ui-spacing-xl)",
  "var(--lustre-ui-spacing-xl_2)",
  "var(--lustre-ui-spacing-xl_3)"
);
function default$() {
  let id = "lustre-ui-default";
  let font$1 = new Fonts(sans, sans, code);
  let radius$1 = new SizeScale(0.125, 0.25, 0.375, 0.5, 0.75, 1, 1.5);
  let space = new SizeScale(0.25, 0.5, 0.75, 1, 1.5, 2.5, 4);
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

// build/dev/javascript/lustre_ui/lustre/ui/divider.mjs
function vertical() {
  return style(
    toList([
      ["flex-direction", "column"],
      ["--l-divider-size-x", "0"],
      ["--l-divider-size-y", "var(--l-divider-size)"],
      ["margin", "0 var(--l-divider-margin)"]
    ])
  );
}
function thin() {
  return style(toList([["--l-divider-size", "1px"]]));
}
function colour(colour2) {
  return style(toList([["--l-divider-colour", colour2]]));
}
function margin(margin2) {
  return style(toList([["--l-divider-margin", margin2]]));
}
var default_width = "2px";
var colour_tint = "rgb(var(--lustre-ui-tint))";
function css_variables_setup() {
  return toList([
    ["--l-divider-colour", colour_tint],
    ["--l-divider-size", default_width],
    ["--l-divider-size-x", "var(--l-divider-size)"],
    ["--l-divider-size-y", "0"],
    ["--l-divider-margin", "0"]
  ]);
}
function divider(attributes, children2) {
  if (children2.hasLength(0)) {
    return hr(
      prepend(
        class$("self-stretch border-solid border-0"),
        prepend(
          class$("border-[var(--l-divider-colour)]"),
          prepend(
            style(
              prepend(
                ["border-top-width", "var(--l-divider-size-x)"],
                prepend(
                  ["border-left-width", "var(--l-divider-size-y)"],
                  prepend(
                    ["margin", "var(--l-divider-margin) 0"],
                    css_variables_setup()
                  )
                )
              )
            ),
            attributes
          )
        )
      )
    );
  } else {
    return div(
      prepend(
        class$("self-stretch"),
        prepend(
          class$(
            "flex items-center justify-center gap-w-sm leading-none"
          ),
          prepend(
            class$("text-sm"),
            prepend(
              class$("before:content-[''] before:block before:grow"),
              prepend(
                class$("after:content-[''] after:block after:grow"),
                prepend(
                  class$(
                    "before:w-[var(--l-divider-size-y)] before:h-[var(--l-divider-size-x)]"
                  ),
                  prepend(
                    class$(
                      "after:w-[var(--l-divider-size-y)] after:h-[var(--l-divider-size-x)]"
                    ),
                    prepend(
                      class$(
                        "before:bg-[var(--l-divider-colour)] after:bg-[var(--l-divider-colour)]"
                      ),
                      prepend(
                        style(
                          prepend(
                            ["margin", "var(--l-divider-margin) 0"],
                            css_variables_setup()
                          )
                        ),
                        attributes
                      )
                    )
                  )
                )
              )
            )
          )
        )
      ),
      children2
    );
  }
}

// build/dev/javascript/decipher/decipher.mjs
function tagged_union(tag, variants) {
  let switch$ = from_list(variants);
  return (dynamic2) => {
    return try$(
      tag(dynamic2),
      (kind) => {
        let $ = get(switch$, kind);
        if ($.isOk()) {
          let decoder2 = $[0];
          return decoder2(dynamic2);
        } else {
          let tags = (() => {
            let _pipe = keys(switch$);
            let _pipe$1 = map(_pipe, inspect2);
            return join2(_pipe$1, " | ");
          })();
          let path = (() => {
            let $1 = tag(identity(void 0));
            if (!$1.isOk() && $1[0].atLeastLength(1) && $1[0].head instanceof DecodeError) {
              let path2 = $1[0].head.path;
              return path2;
            } else {
              return toList([]);
            }
          })();
          return new Error(
            toList([new DecodeError(tags, inspect2(tag), path)])
          );
        }
      }
    );
  };
}
function enum$(variants) {
  return tagged_union(
    string,
    map(
      variants,
      (_capture) => {
        return map_second(
          _capture,
          (variant) => {
            return (_) => {
              return new Ok(variant);
            };
          }
        );
      }
    )
  );
}
function bool_string(dynamic2) {
  return enum$(
    toList([
      ["true", true],
      ["True", true],
      ["on", true],
      ["On", true],
      ["yes", true],
      ["Yes", true],
      ["false", false],
      ["False", false],
      ["off", false],
      ["Off", false],
      ["no", false],
      ["No", false]
    ])
  )(dynamic2);
}
function index_list(idx, decoder2) {
  return (dynamic2) => {
    return try$(
      list(dynamic)(dynamic2),
      (list3) => {
        let $ = idx >= 0;
        if ($) {
          let _pipe = list3;
          let _pipe$1 = drop(_pipe, idx);
          let _pipe$2 = first(_pipe$1);
          let _pipe$3 = replace_error(
            _pipe$2,
            toList([
              new DecodeError(
                "A list with at least" + to_string3(idx + 1) + "elements",
                "A list with" + to_string3(length2(list3)) + "elements",
                toList([to_string3(idx)])
              )
            ])
          );
          return then$(_pipe$3, decoder2);
        } else {
          return new Error(
            toList([
              new DecodeError(
                "An 'index' decoder with a non-negative index",
                to_string3(idx),
                toList([])
              )
            ])
          );
        }
      }
    );
  };
}
function index2(idx, decoder2) {
  return any(
    toList([
      element(idx, decoder2),
      field(to_string3(idx), decoder2),
      index_list(idx, decoder2)
    ])
  );
}
function do_at(path, decoder2, dynamic2) {
  if (path.hasLength(0)) {
    return decoder2(dynamic2);
  } else {
    let head = path.head;
    let rest2 = path.tail;
    let $ = parse(head);
    if ($.isOk()) {
      let idx = $[0];
      let _pipe = dynamic2;
      let _pipe$1 = index2(idx, dynamic)(_pipe);
      return then$(
        _pipe$1,
        (_capture) => {
          return do_at(rest2, decoder2, _capture);
        }
      );
    } else {
      let _pipe = dynamic2;
      let _pipe$1 = field(head, dynamic)(_pipe);
      return then$(
        _pipe$1,
        (_capture) => {
          return do_at(rest2, decoder2, _capture);
        }
      );
    }
  }
}
function at(path, decoder2) {
  return (dynamic2) => {
    return do_at(path, decoder2, dynamic2);
  };
}

// build/dev/javascript/lustre/lustre/event.mjs
function emit2(event2, data) {
  return event(event2, data);
}
function on2(name3, handler) {
  return on(name3, handler);
}

// build/dev/javascript/lustre_ui/dom.ffi.mjs
var assigned_elements = (slot2) => {
  if (slot2 instanceof HTMLSlotElement) {
    return new Ok(List.fromArray(slot2.assignedElements()));
  }
  return new Error(List.fromArray([]));
};

// build/dev/javascript/lustre_ui/lustre/ui/primitives/collapse.mjs
var Model2 = class extends CustomType {
  constructor(height, expanded2) {
    super();
    this.height = height;
    this.expanded = expanded2;
  }
};
var ParentChangedContent = class extends CustomType {
  constructor(x0) {
    super();
    this[0] = x0;
  }
};
var ParentSetExpanded = class extends CustomType {
  constructor(x0) {
    super();
    this[0] = x0;
  }
};
var UserPressedTrigger = class extends CustomType {
  constructor(x0) {
    super();
    this[0] = x0;
  }
};
function expanded(is_expanded) {
  return attribute(
    "aria-expanded",
    (() => {
      let _pipe = to_string5(is_expanded);
      return lowercase2(_pipe);
    })()
  );
}
function duration(ms) {
  return style(
    toList([["transition-duration", to_string3(ms) + "ms"]])
  );
}
function on_change(handler) {
  return on2(
    "change",
    (event2) => {
      return try$(
        at(toList(["detail", "expanded"]), bool)(event2),
        (is_expanded) => {
          return new Ok(handler(is_expanded));
        }
      );
    }
  );
}
function init2(_) {
  let model = new Model2(0, false);
  let effect = none();
  return [model, effect];
}
function update(model, msg) {
  if (msg instanceof ParentChangedContent) {
    let height = msg[0];
    return [model.withFields({ height }), none()];
  } else if (msg instanceof ParentSetExpanded) {
    let expanded$1 = msg[0];
    return [model.withFields({ expanded: expanded$1 }), none()];
  } else {
    let height = msg[0];
    let model$1 = model.withFields({ height });
    let emit_change = emit2(
      "change",
      object2(toList([["expanded", bool2(!model$1.expanded)]]))
    );
    let emit_expand_collapse = (() => {
      let $ = model$1.expanded;
      if ($) {
        return emit2("collapse", null$());
      } else {
        return emit2("expand", null$());
      }
    })();
    let effect = batch(toList([emit_change, emit_expand_collapse]));
    return [model$1, effect];
  }
}
function on_attribute_change() {
  return from_list(
    toList([
      [
        "aria-expanded",
        (value) => {
          let _pipe = value;
          let _pipe$1 = bool_string(_pipe);
          return map2(
            _pipe$1,
            (var0) => {
              return new ParentSetExpanded(var0);
            }
          );
        }
      ]
    ])
  );
}
function calculate_slot_height(slot2) {
  return try$(
    assigned_elements(slot2),
    (content2) => {
      return try$(
        list(field("clientHeight", float))(content2),
        (heights) => {
          return new Ok(sum(heights));
        }
      );
    }
  );
}
function handle_click(event2) {
  let path = toList(["currentTarget", "nextElementSibling", "firstElementChild"]);
  return try$(
    at(path, dynamic)(event2),
    (slot2) => {
      return try$(
        calculate_slot_height(slot2),
        (height) => {
          return new Ok(new UserPressedTrigger(height));
        }
      );
    }
  );
}
function handle_keydown(event2) {
  return try$(
    field("key", string)(event2),
    (key) => {
      if (key === "Enter") {
        let path = toList([
          "currentTarget",
          "nextElementSibling",
          "firstElementChild"
        ]);
        return try$(
          at(path, dynamic)(event2),
          (slot2) => {
            return try$(
              calculate_slot_height(slot2),
              (height) => {
                return new Ok(new UserPressedTrigger(height));
              }
            );
          }
        );
      } else if (key === " ") {
        let path = toList([
          "currentTarget",
          "nextElementSibling",
          "firstElementChild"
        ]);
        return try$(
          at(path, dynamic)(event2),
          (slot2) => {
            return try$(
              calculate_slot_height(slot2),
              (height) => {
                return new Ok(new UserPressedTrigger(height));
              }
            );
          }
        );
      } else {
        return new Error(toList([]));
      }
    }
  );
}
function view_trigger() {
  let outline = "focus:outline outline-1 outline-w-accent outline-offset-4";
  return slot(
    toList([
      class$("block cursor-pointer rounded"),
      class$(outline),
      name("trigger"),
      attribute("tabindex", "0"),
      on2("click", handle_click),
      on2("keydown", handle_keydown)
    ])
  );
}
function handle_slot_change(event2) {
  return try$(
    field("target", dynamic)(event2),
    (slot2) => {
      return try$(
        calculate_slot_height(slot2),
        (height) => {
          return new Ok(new ParentChangedContent(height));
        }
      );
    }
  );
}
function view_content(height) {
  return div(
    toList([
      class$("transition-height overflow-y-hidden"),
      style(
        toList([["transition-duration", "inherit"], ["height", height]])
      )
    ]),
    toList([slot(toList([on2("slotchange", handle_slot_change)]))])
  );
}
function view(model) {
  let height = (() => {
    let $ = model.expanded;
    if ($) {
      return to_string2(model.height) + "px";
    } else {
      return "0px";
    }
  })();
  return fragment(toList([view_trigger(), view_content(height)]));
}
var name2 = "lustre-ui-collapse";
function register() {
  let app = component(init2, update, view, on_attribute_change());
  return make_lustre_client_component(app, name2);
}
function collapse(attributes, trigger, content2) {
  return element2(
    name2,
    attributes,
    toList([
      div(toList([attribute("slot", "trigger")]), toList([trigger])),
      content2
    ])
  );
}

// build/dev/javascript/lustre_ui/lustre_ui.mjs
function main2() {
  let $ = register();
  if (!$.isOk()) {
    throw makeError(
      "let_assert",
      "lustre_ui",
      13,
      "main",
      "Pattern match failed, no pattern matched the value.",
      { value: $ }
    );
  }
  let theme = default$();
  let app = simple(
    (_) => {
      return false;
    },
    (_, expanded2) => {
      return expanded2;
    },
    (expanded2) => {
      return fragment(
        toList([
          to_style(theme),
          div(
            toList([
              class$(
                "flex items-center gap-w-sm max-w-5xl mx-auto p-w-lg"
              )
            ]),
            toList([solid(toList([]), toList([text2("hello")]))])
          ),
          divider(toList([]), toList([])),
          div(
            toList([class$("p-w-lg flex items-center")]),
            toList([
              div(
                toList([class$("grow")]),
                toList([
                  divider(
                    toList([margin(spacing.md)]),
                    toList([text2("hayleigh")])
                  ),
                  divider(
                    toList([margin(spacing.md)]),
                    toList([text2("and georges")])
                  ),
                  divider(
                    toList([margin(spacing.md)]),
                    toList([text2("sitting on a tree")])
                  ),
                  divider(
                    toList([margin(spacing.md)]),
                    toList([text2("fighting over api's")])
                  ),
                  divider(
                    toList([margin(spacing.md), thin()]),
                    toList([
                      span(
                        toList([class$("text-w-text-subtle italic")]),
                        toList([
                          text2("this actually rhymes in portuguese")
                        ])
                      )
                    ])
                  )
                ])
              ),
              divider(
                toList([vertical(), margin(spacing.md)]),
                toList([text2("or")])
              ),
              div(
                toList([class$("grow")]),
                toList([
                  divider(
                    toList([margin(spacing.md)]),
                    toList([text2("how to stop worrying")])
                  ),
                  divider(
                    toList([margin(spacing.md)]),
                    toList([text2("and love")])
                  ),
                  divider(
                    toList([
                      margin(spacing.md),
                      colour("#FF10F0")
                    ]),
                    toList([
                      span(
                        toList([class$("text-w-text-subtle italic")]),
                        toList([text2("niamh and janine")])
                      )
                    ])
                  ),
                  divider(
                    toList([margin(spacing.md)]),
                    toList([text2("as they are wise and beautiful")])
                  )
                ])
              )
            ])
          ),
          divider(toList([]), toList([])),
          div(
            toList([
              class$(
                "flex items-center gap-w-sm max-w-5xl mx-auto p-w-lg"
              )
            ]),
            toList([
              with_header(
                toList([class$("flex-1 rounded")]),
                toList([
                  title(toList([]), toList([text2("Card title")])),
                  description(
                    toList([class$("text-sm")]),
                    toList([text2("Card description")])
                  )
                ]),
                toList([
                  img(
                    toList([
                      class$("aspect-square shadow rounded"),
                      src("https://picsum.photos/400/400")
                    ])
                  )
                ])
              ),
              custom2(
                toList([class$("flex-1 rounded")]),
                toList([
                  collapse(
                    toList([
                      expanded(expanded2),
                      on_change((expanded3) => {
                        return expanded3;
                      }),
                      duration(400)
                    ]),
                    header2(
                      toList([]),
                      toList([
                        title(
                          toList([]),
                          toList([text2("Card title")])
                        ),
                        description(
                          toList([class$("text-sm")]),
                          toList([text2("Card description")])
                        )
                      ])
                    ),
                    fragment(
                      toList([
                        content(
                          toList([]),
                          toList([
                            img(
                              toList([
                                class$(
                                  "aspect-square shadow rounded"
                                ),
                                src("https://picsum.photos/400/400")
                              ])
                            )
                          ])
                        ),
                        footer2(
                          toList([]),
                          toList([
                            solid2(
                              toList([
                                small(),
                                round3(),
                                primary(),
                                class$("w-full")
                              ]),
                              toList([text2("Post")])
                            )
                          ])
                        )
                      ])
                    )
                  )
                ])
              ),
              with_footer(
                toList([class$("flex-1 rounded")]),
                toList([
                  img(
                    toList([
                      class$("aspect-square shadow rounded"),
                      src("https://picsum.photos/400/400")
                    ])
                  )
                ]),
                toList([
                  solid2(
                    toList([
                      small(),
                      round3(),
                      primary(),
                      class$("w-full")
                    ]),
                    toList([text2("Post")])
                  )
                ])
              )
            ])
          )
        ])
      );
    }
  );
  let $1 = start2(app, "#app", void 0);
  if (!$1.isOk()) {
    throw makeError(
      "let_assert",
      "lustre_ui",
      162,
      "main",
      "Pattern match failed, no pattern matched the value.",
      { value: $1 }
    );
  }
  return $1;
}

// build/.lustre/entry.mjs
main2();
