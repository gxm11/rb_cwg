# rb_cwg
Ruby crossword generator.

## Run
1. Put your word list in `word_list.txt`
2. Pass the max size of map to `main.rb`, or using the length of word list.
```ruby
ruby main.rb
ruby main.rb 20
```
3. The result is saved in `crossword.txt`

## Method
1. Sort the word list by their length.
2. Take each word in order, try to put it into Xmap.
3. If a word cannot be put into Xmap, try another way to put the last word.

Script finished with faliure means there's no solution for the word list. Retry with a bigger size of Xmap.

## Next
Higher Performance. (Or you think ruby is fast enough?)
