///
///
pub type Prop(a) {
  Prop(value: a, controlled: Bool, touched: Bool)
}

// CONSTRUCTORS ----------------------------------------------------------------

///
///
pub fn new(value: a) -> Prop(a) {
  Prop(value: value, controlled: False, touched: False)
}

// MANIPULATIONS ---------------------------------------------------------------

///
///
pub fn default(prop: Prop(a), value: a) -> Prop(a) {
  case prop.controlled || prop.touched {
    True -> prop
    False -> Prop(..prop, value:)
  }
}

///
///
pub fn control(prop: Prop(a), value: a) -> Prop(a) {
  Prop(..prop, value:, controlled: True)
}

///
///
pub fn touch(prop: Prop(a), value: a) -> Prop(a) {
  case prop.controlled {
    True -> prop
    False -> Prop(..prop, value:, touched: True)
  }
}
