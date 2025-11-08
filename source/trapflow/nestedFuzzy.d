module trapflow.nestedFuzzy;
import std;

struct NestedFuzzy(T){
    T value;
    alias value this;
    static if(is(T == struct)) private alias FieldTypes = FieldTypeTuple!T;
    else static if(isArray!T) alias ElemType = ElementType!T;
    
    bool opIndex(Args...)(Args args){
        bool cond = true;
        static foreach(idx,arg;args){
            static if(is(T == struct)){
                static if( is(Args[idx] : FieldTypes[idx])) cond &= value.tupleof[idx] == arg;
            }
            else static if(isArray!T){
                static if(is (Args[idx] : ElemType)) cond &= value[idx] == arg;
            }
            else static if(is(Args[idx] : bool)) cond &= arg;
            else cond &= false;
        }
        return cond;
    }
    auto opDollar(size_t idx)(){
        static if(is(T == struct)){
            static if(is(FieldTypes[idx] == struct)){
                return NestedFuzzy!(FieldTypes[idx])(value.tupleof[idx]);
            }
            else static if(isArray!(FieldTypes[idx])){
                return NestedFuzzy!(FieldTypes[idx])(value.tupleof[idx]);
            }
            else{
                return value.tupleof[idx];
            }
        }
        else static if(isArray!T){
            static if(is(ElemType == struct)){
                return NestedFuzzy!(ElemType)(value[idx]);
            }
            else static if(isArray!(ElemType)){
                return NestedFuzzy!(ElemType)(value[idx]);
            }
            else{
                return value[idx];
            }
        }
    }
}