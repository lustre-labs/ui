pub fn first(options: List(String)) -> String {
  case options {
    [] -> ""
    [a, ..] -> a
  }
}

pub fn previous(options: List(String), selected: String) -> String {
  case options {
    [] -> selected
    [a] -> a
    [a, ..] if a == selected -> a
    [a, b, ..] if b == selected -> a
    [_, ..rest] -> previous(rest, selected)
  }
}

pub fn next(options: List(String), selected: String) -> String {
  case options {
    [] -> selected
    [a] -> a
    [a, b, ..] if a == selected -> b
    [_, ..rest] -> next(rest, selected)
  }
}

pub fn last(options: List(String)) -> String {
  case options {
    [] -> ""
    [a] -> a
    [_, ..rest] -> last(rest)
  }
}
