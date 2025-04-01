--!native
--!strict
--!optimize 2
export type Node<T> = {
	value: T,
	next: Node<T>?,
	prev: Node<T>?
}

export type LinkedList<T> = {
	head: Node<T>?,
	tail: Node<T>?,
	size: number
}

local function createnode<T>(value: T, next: Node<T>?, prev: Node<T>?): Node<T>
	return {
		value = value,
		next = next,
		prev = prev
	}
end

export type PriorityQueue<T> = {
	heap: {T},
	size: number,
	comparator: (a: T, b: T) -> boolean
}

export type HashTable<K, V> = {
	buckets: {{key: K, value: V}},
	size: number,
	capacity: number,
	loadfactor: number
}

local function hash(key: any): number
	if type(key) == "string" then
		local h = 0
		for i = 1, #key do
			h = (h * 31 + string.byte(key, i)) % 2147483647 -- ❤️
		end
		return h
	elseif type(key) == "number" then
		return math.floor(key) % 2147483647
	elseif type(key) == "boolean" then
		return key and 1 or 0
	end
	return 0
end

local function linkedlist_new<T>(): LinkedList<T>
	return {
		head = nil,
		tail = nil,
		size = 0
	}
end

local function linkedlist_push<T>(list: LinkedList<T>, value: T): LinkedList<T>
	local newnode = createnode(value, nil, list.tail)
	if list.size == 0 then
		list.head = newnode
		list.tail = newnode
	else
		if list.tail then
			list.tail.next = newnode
		end
		list.tail = newnode
	end
	list.size += 1
	return list
end

local function linkedlist_pop<T>(list: LinkedList<T>): (LinkedList<T>, T?)
	if list.size == 0 then return list, nil end
	local value = list.tail and list.tail.value
	if list.size == 1 then
		list.head = nil
		list.tail = nil
	else
		if list.tail and list.tail.prev then
			list.tail = list.tail.prev
			list.tail.next = nil
		end
	end
	list.size -= 1
	return list, value
end

local function linkedlist_shift<T>(list: LinkedList<T>): (LinkedList<T>, T?)
	if list.size == 0 then return list, nil end
	local value = list.head and list.head.value
	if list.size == 1 then
		list.head = nil
		list.tail = nil
	else
		if list.head and list.head.next then
			list.head = list.head.next
			list.head.prev = nil
		end
	end
	list.size -= 1
	return list, value
end

local function linkedlist_unshift<T>(list: LinkedList<T>, value: T): LinkedList<T>
	local newnode = createnode(value, list.head, nil)
	if list.size == 0 then
		list.head = newnode
		list.tail = newnode
	else
		if list.head then
			list.head.prev = newnode
		end
		list.head = newnode
	end
	list.size += 1
	return list
end

local function linkedlist_get<T>(list: LinkedList<T>, index: number): T?
	if index < 1 or index > list.size then return nil end
	local current: Node<T>?
	if index <= list.size / 2 then
		current = list.head
		for i = 1, index - 1 do
			if current then
				current = current.next
			end
		end
	else
		current = list.tail
		for i = list.size, index + 1, -1 do
			if current then
				current = current.prev
			end
		end
	end
	return current and current.value
end

local function linkedlist_remove<T>(list: LinkedList<T>, index: number): (LinkedList<T>, T?)
	if index < 1 or index > list.size then return list, nil end
	local value: T?
	if index == 1 then
		list, value = linkedlist_shift(list)
	elseif index == list.size then
		list, value = linkedlist_pop(list)
	else
		local current = list.head
		for i = 1, index - 1 do
			if current then
				current = current.next
			end
		end
		if current then
			value = current.value
			if current.prev and current.next then
				current.prev.next = current.next
				current.next.prev = current.prev
			end
			list.size -= 1
		end
	end
	return list, value
end

local function linkedlist_insert<T>(list: LinkedList<T>, index: number, value: T): (LinkedList<T>, boolean)
	if index < 1 or index > list.size + 1 then return list, false end
	if index == 1 then
		return linkedlist_unshift(list, value), true
	elseif index == list.size + 1 then
		return linkedlist_push(list, value), true
	else
		local current = list.head
		for i = 1, index - 1 do
			if current then
				current = current.next
			end
		end
		if current and current.prev then
			local newnode = createnode(value, current, current.prev)
			current.prev.next = newnode
			current.prev = newnode
			list.size += 1
		end
		return list, true
	end
end

local function linkedlist_foreach<T>(list: LinkedList<T>, callback: (value: T, index: number) -> ()): ()
	local current = list.head
	local index = 1
	while current do
		callback(current.value, index)
		current = current.next
		index += 1
	end
end

local function linkedlist_toarray<T>(list: LinkedList<T>): {T}
	local result = table.create(list.size)
	local current = list.head
	local index = 1
	while current do
		result[index] = current.value
		current = current.next
		index += 1
	end
	return result
end

local function linkedlist_clear<T>(list: LinkedList<T>): LinkedList<T>
	list.head = nil
	list.tail = nil
	list.size = 0
	return list
end

local function priorityqueue_new<T>(comparator: (a: T, b: T) -> boolean): PriorityQueue<T>
	return {
		heap = {},
		size = 0,
		comparator = comparator
	}
