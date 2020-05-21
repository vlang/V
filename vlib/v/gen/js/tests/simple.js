// V_COMMIT_HASH 74686d0
// V_CURRENT_COMMIT_HASH 0d3f133
// Generated by the V compiler

"use strict";

/* namespace: hello */
const hello = (function () {
	class A {
		/**
		 * @param {{foo?: string}} values - values for this class fields
		 * @constructor
		*/
		constructor(values) {
			this.foo = values.foo
		}
		
		/**
		 * @param {string} s
		 * @returns {void}
		*/
		update(s) {
			const a = this;
			a.foo = s;
		}
	}

	
	class B {
		/**
		 * @param {{}} values - values for this class fields
		 * @constructor
		*/
		constructor(values) {
		}
	}

	const C = Object.freeze({
	});
	
	/**
	 * @returns {string}
	*/
	function v_debugger() {
		const v = new B({
		});
		return "Hello";
	}
	
	/**
	 * @returns {string}
	*/
	function excited() {
		return v_debugger() + "!";
	}

	/* module exports */
	return {
		A,
		C,
		v_debugger,
		excited,
	};
})();

/* namespace: main */
const main = (function (hello) {
	class D {
		/**
		 * @param {{a?: hello["A"]["prototype"]}} values - values for this class fields
		 * @constructor
		*/
		constructor(values) {
			this.a = values.a
		}
	}

	/**
	 * @param {hello["A"]["prototype"]} arg
	 * @returns {void}
	*/
	function struct_arg(arg) {
		console.log(arg);
	}
	
	/* program entry point */
	(function() {
		struct_arg(new hello.A({
			foo: "hello"
		}));
		/** @type {number} - a */
		let a = 1;
		a += 2;
		console.log(a);
		const b = new hello.A({
		});
		console.log(b);
	})();

	/* module exports */
	return {
	};
})(hello);


