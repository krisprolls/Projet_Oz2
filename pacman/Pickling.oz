declare
fun {LoadPickle URL}
   F={New Open.file init(url:URL flags:[read])}
in
   try   
      VBS
   in
      {F read(size:all list:VBS)}
      {Pickle.unpack VBS}
   finally
      {F close}
   end
end

declare
URLmap='./test_map.ozp'
Map=map(r(1 1 1 1 1 1 1 5 1 1 1 1 1 1 1)
	r(1 0 0 0 0 0 0 0 0 1 0 0 0 0 1)
	r(1 3 0 0 0 0 0 0 0 1 2 0 0 0 1)
	r(1 0 0 0 0 0 0 0 4 1 0 0 0 0 1)
	r(1 0 0 0 0 0 0 0 0 1 1 1 0 0 1)
	r(1 0 0 0 0 0 0 0 0 1 0 0 0 0 1)
	r(1 0 0 0 0 0 0 0 0 1 0 0 0 0 1)
	r(1 1 1 0 0 1 1 1 1 1 0 0 0 0 1)
	r(1 0 0 0 0 0 0 1 0 0 0 0 0 0 1)
	r(1 3 0 0 0 0 0 1 4 0 0 0 0 3 1)
	r(1 0 0 0 0 0 0 1 0 0 0 0 0 0 1)
	r(1 0 0 0 0 0 0 1 0 0 0 0 0 0 1)
	r(1 0 0 0 0 0 0 1 2 0 0 0 0 0 1)
	r(1 0 0 0 0 0 0 0 0 0 0 0 0 0 1)
	r(1 1 1 1 1 1 1 1 1 1 1 1 1 1 1))
	
{Pickle.save Map URLmap}

{Browse {LoadPickle URLmap}}
