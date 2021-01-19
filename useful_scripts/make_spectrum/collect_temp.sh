#!/bin/bash
for path in W*/ ;do 
	[ -d "${path}" ] || continue # if not a directory, skip
	dirname="$(basename "${path}")"
	echo $dirname
	cd $dirname
	cp gammatable temp
	sed -i -e "1,14d" temp
	cat temp >>../Spectrum
	rm temp
	cd ../
done

	
