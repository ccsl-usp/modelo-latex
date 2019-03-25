function euclid(a, b) // The \textbf{g.c.d.} of a and b
	r := a $\bmod$ b
	while r != 0 // We have the answer if r is 0
		a := b
		b := r
		r := a $\bmod$ b
	end
	return b // The \textbf{g.c.d.} is b
end
