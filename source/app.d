import std.stdio;
import trapflow.trapflow;

void main()
{
	auto x = 1.flow("default")
		.trap[5]( "five" )
		.trap[10]( "ten" )
		.trap[15]( "fifteen" )
		.trap[$]("other")
		.result();
	writeln(x); // Output: ten
}
