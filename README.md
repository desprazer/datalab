# datalab
luau data structure library

## linkedlist

### types

```lua
type node<t> = {
    value: t,
    next: node<t>?,
    prev: node<t>?
}

type linkedlist<t> = {
    head: node<t>?,
    tail: node<t>?,
    size: number
}
```

### functions

#### `createlinkedlist<t>(): linkedlist<t>`
creates new empty linked list
- returns: new linkedlist with nil head/tail and size 0

#### `push<t>(list: linkedlist<t>, value: t): linkedlist<t>`
adds value to end of list
- parameters:
  - `list`: linkedlist to modify
  - `value`: value to add
- returns: modified linkedlist

#### `pop<t>(list: linkedlist<t>): (linkedlist<t>, t?)`
removes last value from list
- parameters:
  - `list`: linkedlist to modify
- returns: 
  - modified linkedlist
  - removed value (nil if empty)

#### `shift<t>(list: linkedlist<t>): (linkedlist<t>, t?)`
removes first value from list
- parameters:
  - `list`: linkedlist to modify
- returns: 
  - modified linkedlist
  - removed value (nil if empty)

#### `unshift<t>(list: linkedlist<t>, value: t): linkedlist<t>`
adds value to start of list
- parameters:
  - `list`: linkedlist to modify
  - `value`: value to add
- returns: modified linkedlist

#### `get<t>(list: linkedlist<t>, index: number): t?`
gets value at specific index
- parameters:
  - `list`: linkedlist to read from
  - `index`: position (1-based)
- returns: value at index (nil if invalid index)

#### `remove<t>(list: linkedlist<t>, index: number): (linkedlist<t>, t?)`
removes value at specific index
- parameters:
  - `list`: linkedlist to modify
  - `index`: position (1-based)
- returns:
  - modified linkedlist
  - removed value (nil if invalid index)

#### `insert<t>(list: linkedlist<t>, index: number, value: t): (linkedlist<t>, boolean)`
inserts value at specific index
- parameters:
  - `list`: linkedlist to modify
  - `index`: position (1-based)
  - `value`: value to insert
- returns:
  - modified linkedlist
  - success boolean

#### `foreach<t>(list: linkedlist<t>, callback: (value: t, index: number) -> ()): ()`
iterates over each item in list
- parameters:
  - `list`: linkedlist to iterate
  - `callback`: function called with each value and index

#### `toarray<t>(list: linkedlist<t>): {t}`
converts list to array
- parameters:
  - `list`: linkedlist to convert
- returns: array containing all values

#### `clear<t>(list: linkedlist<t>): linkedlist<t>`
removes all items from list
- parameters:
  - `list`: linkedlist to clear
- returns: empty linkedlist

## priorityqueue

### types

```lua
type priorityqueue<t> = {
    heap: {t},
    size: number,
    comparator: (a: t, b: t) -> boolean
}
```

### functions

#### `createpriorityqueue<t>(comparator: (a: t, b: t) -> boolean): priorityqueue<t>`
creates new priority queue
- parameters:
  - `comparator`: function determining priority (returns true if a has higher priority than b)
- returns: new empty priorityqueue

#### `enqueue<t>(queue: priorityqueue<t>, value: t): priorityqueue<t>`
adds value to queue
- parameters:
  - `queue`: priorityqueue to modify
  - `value`: value to add
- returns: modified priorityqueue

#### `dequeue<t>(queue: priorityqueue<t>): (priorityqueue<t>, t?)`
removes highest priority value
- parameters:
  - `queue`: priorityqueue to modify
- returns:
  - modified priorityqueue
  - removed value (nil if empty)

#### `peek<t>(queue: priorityqueue<t>): t?`
gets highest priority value without removing
- parameters:
  - `queue`: priorityqueue to read from
- returns: highest priority value (nil if empty)

## hashtable

### types

```lua
type hashtable<k, v> = {
    buckets: {{key: k, value: v}},
    size: number,
    capacity: number,
    loadfactor: number
}
```

### functions

#### `createhashtable<k, v>(capacity: number?, loadfactor: number?): hashtable<k, v>`
creates new hashtable
- parameters:
  - `capacity`: initial bucket count (default 16)
  - `loadfactor`: threshold for resizing (default 0.75)
- returns: new empty hashtable

#### `put<k, v>(table: hashtable<k, v>, key: k, value: v): hashtable<k, v>`
adds or updates key-value pair
- parameters:
  - `table`: hashtable to modify
  - `key`: key to store value under
  - `value`: value to store
- returns: modified hashtable

#### `get<k, v>(table: hashtable<k, v>, key: k): v?`
retrieves value by key
- parameters:
  - `table`: hashtable to read from
  - `key`: key to look up
- returns: value associated with key (nil if not found)

#### `remove_key<k, v>(table: hashtable<k, v>, key: k): (hashtable<k, v>, v?)`
removes key-value pair
- parameters:
  - `table`: hashtable to modify
  - `key`: key to remove
- returns:
  - modified hashtable
  - removed value (nil if not found)
