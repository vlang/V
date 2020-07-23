/*
    Compability header for stdatomic.h that works for all compilers supported
    by V. For TCC libatomic from the operating system is used

*/
#ifndef __ATOMIC_H
#define __ATOMIC_H

#ifndef __cplusplus
// If C just use stdatomic.h
#ifndef __TINYC__
#include <stdatomic.h>
#endif
#else
// CPP wrapper for atomic operations that are compatible with C
#include "atomic_cpp.h"
#endif

#ifdef __TINYC__

typedef volatile long long atomic_llong;
typedef volatile unsigned long long atomic_ullong;
typedef volatile uintptr_t atomic_uintptr_t;

// use functions for 64, 32 and 8 bit from libatomic directly
// since tcc is not capible to use "generic" C functions

extern unsigned long long __atomic_load_8(unsigned long long* x, int mo);
extern void __atomic_store_8(unsigned long long* x, unsigned long long y, int mo);
extern char __atomic_compare_exchange_8(unsigned long long* x, unsigned long long* expected, unsigned long long y, int mo, int mo2);
extern char __atomic_compare_exchange_8(unsigned long long* x, unsigned long long* expected, unsigned long long y, int mo, int mo2);
extern unsigned long long __atomic_exchange_8(unsigned long long* x, unsigned long long y, int mo);
extern unsigned long long __atomic_fetch_add_8(unsigned long long* x, unsigned long long y, int mo);
extern unsigned long long __atomic_fetch_sub_8(unsigned long long* x, unsigned long long y, int mo);

extern unsigned int __atomic_load_4(unsigned int* x, int mo);
extern void __atomic_store_4(unsigned int* x, unsigned int y, int mo);
extern char __atomic_compare_exchange_4(unsigned int* x, unsigned int* expected, unsigned int y, int mo, int mo2);
extern char __atomic_compare_exchange_4(unsigned int* x, unsigned int* expected, unsigned int y, int mo, int mo2);
extern unsigned int __atomic_exchange_4(unsigned int* x, unsigned int y, int mo);
extern unsigned int __atomic_fetch_add_4(unsigned int* x, unsigned int y, int mo);
extern unsigned int __atomic_fetch_sub_4(unsigned int* x, unsigned int y, int mo);

extern unsigned char __atomic_load_1(unsigned char* x, int mo);
extern void __atomic_store_1(unsigned char* x, unsigned char y, int mo);
extern unsigned char __atomic_compare_exchange_1(unsigned char* x, unsigned char* expected, unsigned char y, int mo, int mo2);
extern unsigned char __atomic_compare_exchange_1(unsigned char* x, unsigned char* expected, unsigned char y, int mo, int mo2);
extern unsigned char __atomic_exchange_1(unsigned char* x, unsigned char y, int mo);
extern unsigned char __atomic_fetch_add_1(unsigned char* x, unsigned char y, int mo);
extern unsigned char __atomic_fetch_sub_1(unsigned char* x, unsigned char y, int mo);

// The default functions should work with pointers so we have to decide based on pointer size
#if UINTPTR_MAX == 0xFFFFFFFF

#define atomic_load_explicit __atomic_load_4
#define atomic_store_explicit __atomic_store_4
#define atomic_compare_exchange_weak_explicit __atomic_compare_exchange_4
#define atomic_compare_exchange_strong_explicit __atomic_compare_exchange_4
#define atomic_exchange_explicit __atomic_exchange_4
#define atomic_fetch_add_explicit __atomic_fetch_add_4
#define atomic_fetch_sub_explicit __atomic_sub_fetch_4

#else

#define atomic_load_explicit __atomic_load_8
#define atomic_store_explicit __atomic_store_8
#define atomic_compare_exchange_weak_explicit __atomic_compare_exchange_8
#define atomic_compare_exchange_strong_explicit __atomic_compare_exchange_8
#define atomic_exchange_explicit __atomic_exchange_8
#define atomic_fetch_add_explicit __atomic_fetch_add_8
#define atomic_fetch_sub_explicit __atomic_sub_fetch_8

#endif

// memory order policies - we use "sequentially consistent" by default

#define memory_order_relaxed 0
#define memory_order_consume 1
#define memory_order_acquire 2
#define memory_order_release 3
#define memory_order_acq_rel 4
#define memory_order_seq_cst 5

