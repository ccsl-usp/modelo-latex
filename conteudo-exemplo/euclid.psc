function euclid($a,b$) // The \textbf{g.c.d.} of $a$ and $b$
	$r \gets a \bmod b$
	while $r \neq 0$ // We have the answer if $r$ is 0
		$a \gets b$
		$b \gets r$
		$r \gets a \bmod b$
	end
	return $b$ // The \textbf{g.c.d.} is $b$
end
