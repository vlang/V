mut i := 4
goto L1
L1: for {
	i++
	for {
		if i < 7 {continue L1}
		else {break L1}
	}
}
assert i == 7

goto L2
L2: for ;; i++ {
	for {
		if i < 17 {continue L2}
		else {break L2}
	}
}
assert i == 17

goto L3
L3: for e in [1,2,3,4] {
	i = e
	for {
		if i < 3 {continue L3}
		else {break L3}
	}
}
assert i == 3
