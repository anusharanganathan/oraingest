# Sufia [![Version](https://badge.fury.io/rb/sufia.png)](http://badge.fury.io/rb/sufia) [![Build Status](https://travis-ci.org/projecthydra/sufia.png?branch=master)](https://travis-ci.org/projecthydra/sufia) [![Dependency Status](https://gemnasium.com/projecthydra/sufia.png)](https://gemnasium.com/projecthydra/sufia)


# Installation

This is based on the instructions in the [Sufia README](https://github.com/projecthydra/sufia)

### Run the migrations

```
rake db:migrate
```

### Get a copy of hydra-jetty
```
rails g hydra:jetty
rake jetty:config
rake jetty:start
```

### Install Fits.sh
http://code.google.com/p/fits/downloads/list
Download a copy of fits & unpack it somewhere on your PATH.

### Start background workers
```
COUNT=4 QUEUE=* rake environment resque:work
```
See https://github.com/defunkt/resque for more options

### If you want to enable transcoding of video, instal ffmpeg version 1.0+
#### On a mac
Use homebrew:
```
brew install ffmpeg --with-libvpx --with-libvorbis
```

#### On Ubuntu Linux
See https://ffmpeg.org/trac/ffmpeg/wiki/UbuntuCompilationGuide
