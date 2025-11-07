import std.stdio;
import trapflow.trapflow;

void main()
{
	auto x1 = 1.flow("default")
		.trap[5]( "five" )
		.trap[10]( "ten" )
		.trap[15]( "fifteen" )
		.trap[$]("other")
		.result();
	writeln(x1); // Output: ten

	struct MyStruct { int a; string b; }
	auto x2 = MyStruct(2,"hello").flow("default")
		.trap[ $[1,"one"] ]( "struct one" )
		.trap[ $[2,$] ]( "struct two or more" )
		.result();
	writeln(x2); // Output: struct two or more

	struct MyStruct2 { MyStruct s; int t; }
	auto x3 = MyStruct2( MyStruct(3,"three"), 30 ).flow("default")
		.trap[ $[$[1,"one"], $] ]( "struct2 with struct one" )
		.trap[ $[$[3,$] , 30] ]( "struct2 with struct three" )
		.result();
	writeln(x3); // Output: struct2 with struct three
}
