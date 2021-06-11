// "noscan" version of `map` initialization routines if the compiler can proof that
// either the keys or the values of both do not contain any pointers they can
// be placed in a memory area that is no scanned by the garbage collector

module builtin

[inline]
fn new_dense_array_noscan(key_bytes int, keys_noscan bool, value_bytes int, values_noscan bool) DenseArray {
	cap := 8
	return DenseArray{
		key_bytes: key_bytes
		value_bytes: value_bytes
		cap: cap
		len: 0
		deletes: 0
		all_deleted: 0
		keys: if keys_noscan { unsafe { malloc_noscan(cap * key_bytes) } } else { unsafe { malloc(cap * key_bytes) } }
		values: if values_noscan { unsafe { malloc_noscan(cap * value_bytes) } } else { unsafe { malloc(cap * value_bytes) } }
	}
}

fn new_map_noscan_keys(key_bytes int, value_bytes int, hash_fn MapHashFn, key_eq_fn MapEqFn, clone_fn MapCloneFn, free_fn MapFreeFn) map {
	metasize := int(sizeof(u32) * (init_capicity + extra_metas_inc))
	// for now assume anything bigger than a pointer is a string
	has_string_keys := key_bytes > sizeof(voidptr)
	return map{
		key_bytes:       key_bytes
		value_bytes:     value_bytes
		even_index:      init_even_index
		cached_hashbits: max_cached_hashbits
		shift:           init_log_capicity
		key_values:      new_dense_array_noscan(key_bytes, true, value_bytes, false)
		metas:           unsafe { &u32(vcalloc_noscan(metasize)) }
		extra_metas:     extra_metas_inc
		len:             0
		has_string_keys: has_string_keys
		hash_fn:         hash_fn
		key_eq_fn:       key_eq_fn
		clone_fn:        clone_fn
		free_fn:         free_fn
	}
}

fn new_map_noscan_values(key_bytes int, value_bytes int, hash_fn MapHashFn, key_eq_fn MapEqFn, clone_fn MapCloneFn, free_fn MapFreeFn) map {
	metasize := int(sizeof(u32) * (init_capicity + extra_metas_inc))
	// for now assume anything bigger than a pointer is a string
	has_string_keys := key_bytes > sizeof(voidptr)
	return map{
		key_bytes:       key_bytes
		value_bytes:     value_bytes
		even_index:      init_even_index
		cached_hashbits: max_cached_hashbits
		shift:           init_log_capicity
		key_values:      new_dense_array_noscan(key_bytes, false, value_bytes, true)
		metas:           unsafe { &u32(vcalloc_noscan(metasize)) }
		extra_metas:     extra_metas_inc
		len:             0
		has_string_keys: has_string_keys
		hash_fn:         hash_fn
		key_eq_fn:       key_eq_fn
		clone_fn:        clone_fn
		free_fn:         free_fn
	}
}

fn new_map_noscan_keys_values(key_bytes int, value_bytes int, hash_fn MapHashFn, key_eq_fn MapEqFn, clone_fn MapCloneFn, free_fn MapFreeFn) map {
	metasize := int(sizeof(u32) * (init_capicity + extra_metas_inc))
	// for now assume anything bigger than a pointer is a string
	has_string_keys := key_bytes > sizeof(voidptr)
	return map{
		key_bytes:       key_bytes
		value_bytes:     value_bytes
		even_index:      init_even_index
		cached_hashbits: max_cached_hashbits
		shift:           init_log_capicity
		key_values:      new_dense_array_noscan(key_bytes, true, value_bytes, true)
		metas:           unsafe { &u32(vcalloc_noscan(metasize)) }
		extra_metas:     extra_metas_inc
		len:             0
		has_string_keys: has_string_keys
		hash_fn:         hash_fn
		key_eq_fn:       key_eq_fn
		clone_fn:        clone_fn
		free_fn:         free_fn
	}
}

fn new_map_init_noscan_keys(hash_fn MapHashFn, key_eq_fn MapEqFn, clone_fn MapCloneFn, free_fn MapFreeFn, n int, key_bytes int, value_bytes int, keys voidptr, values voidptr) map {
	mut out := new_map_noscan_keys(key_bytes, value_bytes, hash_fn, key_eq_fn, clone_fn, free_fn)
	// TODO pre-allocate n slots
	mut pkey := &byte(keys)
	mut pval := &byte(values)
	for _ in 0 .. n {
		unsafe {
			out.set(pkey, pval)
			pkey = pkey + key_bytes
			pval = pval + value_bytes
		}
	}
	return out
}

fn new_map_init_noscan_values(hash_fn MapHashFn, key_eq_fn MapEqFn, clone_fn MapCloneFn, free_fn MapFreeFn, n int, key_bytes int, value_bytes int, keys voidptr, values voidptr) map {
	mut out := new_map_noscan_values(key_bytes, value_bytes, hash_fn, key_eq_fn, clone_fn, free_fn)
	// TODO pre-allocate n slots
	mut pkey := &byte(keys)
	mut pval := &byte(values)
	for _ in 0 .. n {
		unsafe {
			out.set(pkey, pval)
			pkey = pkey + key_bytes
			pval = pval + value_bytes
		}
	}
	return out
}

fn new_map_init_noscan_keys_values(hash_fn MapHashFn, key_eq_fn MapEqFn, clone_fn MapCloneFn, free_fn MapFreeFn, n int, key_bytes int, value_bytes int, keys voidptr, values voidptr) map {
	mut out := new_map_noscan_keys_values(key_bytes, value_bytes, hash_fn, key_eq_fn, clone_fn, free_fn)
	// TODO pre-allocate n slots
	mut pkey := &byte(keys)
	mut pval := &byte(values)
	for _ in 0 .. n {
		unsafe {
			out.set(pkey, pval)
			pkey = pkey + key_bytes
			pval = pval + value_bytes
		}
	}
	return out
}