static inline uintptr_t atomic_load(uintptr_t* x) {
	return atomic_load_explicit(x, memory_order_seq_cst);
}
static inline void atomic_store(uintptr_t* x, uintptr_t y) {
	atomic_store_explicit(x, y, memory_order_seq_cst);
}
static inline int atomic_compare_exchange_weak(uintptr_t* x, uintptr_t* expected, uintptr_t y) {
	return atomic_compare_exchange_weak_explicit(x, expected, y, memory_order_seq_cst, memory_order_seq_cst);
}
static inline int atomic_compare_exchange_strong(uintptr_t* x, uintptr_t* expected, uintptr_t y) {
	return atomic_compare_exchange_strong_explicit(x, expected, y, memory_order_seq_cst, memory_order_seq_cst);
}
static inline uintptr_t atomic_exchange(uintptr_t* x, uintptr_t y) {
	return atomic_exchange_explicit(x, y, memory_order_seq_cst);
}
static inline uintptr_t atomic_fetch_add(uintptr_t* x, uintptr_t y) {
	return atomic_fetch_add_explicit(x, y, memory_order_seq_cst);
}
static inline uintptr_t atomic_fetch_sub(uintptr_t* x, uintptr_t y) {
	return atomic_fetch_sub_explicit(x, y, memory_order_seq_cst);
}

// specialized versions for 64 bit

static inline unsigned long long atomic_load_u64(unsigned long long* x) {
	return __atomic_load_8(x, memory_order_seq_cst);
}
static inline void atomic_store_u64(unsigned long long* x, unsigned long long y) {
	__atomic_store_8(x, y, memory_order_seq_cst);
}
static inline int atomic_compare_exchange_weak_u64(unsigned long long* x, unsigned long long* expected, unsigned long long y) {
	return __atomic_compare_exchange_weak_8(x, expected, y, memory_order_seq_cst, memory_order_seq_cst);
}
static inline int atomic_compare_exchange_strong_u64(unsigned long long* x, unsigned long long* expected, unsigned long long y) {
	return __atomic_compare_exchange_strong_8(x, expected, y, memory_order_seq_cst, memory_order_seq_cst);
}
static inline unsigned long long atomic_exchange_u64(unsigned long long* x, unsigned long long y) {
	return __atomic_exchange_8(x, y, memory_order_seq_cst);
}
static inline unsigned long long atomic_fetch_add_u64(unsigned long long* x, unsigned long long y) {
	return __atomic_fetch_add_8(x, y, memory_order_seq_cst);
}
static inline unsigned long long atomic_fetch_sub_u64(unsigned long long* x, unsigned long long y) {
	return __atomic_fetch_sub_8(x, y, memory_order_seq_cst);
}

static inline unsigned atomic_load_u32(unsigned* x) {
	return __atomic_load_4(x, memory_order_seq_cst);
}
static inline void atomic_store_u32(unsigned* x, unsigned y) {
	__atomic_store_4(x, y, memory_order_seq_cst);
}
static inline int atomic_compare_exchange_weak_u32(unsigned* x, unsigned* expected, unsigned y) {
	return __atomic_compare_exchange_weak_4(x, expected, y, memory_order_seq_cst, memory_order_seq_cst);
}
static inline int atomic_compare_exchange_strong_u32(unsigned* x, unsigned* expected, unsigned y) {
	return __atomic_compare_exchange_strong_4(x, expected, y, memory_order_seq_cst, memory_order_seq_cst);
}
static inline unsigned atomic_exchange_u32(unsigned* x, unsigned y) {
	return __atomic_exchange_4(x, y, memory_order_seq_cst);
}
static inline unsigned atomic_fetch_add_u32(unsigned* x, unsigned y) {
	return __atomic_fetch_add_4(x, y, memory_order_seq_cst);
}
static inline unsigned atomic_fetch_sub_u32(unsigned* x, unsigned y) {
	return __atomic_fetch_sub_4(x, y, memory_order_seq_cst);
}

static inline unsigned char atomic_load_byte(unsigned char* x) {
	return __atomic_load_1(x, memory_order_seq_cst);
}
static inline void atomic_store_byte(unsigned char* x, unsigned char y) {
	__atomic_store_1(x, y, memory_order_seq_cst);
}
static inline int atomic_compare_exchange_weak_byte(unsigned char* x, unsigned char* expected, unsigned char y) {
	return __atomic_compare_exchange_weak_1(x, expected, y, memory_order_seq_cst, memory_order_seq_cst);
}
static inline int atomic_compare_exchange_strong_byte(unsigned char* x, unsigned char* expected, unsigned char y) {
	return __atomic_compare_exchange_strong_1(x, expected, y, memory_order_seq_cst, memory_order_seq_cst);
}
static inline unsigned char atomic_exchange_byte(unsigned char* x, unsigned char y) {
	return __atomic_exchange_1(x, y, memory_order_seq_cst);
}
static inline unsigned char atomic_fetch_add_byte(unsigned char* x, unsigned char y) {
	return __atomic_fetch_add_1(x, y, memory_order_seq_cst);
}
static inline unsigned char atomic_fetch_sub_byte(unsigned char* x, unsigned char y) {
	return __atomic_fetch_sub_1(x, y, memory_order_seq_cst);
}

