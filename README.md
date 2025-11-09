# TrapFlow

[日本語](#日本語) | [English](#english)

---

## 日本語

TrapFlowは、D言語のための表現力豊かなパターンマッチングライブラリです。これは実験的でおもちゃのライブラリです。実用的かどうかはわかりません。


### 基本的な使用法

#### 数値のパターンマッチング

```d
import trapflow;

auto x = 10.flow!string
    .trap[5]("5")
    .trap[$ <= 4](" <= 4")
    .trap[10,12]("10 12")
    .trap[15 .. 20]("15 16 17 18 19")
    .trap[$]("other")
    .result;
// 結果: "10 12"
```

#### ネスト構造体のマッチング

```d
struct Inner { int a; string b; }
struct Outer { Inner s; int t; }

auto x = Outer(Inner(3,"three"), 33).flow("default")
    .trap[$[$[1,"one"], $]]("case 1")
    .trap[$[$ , 22]]("case 2")
    .trap[$[$[$,"three"], 33]]("case 3")
    .result;
// 結果: "case 3"
```

#### 再帰的配列処理

```d
auto sum = (int[] arr) {
    return arr.flow!int
        .trap[[]]( 0 )
        .trap[$]( (x) => x[0] + sum(x[1..$]) )
        .result;
};

assert(sum([1,2,3,4,5]) == 15);
```

#### FizzBuzz実装例

```d
foreach(idx; 1..10) {
    auto fizzbuzz = tuple(idx % 3, idx % 5).flow!string
        .trap[$[0,0]]("FizzBuzz")
        .trap[$[0,$]]("Fizz")
        .trap[$[$,0]]("Buzz")
        .trap[$](idx.to!string)
        .result;
}
```

### API リファレンス

#### 主要なメソッド

- `flow(value)` - パターンマッチングフローを開始
- `.trap[pattern](action)` - パターンにマッチした場合のアクションを定義
- `.result` - マッチした結果を返す

#### パターンタイプ

- `[値]` - 値の等価性
- `[値1, 値2, ...]` - 複数値のマッチング
- `[値1..値2]` - 範囲マッチング（値1以上、値2未満）
- `[$]` - デフォルト/catchall パターン
- `[$[...]]` - 構造体や配列のマッチング（ネスト可能）


### ライセンス

MIT License


---

## English

TrapFlow is expressive pattern matching library for D language. This is experimental and toy library. I dont know this is practical.


### Basic Usage

#### Numeric Pattern Matching

```d
import trapflow;

auto x = 10.flow!string
    .trap[5]("5")
    .trap[$ <= 4](" <= 4")
    .trap[10,12]("10 12")
    .trap[15 .. 20]("15 16 17 18 19")
    .trap[$]("other")
    .result;
// Result: "10 12"
```

#### Nested Struct Matching

```d
struct Inner { int a; string b; }
struct Outer { Inner s; int t; }

auto x = Outer(Inner(3,"three"), 33).flow("default")
    .trap[$[$[1,"one"], $]]("case 1")
    .trap[$[$ , 22]]("case 2")
    .trap[$[$[$,"three"], 33]]("case 3")
    .result;
// Result: "case 3"
```

#### Recursive Array Processing

```d
auto sum = (int[] arr) {
    return arr.flow!int
        .trap[[]]( 0 )
        .trap[$]( (x) => x[0] + sum(x[1..$]) )
        .result;
};

assert(sum([1,2,3,4,5]) == 15);
```

#### FizzBuzz Example

```d
foreach(idx; 1..10) {
    auto fizzbuzz = tuple(idx % 3, idx % 5).flow!string
        .trap[$[0,0]]("FizzBuzz")
        .trap[$[0,$]]("Fizz")
        .trap[$[$,0]]("Buzz")
        .trap[$](idx.to!string)
        .result;
}
```

### API Reference

#### Main Methods

- `flow(value)` - Start pattern matching flow
- `.trap[pattern](action)` - Define action for pattern match
- `.result` - Return the matched result

#### Pattern Types

- `[value]` - Value equality
- `[value1, value2, ...]` - Multiple value matching
- `[v1..v2]` - Range matching ($ \rm{v1} \le x < \rm{v2} $)
- `[$]` - Default/catchall pattern
- `[$[...]]` - struct or array matching


### License

MIT License
