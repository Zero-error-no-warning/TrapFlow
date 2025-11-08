module trapflow.trapflow;
import trapflow.nestedFuzzy;
import std;

auto flow(T,S)(T v, lazy S _){
    return FlowImpl!(T,S)(v,x=>_,false,false);
}
auto flow(T,S)(T v, S delegate(T) _){
    return FlowImpl!(T,S)(v,x=>_,false,false);
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

    auto opCall(S lhs){
        if(justMatchNow && !matched){
            this.dg = x=>lhs;
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
                    else static if(isCallable!(Args[idx]) && is(T : ReturnType!(Args[idx]) ) ){
                        alias Func = Args[idx];
                        alias Params = ParameterTypeTuple!Func;
                        alias Names = ParameterIdentifierTuple!Func;
                        static foreach(i ; 0.. Params.length){
                            static if(is(Params[i] == T)){
                                enum name = Names[i].stringof;
                                mixin("auto " ~ name ~ " = value;");
                            }
                        }
                    }
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