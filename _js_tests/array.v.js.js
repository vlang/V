// V_COMMIT_HASH 612fe1b
// V_CURRENT_COMMIT_HASH d7e0d11
// Generated by the V compiler

"use strict";

/** @namespace builtin */
const builtin = (function () {
	/**
	 * @function
	 * @param {any} s
	 * @returns {void}
	*/
	function println(s) {
		console.log(s);
	}

	/**
	 * @function
	 * @param {any} s
	 * @returns {void}
	*/
	function print(s) {
		process.stdout.write(s);
	}

	/**
	 * @function
	 * @param {any} s
	 * @returns {void}
	*/
	function eprintln(s) {
		console.error(s);
	}

	/**
	 * @function
	 * @param {any} s
	 * @returns {void}
	*/
	function eprint(s) {
		process.stderr.write(s);
	}

	/**
	 * @function
	 * @param {number} c
	 * @returns {void}
	*/
	function exit(c) {
		process.exit(c);
	}

	/**
	 * @function
	 * @param {string} s
	 * @returns {void}
	*/
	function panic(s) {
		builtin.eprintln(`V panic: ${s}`);
		builtin.exit(1);
	}

	/* module exports */
	return {
		println,
		print,
		eprintln,
		eprint,
		exit,
		panic
	};
})();

/** @namespace main */
const main = (function () {
	/**
	 * @function
	 * @param {string} s
	 * @returns {string}
	*/
	function map_cb(s) {
		return `CB: ${s}`;
	}

	/**
	 * @function
	 * @param {number} n
	 * @returns {boolean}
	*/
	function filter_cb(n) {
		return n < 4;
	}

	/**
	 * @function
	 * @param {...number} args
	 * @returns {void}
	*/
	function variadic(...args) {
		builtin.println(args);
		builtin.println(args[0]);
		builtin.println(args[1]);
	}

	/**
	 * @function
	 * @returns {void}
	*/
	function vararg_test() {
		variadic(1, 2, 3);
	}

	/* program entry point */
	(function() {
		vararg_test();
		/** @type {string[]} */
		const arr1 = ["Hello", "JS", "Backend"];
		/** @type {number[]} */
		let arr2 = [1, 2, 3, 4, 5];
		/** @type {string[]} */
		const slice1 = arr1.slice(1, 3);
		/** @type {number[]} */
		const slice2 = arr2.slice(0, 3);
		/** @type {number[]} */
		const slice3 = arr2.slice(3, arr2.length);
		/** @type {string} */
		const idx1 = slice1[1];
		/** @type {number} */
		arr2[0] = 1;
		/** @type {number} */
		arr2[0 + 1] = 2;
		builtin.println(arr2);
		arr2.push(6);
		arr2.push(...[7, 8, 9]);
		builtin.println(arr2);
		builtin.println("\n\n");
		/** @type {string} */
		let slice4 = idx1.slice(0, 4);
		builtin.print("Back\t=> ");
		builtin.println(slice4);
		/** @type {number} */
		const idx2 = slice4.charCodeAt(0);
		builtin.print("66\t=> ");
		builtin.println(idx2);
		/** @type {Map<string, string>} */
		let m = new Map();
		/** @type {string} */
		const key = "key";
		/** @type {string} */
		m.set(key, "value");
		/** @type {string} */
		const val = m.get("key");
		builtin.print("value\t=> ");
		builtin.println(val);
		builtin.print("true\t=> ");
		builtin.println(arr1.includes("JS"));
		builtin.print("false\t=> ");
		builtin.println(!(arr2.includes(3)));
		builtin.print("true\t=> ");
		builtin.println(m.has("key"));
		builtin.print("true\t=> ");
		builtin.println(!(m.has("badkey")));
		builtin.print("true\t=> ");
		builtin.println("hello".includes("o"));
		for (let _tmp1 = 0; _tmp1 < arr1.length; ++_tmp1) {
		}
		
		builtin.println("0 to 8\t=>");
		for (let i = 0; i < arr2.length; ++i) {
			builtin.println(i);
		}
		
		builtin.println("\n\n4 to 5\t=> ");
		for (let _tmp2 = 0; _tmp2 < slice3.length; ++_tmp2) {
			const v = slice3[_tmp2];
			builtin.println(v);
		}
		
		builtin.println("\n\n");
		/** @type {string[]} */
		const a = arr1.map(it => `VAL: ${it}`);
		/** @type {string[]} */
		const b = arr1.map(map_cb);
		/** @type {string[]} */
		const c = arr1.map(it => map_cb(it));
		/** @type {string[]} */
		const d = arr1.map(function (a) {
			return `ANON: ${a}`;
		});
		/** @type {number[]} */
		const e = arr1.map(it => 456);
		builtin.println(a);
		builtin.println(b);
		builtin.println(c);
		builtin.println(d);
		builtin.println(e);
		builtin.println("\n\n");
		/** @type {number[]} */
		const aa = arr2.filter(it => it < 4);
		/** @type {number[]} */
		const bb = arr2.filter(filter_cb);
		/** @type {number[]} */
		const cc = arr2.filter(it => filter_cb(it));
		/** @type {number[]} */
		const dd = arr2.filter(function (a) {
			return a < 4;
		});
		builtin.println(aa);
		builtin.println(bb);
		builtin.println(cc);
		builtin.println(dd);
		/** @type {number[]} */
		const f1 = [1, 2, 3, 4, 5];
		/** @type {number[]} */
		let f2 = [8];
		/** @type {number} */
		f2[0] = 1.23;
		/** @type {string[]} */
		const f3 = ["foo", "bar"];
		/** @type {number[]} */
		const f4 = [0xffffffffffffffff, 0xdeadface];
		builtin.println(`
${f1}
${f2}
${f3}
${f4}`);
	})();

	/* module exports */
	return {};
})();


