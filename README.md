# rb_cwg
Ruby crossword generator.

## Why
I cannot find a good crossword generator on github, so I do it.

## Run
```ruby
ruby main.rb > ./crossword.txt
ruby main.rb -i <Input Word List> -o <Output Json> -s <Max Xmap Size> -p <Tuning Parameter> 
```

| Parameter | Default | Description |
|:---------:|:-------:|:-----------:|
|`-i`|`./word_list.txt`|Input word list, each word takes one line.|
|`-o`|`./crossword.json`|Output json file.|
|`-s`|`256`|Maximum size of crossword map.|
|`-p`|`0.1`|Tuning parameter.|
|`-h`||Help Message.|

## Method
1. Sort the word list by their length and chars variety (with ratio `p`).
2. Take each word in order, try to put it into Xmap.
3. If a word cannot be put into Xmap, try another way to put the last word.

Script finished with faliure means there's no solution for the word list. 
- Retry with a larger size of Xmap.
- Retry with another p
- Retry with less words

## Example
The `crossword.txt` in project folder is generate by `ruby main.rb -s 19 > ./crossword.txt`.

## Performance
Using `ruby main.rb -s 18` to obtain a 18x18 crossword map.

### v1.0
> 1500 iters/s

```txt
Run 7472859 iterations in 4933.88 sec.
Xmap Shape: 18 x 18
..b....sperm......
norman...x..stiffs
..i....h.c...h...p
c.duck.o.a.d.i.c.a
o.g....v.l.e.r.a.n
creosote.i.n.d.p.k
o...p..r.b.n...r.i
n.b.a..crucifixion
u.l.m..r.r.s...c.g
t.e....a..f....o..
..s..k.f.wobbler.d
castanets.r.a..n.e
a.e..i....k.p.h..i
m.d..g...l..t.i..r
e....g...l.finland
l.boxer..a..s.t..r
o.o..t...m..t.e..e
t.b..socrates.reg.
```

### v1.1
> 3700 iters/s

```txt
Load 30 words.
Run 49867859 iterations in 13459.03 sec.
Xmap Shape: 18 x 18
....third.spam..n.
.s......e.t.....o.
fork..h.n.i.e.d.r.
.c..l.o.n.f.x.u.m.
.r..l.v.i.f.c.c.a.
castanets.spanking
.t..m.r.....l.....
reg.a.crucifixion.
.s.h..r.....b.....
..finland...u..b.k
.c.l..f..capricorn
baptists.r.....b.i
.m.e.....e....b..g
deirdre.wobbler..g
.l.......s....i..e
boxer.coconut.d..t
.t.......t....g..s
....blessed.sperm.
```

### v1.2
Load 30 words.
Run 7472859 iterations in 1265.03 sec.
Xmap Shape: 18 x 18
..b....sperm......
norman...x..stiffs
..i....h.c...h...p
c.duck.o.a.d.i.c.a
o.g....v.l.e.r.a.n
creosote.i.n.d.p.k
o...p..r.b.n...r.i
n.b.a..crucifixion
u.l.m..r.r.s...c.g
t.e....a..f....o..
..s..k.f.wobbler.d
castanets.r.a..n.e
a.e..i....k.p.h..i
m.d..g...l..t.i..r
e....g...l.finland
l.boxer..a..s.t..r
o.o..t...m..t.e..e
t.b..socrates.reg.
