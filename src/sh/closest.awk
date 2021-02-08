#/usr/bin/env awk

function closest(b,i) { # define a function
	distance=250000000; # this should be higher than the max index to avoid returning null
	for (x in b) { # loop over the array to get its keys
		(x+0 > i+0) ? tmp = x - i : tmp = i - x # +0 to compare integers, ternary operator to reduce code, compute the diff between the key and the target
		if (tmp < distance) { # if the distance if less than preceding, update
			distance = tmp
			found = x # and save the key actually found closest
		}
	}
	return found  # return the closest key
}

{ # parse the files for each line (no condition)
	if (NR>FNR) { # If we changed file (File Number Record is less than Number Record) change array
		b[$2"-"$3]=$0 # make an array with $1 as key
	} else {
		akeys[max++] = $2"-"$3 # store the array keys to ensure order at end as for (x in array) does not guarantee the order
		a[$2"-"$3]=$0 # make an array with $1 as key
	}
}

END { # Now we ended parsing the two files, print the result
	for (i in akeys) { # loop over the first file keys
		# print a[akeys[i]] # print the value for this file
		if (akeys[i] in b) { # if the same key exist in second file
			print b[akeys[i]], a[akeys[i]] # then print it
		} else {
			bindex = closest(b,akeys[i]) # call the function to find the closest key from second file
			print b[bindex], a[akeys[i]] # print what we found
		}
	}
}



