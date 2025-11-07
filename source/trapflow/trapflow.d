module trapflow.trapflow;
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

    auto opCall(S lhs)=> justMatchNow && !matched ? FlowImpl(value,x=>lhs,true,false) : this;
    auto opCall(S delegate(T) dg) => justMatchNow && !matched ? FlowImpl(value,dg,true,false) : this;

    auto opDispatch(string name)() if(name == T.stringof && is(T == struct)){
        return FuzzyImpl(value,dg,matched);
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
                    else static if(is(X[idx] == bool)) cond = arg;
                    else cond = false;
                    if(cond){
                        return FlowImpl(value,null,false,true);
                    }
                }}
            }
            return FlowImpl(value,dg,matched,false);
        }
        auto opDollar()=>value;
        auto opDispatch(string name)() if(name == T.stringof && is(T == struct)){
            return FuzzyImpl(value,dg,matched);
        }

    }
    struct FuzzyImpl{
        T value;
        S delegate(T) dg;
        bool matched;
        this(T v, S delegate(T) dg, bool m){
            this.value = v;
            this.dg = dg;
            this.matched = m;
        }
        private struct Fuzzy(X){
            X value;
            alias value this;
        }
        private alias FieldTypes = FieldTypeTuple!T;
        auto opDollar(size_t idx)(){
            return Fuzzy!(FieldTypes[idx])(value.tupleof[idx]);
        }
        FlowImpl opIndex(Args...)(Args args) if(Args.length == T.tupleof.length){
            if(!matched){
                bool cond = true;
                static foreach(idx,arg;args){
                    static if(is(Args[idx] : FieldTypes[idx])) cond &= value.tupleof[idx] == arg;
                    else static if(is(Args[idx] : bool)) cond &= arg;
                    else cond &= false;
                }
                return FlowImpl(value,null,false,cond);
            }
            return FlowImpl(value,dg,matched,false);
        }
    }
}