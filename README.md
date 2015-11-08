# StubOnWeb [![Build Status](https://travis-ci.org/endeepak/stub_on_web.svg?branch=master)](https://travis-ci.org/endeepak/stub_on_web)

Create stub urls to test external API integration

Try it : http://stubonweb.herokuapp.com

## Running

* Install elixir, mongodb

* To start your app:

		mix deps.get
		mix ecto.create && mix ecto.migrate
		mix phoenix.server

* Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

* Ready to run in production? Please [check phoenix deployment guides](http://www.phoenixframework.org/docs/deployment).

## Contributing

You can raise issues and feature requests on [github](https://github.com/endeepak/stub_on_web/issues)

If you can code, fork the repo and raise a pull request

## Why yet another stub?

The existing web solutions suffer from some of the problems listed below

* Doesn't allow to choose your own path for url so it is easy to remember
* Doesn't allow to edit the response. Only way to test multiple scenarios is to create new url and update your app config and restart your services. Oh too much work!
* Change requests take longer time 
* UI cluttered with commercial aspect

And I was learning [elixir](http://elixir-lang.org/). This was simple enough and fun to try out!

## Thanks to 

Awesome people behind [elixir](elixir-lang.org), [phoenix](phoenixframework.org) and other libraries in the ecosystem
Service providers [heroku](https://www.heroku.com/home) and [mongolabs](https://mongolab.com/) for their free tier service


## License

MIT License

## ToDo

* Edit save to remain in edit
* Limit the number of calls stored in system
* 404 page to redirect to add new url
* Template for adding xml, json response

## Sins

* Lot of code in controller
* Low test coverage