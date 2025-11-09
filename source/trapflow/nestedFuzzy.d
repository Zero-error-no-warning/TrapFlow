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
            static if(is(Args[idx] : bool)) cond = cond && arg;
            else static if(is(T == struct) && is(Args[idx] : FieldTypes[idx])){
                cond = cond && value.tupleof[idx] == arg;
            }
            else static if(isArray!T && is (Args[idx] : ElemType)){
                cond = cond && value[idx] == arg;
            }
            else cond = cond && false;
        }
        return cond;
    }
    auto opDollar(size_t idx)(){
        static if(is(T == struct)){
            static if(is(FieldTypes[idx] == struct) || isArray!(FieldTypes[idx]) ){
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