module trapflow.trapflow;
import trapflow.nestedFuzzy;
import std;

auto flow(T,S)(T v, lazy S _){
    return FlowImpl!(T,S)(v,x=>_(),false,false);
}
auto flow(T)(T v){
    return FlowImpl!(T,void)(v,null, false,false);
}
auto flow(S,T)(T v){
    return FlowImpl!(T,S)(v,null,false,false);
}

struct FlowImpl(T,S){
    T value;
    S delegate(T) dg;
    bool matched = false;
    bool justMatchNow = false;
    this(T v, S delegate(T) dg, bool m, bool jmn){
        this.value = v;
        this.dg = dg;
        this.matched = m;
        this.justMatchNow = jmn;
    }
    S result()=>dg(value);

    auto trap()=>TrapImpl(value,dg,matched);

    auto opCall(lazy S lhs){
        if(justMatchNow && !matched){
            this.dg = x=>lhs();
            this.matched = true;
            this.justMatchNow = false;
        }   
        return this;
    }
    auto opCall(S delegate(T) dg){
        if(justMatchNow && !matched){
            this.dg = dg;
            this.matched = true;
            this.justMatchNow = false;
        }   
        return this;
    }

    struct TrapImpl{
        T value;
        S delegate(T) dg;
        bool matched;
        auto opIndex(Args...)(Args args){
            if(!matched){
                static foreach(idx,arg;args){{
                    bool cond;
                    static if(is(T:Args[idx])) cond = value == arg;
                    else static if(is(Args[idx] : bool)) cond = arg;
                    else static if(is(Args[idx] : NestedFuzzy!T)) cond = true;
                    else cond = false;
                    if(cond){
                        return FlowImpl(value,dg,false,true);
                    }
                }}
            }
            return FlowImpl(value,dg,matched,false);
        }
        static if(isOrderingComparable!T){
             bool opSlice(size_t idx)(T v1,T v2)=> v1 <= value && value < v2;
        }
        auto opDollar(size_t idx)(){
            static if(is(T == struct) || isArray!T){
                return NestedFuzzy!(T)(value);
            }
            else{
                return value;
            }
        }
    }
    
    private alias FieldTypes = FieldTypeTuple!T;

}


unittest{ // 
	auto x = 10.flow!string
		.trap[5]( "5" )
		.trap[$ <= 4](" <= 4")
		.trap[10,12]( "10 12" )
		.trap[15 .. 20]( "15 16 17 18 19" )
		.trap[$]("other") 
		.result;
	assert(x == "10 12");
}	

unittest{// nested strcut
	struct Inner { int a; string b; }
	struct Outer { Inner s; int t; }
	auto x = Outer( Inner(3,"three"), 33 ).flow("default")
		.trap[ $[$[1,"one"], $] ]	( "case 1" )
		.trap[ $[ $ , 22] ]			( "case 2" )
		.trap[ $[$[$ ,"three"] , 33] ]	( "case 3" )
		.result;
	assert(x == "case 3"); //
}

unittest{
	auto sum = (int[] arr){
		return arr.flow!int
			.trap[ [] ] ( 0 )
			.trap[ $ ]  ( (x)=> x[0]+sum(x[1..$]) )
			.result;
	};
	assert(sum([1,2,3,4,5]) == 15);
}

unittest{
	foreach(idx;1..10){
		auto fizzbuzz = tuple(idx % 3, idx % 5).flow!string
			.trap[ $[0,0] ] ( "FizzBuzz")
			.trap[ $[0,$] ] ( "Fizz" )
			.trap[ $[$,0] ] ( "Buzz" )
			.trap[ $      ] ( idx.to!string )
			.result;
	}
}