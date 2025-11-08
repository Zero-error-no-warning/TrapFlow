import std;
import trapflow;

void main()
{
	{
		auto x = 10.flow!string
			.trap[5]( "5" )
			.trap[$ <= 4](" <= 4")
			.trap[10,12]( "10 12" )
			.trap[15 .. 20]( "15 16 17 18 19" )
			.trap[$]("other") 
			.result;
		writeln(x); // Output: ten
	}	

	{
		struct Inner { int a; string b; }
		struct Outer { Inner s; int t; }
		auto x = Outer( Inner(3,"three"), 33 ).flow("default")
			.trap[ $[$[1,"one"], $] ]	( "case 1" )
			.trap[ $[ $ , 22] ]			( "case 2" )
			.trap[ $[$[$ ,"three"] , 33] ]	( "case 3" )
			.result;
		writeln(x); // Output: struct2 with struct three
	}

	{
		auto x = [1,2,3].flow!int
			.trap[ [] ] ( 0 )
			.trap[ []]
			.result;
		writeln(x); // Output: one two three
	}

	foreach(idx;1..10){
		auto fizzbuzz = tuple(idx % 3, idx % 5).flow!string
			.trap[ $[0,0] ] ( "FizzBuzz")
			.trap[ $[0,$] ] ( "Fizz" )
			.trap[ $[$,0] ] ( "Buzz" )
			.trap[ $      ] ( idx.to!string )
			.result;
		writeln(fizzbuzz, " ");
	}
}
