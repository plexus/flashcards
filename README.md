# flashcards

A simple app that allows you to memorise with the flash cards method.
By default the data is a fixed set of Japanese hiragana, saved in `data/decks/hiragana.csv`.

## Usage

Install dependencies:

    $ gem install bundler
    $ bundle

Start the web application:

    $ ruby app.rb

Point your browser to [the web application](http://localhost:4567).

## Supply a different deck

You can supply your own deck of cards in csv format.
The default format is a csv file like the following:

    answer,question
    Eins,One
    Zwei,Two
    Drei,Three

Save it with `filename.csv` in `data/decks`.

Start the application with the specific deck:

    $ DECK=filename ruby app.rb

## Tests

Make sure you have all dependencies installed. See Usage.

    $ ruby test/all.rb