#else

// Since V might be confused with "generic" C functions either we provide special versions
// for gcc/clang, too
static inline unsigned long long atomic_load_u64(unsigned long long* x) {
	return atomic_load_explicit(x, memory_order_seq_cst);
}
static inline void atomic_store_u64(unsigned long long* x, unsigned long long y) {
	atomic_store_explicit(x, y, memory_order_seq_cst);
}
static inline int atomic_compare_exchange_weak_u64(unsigned long long* x, unsigned long long* expected, unsigned long long y) {
	return atomic_compare_exchange_weak_explicit(x, expected, y, memory_order_seq_cst, memory_order_seq_cst);
}
static inline int atomic_compare_exchange_strong_u64(unsigned long long* x, unsigned long long* expected, unsigned long long y) {
	return atomic_compare_exchange_strong_explicit(x, expected, y, memory_order_seq_cst, memory_order_seq_cst);
}
static inline unsigned long long atomic_exchange_u64(unsigned long long* x, unsigned long long y) {
	return atomic_exchange_explicit(x, y, memory_order_seq_cst);
}
static inline unsigned long long atomic_fetch_add_u64(unsigned long long* x, unsigned long long y) {
	return atomic_fetch_add_explicit(x, y, memory_order_seq_cst);
}
static inline unsigned long long atomic_fetch_sub_u64(unsigned long long* x, unsigned long long y) {
	return atomic_fetch_sub_explicit(x, y, memory_order_seq_cst);
}

static inline unsigned atomic_load_u32(unsigned* x) {
	return atomic_load_explicit(x, memory_order_seq_cst);
}
static inline void atomic_store_u32(unsigned* x, unsigned y) {
	atomic_store_explicit(x, y, memory_order_seq_cst);
}
static inline int atomic_compare_exchange_weak_u32(unsigned* x, unsigned* expected, unsigned y) {
	return atomic_compare_exchange_weak_explicit(x, expected, y, memory_order_seq_cst, memory_order_seq_cst);
}
static inline int atomic_compare_exchange_strong_u32(unsigned* x, unsigned* expected, unsigned y) {
	return atomic_compare_exchange_strong_explicit(x, expected, y, memory_order_seq_cst, memory_order_seq_cst);
}
static inline unsigned atomic_exchange_u32(unsigned* x, unsigned y) {
	return atomic_exchange_explicit(x, y, memory_order_seq_cst);
}
static inline unsigned atomic_fetch_add_u32(unsigned* x, unsigned y) {
	return atomic_fetch_add_explicit(x, y, memory_order_seq_cst);
}
static inline unsigned atomic_fetch_sub_u32(unsigned* x, unsigned y) {
	return atomic_fetch_sub_explicit(x, y, memory_order_seq_cst);
}

static inline unsigned char atomic_load_byte(unsigned char* x) {
	return atomic_load_explicit(x, memory_order_seq_cst);
}
static inline void atomic_store_byte(unsigned char* x, unsigned char y) {
	atomic_store_explicit(x, y, memory_order_seq_cst);
}
static inline int atomic_compare_exchange_weak_byte(unsigned char* x, unsigned char* expected, unsigned char y) {
	return atomic_compare_exchange_weak_explicit(x, expected, y, memory_order_seq_cst, memory_order_seq_cst);
}
static inline int atomic_compare_exchange_strong_byte(unsigned char* x, unsigned char* expected, unsigned char y) {
	return atomic_compare_exchange_strong_explicit(x, expected, y, memory_order_seq_cst, memory_order_seq_cst);
}
static inline unsigned char atomic_exchange_byte(unsigned char* x, unsigned char y) {
	return atomic_exchange_explicit(x, y, memory_order_seq_cst);
}
static inline unsigned char atomic_fetch_add_byte(unsigned char* x, unsigned char y) {
	return atomic_fetch_add_explicit(x, y, memory_order_seq_cst);
}
static inline unsigned char atomic_fetch_sub_byte(unsigned char* x, unsigned char y) {
	return atomic_fetch_sub_explicit(x, y, memory_order_seq_cst);
}

#endif
#endif
