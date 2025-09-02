// TYPES -----------------------------------------------------------------------

///
///
pub type Value(a) {
  Controlled(value: a)
  Uncontrolled(value: a, default: a, touched: Bool)
}
