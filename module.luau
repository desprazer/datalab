--!native
--!strict
--!optimize 2

export type node<t> = {
	value: t,
	next: node<t>?,
	prev: node<t>?
}

export type linkedlist<t> = {
	head: node<t>?,
	tail: node<t>?,
	size: number
}

local function createnode<t>(value: t, next: node<t>?, prev: node<t>?): node<t>
	return {
		value = value,
		next = next,
		prev = prev
	}
end

local function createlinkedlist<t>(): linkedlist<t>
	return {
		head = nil,
		tail = nil,
		size = 0
	}
end

local function push<t>(list: linkedlist<t>, value: t): linkedlist<t>
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

local function pop<t>(list: linkedlist<t>): (linkedlist<t>, t?)
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

local function shift<t>(list: linkedlist<t>): (linkedlist<t>, t?)
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

local function unshift<t>(list: linkedlist<t>, value: t): linkedlist<t>
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

local function get<t>(list: linkedlist<t>, index: number): t?
	if index < 1 or index > list.size then return nil end
	local current: node<t>?
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

local function remove<t>(list: linkedlist<t>, index: number): (linkedlist<t>, t?)
	if index < 1 or index > list.size then return list, nil end
	local value: t?
	if index == 1 then
		list, value = shift(list)
	elseif index == list.size then
		list, value = pop(list)
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

local function insert<t>(list: linkedlist<t>, index: number, value: t): (linkedlist<t>, boolean)
	if index < 1 or index > list.size + 1 then return list, false end
	if index == 1 then
		return unshift(list, value), true
	elseif index == list.size + 1 then
		return push(list, value), true
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

local function foreach<t>(list: linkedlist<t>, callback: (value: t, index: number) -> ()): ()
	local current = list.head
	local index = 1
	while current do
		callback(current.value, index)
		current = current.next
		index += 1
	end
end

local function toarray<t>(list: linkedlist<t>): {t}
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

local function clear<t>(list: linkedlist<t>): linkedlist<t>
	list.head = nil
	list.tail = nil
	list.size = 0
	return list
end

export type priorityqueue<t> = {
	heap: {t},
	size: number,
	comparator: (a: t, b: t) -> boolean
}

local function createpriorityqueue<t>(comparator: (a: t, b: t) -> boolean): priorityqueue<t>
	return {
		heap = {},
		size = 0,
		comparator = comparator
	}
end

local function swap<t>(heap: {t}, i: number, j: number): ()
	heap[i], heap[j] = heap[j], heap[i]
end

local function bubbleup<t>(queue: priorityqueue<t>, index: number): priorityqueue<t>
	local parent = math.floor(index / 2)
	if parent >= 1 and queue.comparator(queue.heap[index], queue.heap[parent]) then
		swap(queue.heap, index, parent)
		queue = bubbleup(queue, parent)
	end
	return queue
end

local function bubbledown<t>(queue: priorityqueue<t>, index: number): priorityqueue<t>
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

local function enqueue<t>(queue: priorityqueue<t>, value: t): priorityqueue<t>
	queue.size += 1
	queue.heap[queue.size] = value
	queue = bubbleup(queue, queue.size)
	return queue
end

local function dequeue<t>(queue: priorityqueue<t>): (priorityqueue<t>, t?)
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

local function peek<t>(queue: priorityqueue<t>): t?
	return queue.size > 0 and queue.heap[1] or nil
end

export type hashtable<k, v> = {
	buckets: {{key: k, value: v}},
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

local function createhashtable<k, v>(capacity: number?, loadfactor: number?): hashtable<k, v>
	local actualcapacity = capacity or 16
	local actualloadfactor = loadfactor or 0.75
	
	return {
		buckets = table.create(actualcapacity),
		size = 0,
		capacity = actualcapacity,
		loadfactor = actualloadfactor
	}
end

local function resize<k, v>(table: hashtable<k, v>): hashtable<k, v>
	local newcapacity = table.capacity * 2
	local newtable = createhashtable<k, v>(newcapacity, table.loadfactor)
	
	for i = 1, table.capacity do
		local bucket = table.buckets[i]
		if bucket then
			for _, entry in ipairs(bucket) do
				newtable = put(newtable, entry.key, entry.value)
			end
		end
	end
	
	return newtable
end

local function put<k, v>(table: hashtable<k, v>, key: k, value: v): hashtable<k, v>
	if table.size >= table.capacity * table.loadfactor then
		table = resize(table)
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

local function get<k, v>(table: hashtable<k, v>, key: k): v?
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

local function remove_key<k, v>(table: hashtable<k, v>, key: k): (hashtable<k, v>, v?)
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
	createlinkedlist = createlinkedlist,
	push = push,
	pop = pop,
	shift = shift,
	unshift = unshift,
	get = get,
	remove = remove,
	insert = insert,
	foreach = foreach,
	toarray = toarray,
	clear = clear,
	createpriorityqueue = createpriorityqueue,
	enqueue = enqueue,
	dequeue = dequeue,
	peek = peek,
	createhashtable = createhashtable,
	put = put,
	get = get,
	remove_key = remove_key
}
