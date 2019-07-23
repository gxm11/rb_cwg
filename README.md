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
|`-i`|`"./word_list.txt"`|Input word list, each word takes one line.|
|`-o`|`"./crossword.json"`|Output json file.|
|`-s`|`256`|Maximum size of crossword map.|
|`-p`|`0.1`|Tuning parameter.|

## Method
1. Sort the word list by their length and chars variety (with ratio `p`).
2. Take each word in order, try to put it into Xmap.
3. If a word cannot be put into Xmap, try another way to put the last word.

Script finished with faliure means there's no solution for the word list. 
- Retry with a larger size of Xmap.
- Retry with another p
- Retry with less words

## Next
Higher Performance. (Or you think ruby is fast enough?)

## Example
The `crossword.txt` in project folder is generate by `ruby main.rb -s 19 > ./crossword.txt`.