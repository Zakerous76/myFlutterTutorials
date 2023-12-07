// Now, let's break down the key elements:
//
// Stream<List<T>> filter(bool Function(T) where): This defines a method named
// filter that extends Stream<List<T>>. The method takes a single parameter, a
// function named where, which is a predicate function. The where function is
// expected to take an item of type T and return a boolean.
//
// map((items) => items.where(where).toList()): This part uses the map method
// on the stream to transform each event in the stream. It takes a callback
// function that operates on each list of items (items). Inside the callback:
//
// items.where(where): This filters the items in the list based on the provided
// where function, which serves as the filtering condition.
// .toList(): This converts the filtered items back into a list.
// So, the map method essentially transforms each list in the stream by
// filtering its items based on the provided condition.

extension Filter<T> on Stream<List<T>> {
  Stream<List<T>> filter(bool Function(T) where) =>
      map((items) => items.where(where).toList());
}
