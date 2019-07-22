# rb_cwg
Ruby crossword generator.

## Why
I cannot find a good crossword generator on github, so I do it.

## Run
1. Put your word list in `word_list.txt`
2. Pass the size of Xmap to `main.rb`, or using the length of word list.
```ruby
ruby main.rb
ruby main.rb -s <Max Xmap Size> -p <Tuning Parameter>
```
3. The result is saved in `crossword.txt`

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
The `crossword.txt` in project folder is generate by `ruby main.rb -p 0.25 -s 19`.