end

local function swap<T>(heap: {T}, i: number, j: number): ()
	heap[i], heap[j] = heap[j], heap[i]
end

local function bubbleup<T>(queue: PriorityQueue<T>, index: number): PriorityQueue<T>
	local parent = math.floor(index / 2)
	if parent >= 1 and queue.comparator(queue.heap[index], queue.heap[parent]) then
		swap(queue.heap, index, parent)
		queue = bubbleup(queue, parent)
	end
	return queue
end

local function bubbledown<T>(queue: PriorityQueue<T>, index: number): PriorityQueue<T>
	local left = index * 2
	local right = left + 1
	local largest = index
	
	if left <= queue.size and queue.comparator(queue.heap[left], queue.heap[largest]) then
		largest = left
	end
	
	if right <= queue.size and queue.comparator(queue.heap[right], queue.heap[largest]) then
		largest = right
	end
	
	if largest ~= index then
		swap(queue.heap, index, largest)
		queue = bubbledown(queue, largest)
	end
	
	return queue
end

local function priorityqueue_enqueue<T>(queue: PriorityQueue<T>, value: T): PriorityQueue<T>
	queue.size += 1
	queue.heap[queue.size] = value
	queue = bubbleup(queue, queue.size)
	return queue
end

local function priorityqueue_dequeue<T>(queue: PriorityQueue<T>): (PriorityQueue<T>, T?)
	if queue.size == 0 then
		return queue, nil
	end
	
	local result = queue.heap[1]
	queue.heap[1] = queue.heap[queue.size]
	queue.heap[queue.size] = nil
	queue.size -= 1
	
	if queue.size > 0 then
		queue = bubbledown(queue, 1)
	end
	
	return queue, result
end

local function priorityqueue_peek<T>(queue: PriorityQueue<T>): T?
	return queue.size > 0 and queue.heap[1] or nil
end

local function hashtable_new<K, V>(capacity: number?, loadfactor: number?): HashTable<K, V>
	local actualcapacity = capacity or 16
	local actualloadfactor = loadfactor or 0.75
	
	return {
		buckets = table.create(actualcapacity),
		size = 0,
		capacity = actualcapacity,
		loadfactor = actualloadfactor
	}
end

local function hashtable_resize<K, V>(table: HashTable<K, V>): HashTable<K, V>
	local newcapacity = table.capacity * 2
	local newtable = hashtable_new<K, V>(newcapacity, table.loadfactor)
	
	for i = 1, table.capacity do
		local bucket = table.buckets[i]
		if bucket then
			for _, entry in ipairs(bucket) do
				newtable = hashtable_put(newtable, entry.key, entry.value)
			end
		end
	end
	
	return newtable
end

local function hashtable_put<K, V>(table: HashTable<K, V>, key: K, value: V): HashTable<K, V>
	if table.size >= table.capacity * table.loadfactor then
		table = hashtable_resize(table)
	end
	
	local hashvalue = hash(key)
	local index = (hashvalue % table.capacity) + 1
	
	if not table.buckets[index] then
		table.buckets[index] = {}
	end
	
	for i, entry in ipairs(table.buckets[index]) do
		if entry.key == key then
			entry.value = value
			return table
		end
	end
	
	table.size += 1
	table.buckets[index][#table.buckets[index] + 1] = {key = key, value = value}
	
	return table
end

local function hashtable_get<K, V>(table: HashTable<K, V>, key: K): V?
	local hashvalue = hash(key)
	local index = (hashvalue % table.capacity) + 1
	
	if not table.buckets[index] then
		return nil
	end
	
	for _, entry in ipairs(table.buckets[index]) do
		if entry.key == key then
			return entry.value
		end
	end
	
	return nil
end

local function hashtable_remove<K, V>(table: HashTable<K, V>, key: K): (HashTable<K, V>, V?)
	local hashvalue = hash(key)
	local index = (hashvalue % table.capacity) + 1
	
	if not table.buckets[index] then
		return table, nil
	end
	
	for i, entry in ipairs(table.buckets[index]) do
		if entry.key == key then
			local value = entry.value
			table.buckets[index][i] = table.buckets[index][#table.buckets[index]]
			table.buckets[index][#table.buckets[index]] = nil
			table.size -= 1
			return table, value
		end
	end
	
	return table, nil
end

return {
	linkedlist = {
		new = linkedlist_new,
		push = linkedlist_push,
		pop = linkedlist_pop,
		shift = linkedlist_shift,
		unshift = linkedlist_unshift,
		get = linkedlist_get,
		remove = linkedlist_remove,
		insert = linkedlist_insert,
		foreach = linkedlist_foreach,
		toarray = linkedlist_toarray,
		clear = linkedlist_clear
	},
	
	priorityqueue = {
		new = priorityqueue_new,
		enqueue = priorityqueue_enqueue,
		dequeue = priorityqueue_dequeue,
		peek = priorityqueue_peek
	},
	
	hashtable = {
		new = hashtable_new,
		put = hashtable_put,
		get = hashtable_get,
		remove = hashtable_remove
	}
}
