// V_COMMIT_HASH d697b28
// V_CURRENT_COMMIT_HASH 11c06ec

// Generated by the V compiler
"use strict";

const CONSTANTS = Object.freeze({
	/** @type {number} - i_am_a_const */
	i_am_a_const: 	21214,
	/** @type {string} - v_super */
	v_super: "amazing keyword"
});


/* namespace: hello */
const hello = (function () {	/**
	* @return {string}
	*/
	function standard() {
		return "Hello";
	}
	
	/**
	* @return {string}
	*/
	function excited() {
		return hello.standard() + "!";
	}
	

	/* module exports */
	return {
		standard,
		excited,
	};
})();
/* namespace: main */
const main = (function (greeting) {	
	
class Companies {
		/**
		* @param {{google: number, amazon: boolean, yahoo: string}} values - values for this class fields
		* @constructor
		*/
		constructor(values) {
			this.google = values.google
			this.amazon = values.amazon
			this.yahoo = values.yahoo
		}
		
		/**
		* @return {number}
		*/
		method() {
			const it = this;
			const ss = new Companies({
				google: 2, 
				amazon: true, 
				yahoo: "hello"
			});
			/** @type {[number, number]} */
			const [a, b] = hello(2, "google", "not google");
			/** @type {string} - glue */
			const glue = (a > 2 ? "more_glue" : a > 5 ? "more glueee" : "less glue");
			if (a !== 2) {
			}
			
			return 0;
		}
	}
	const POSITION = Object.freeze({
		go_back: 0,
		dont_go_back: 1,
	});
	
	/**
	* @param {string} v_extends
	* @param {number} v_instanceof
	* @return {void}
	*/
	function v_class(v_extends, v_instanceof) {
		/** @type {number} - v_delete */
		const v_delete = v_instanceof;
	}
	
	/* program entry point */
	(async function() {
		console.log("Hello from V.js!");
		/** @type {string} - v */
		const v = "done";
		{
			/** @type {string} - _ */
			const _ = "block";
		}
		
		/** @type {number} - pos */
		const pos = POSITION.go_back;
		/** @type {string} - v_debugger */
		const v_debugger = "JS keyword";
		/** @type {string} - v_await */
		const v_await = CONSTANTS.v_super + v_debugger;
		/** @type {string} - v_finally */
		let v_finally = "implemented";
		console.log(v_await, v_finally);
		/** @type {number} - dun */
		const dun = CONSTANTS.i_am_a_const * 20;
		for (let i = 0; i < 10; i++) {
		}
		
		for (let i = 0; i < "hello".length; ++i) {
			let x = "hello"[i];
		}
		
		for (let x = 1; x < 10; ++x) {
		}
		
		/** @type {number[]} - arr */
		const arr = [1, 2, 3, 4, 5];
		for (let _tmp1 = 0; _tmp1 < arr.length; ++_tmp1) {
			let a = arr[_tmp1];
		}
		
		/** @type {Map<string, string>} - ma */
		const ma = new Map([
			["str", "done"],
			["ddo", "baba"]
		]);
		for (let [m, n] of ma) {
			/** @type {string} - iss */
			const iss = m;
		}
		
		await new Promise(function(resolve){
			async(0, "hello");
			resolve();
		});
		
		/** @type {anon_1011_7_1} - fn_in_var */
		const fn_in_var = function (number) {
			console.log(tos3(`number: ${number}`));
		};
		anon_consumer(greeting.excited(), function (message) {
			console.log(message);
		});
	})();
	
	/**
	* @param {string} greeting
	* @param {anon_fn_18_1} anon
	* @return {void}
	*/
	function anon_consumer(greeting, anon) {
		anon(greeting);
	}
	
	/**
	* @param {number} num
	* @param {string} def
	* @return {void}
	*/
	function async(num, def) {
	}
	
	/* [inline] */
	/**
	* @param {number} game_on
	* @param {...string} dummy
	* @return {multi_return_int_int}
	*/
	function hello(game_on, ...dummy) {
		for (let _tmp2 = 0; _tmp2 < dummy.length; ++_tmp2) {
			let dd = dummy[_tmp2];
			/** @type {string} - l */
			const l = dd;
		}
		
		(function defer() {
			/** @type {string} - v_do */
			const v_do = "not";
		})();
		return [game_on + 2, 221];
	}
	
	

	/* module exports */
	return {
	};
})(hello);
