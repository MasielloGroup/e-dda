 clear
Begin=0.8
Finish=2.0
NumCal=100
Num=$(dc <<< "3k $NumCal 1-p")	
Inc=$(dc <<< "3k $Finish $Begin-p")
Incr=$(dc <<< "3k $Inc $Num/p")	
unit=1000
wave=0

	
for ((i=1;i<=$NumCal;i++));do
	mkdir W${i}
	cd W${i}
	wave=$(dc <<< "5k 1.24 $Begin/p")
	echo $wave
	cp ../ddscat.par ddscat.par
	sed -i "s#0.4\ 0.4#$wave\ $wave#" ddscat.par
	echo ${i} >> temp
	cat temp >> ../folders.tab
	rm temp
	ln -s ../shape.dat shape.dat
	Begin=$(dc <<< "$Begin $Incr+p ")
	cd ../
done
	mv ddscat.par par
	echo $NumCal >> numwave
